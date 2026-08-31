# Diseño técnico — Reto 365

> Cómo se construye lo que pide [`requirements.md`](requirements.md).
> Los detalles profundos viven en `docs/` y **no se repiten aquí**:
>
> - Esquema, invariantes y matemática → [`docs/data-model.md`](../../../docs/data-model.md)
> - Formato binario del QR → [`docs/qr-sync-protocol.md`](../../../docs/qr-sync-protocol.md)
> - Tokens y componentes → [`docs/design-system.md`](../../../docs/design-system.md)

---

## 1. La decisión que da forma a todo

Cada persona tiene **sus propios 365**. De ahí:

> Cada dispositivo es autor único de su tablero. El tablero de la pareja es una
> réplica de solo lectura que se reemplaza completa.

No hay escritura concurrente sobre el mismo dato, así que **no hace falta CRDT,
ni reloj vectorial, ni resolución de conflictos**. "Merge" aquí significa
*reemplazar la réplica si el snapshot entrante es más nuevo*, y el orden lo da un
contador escalar por autor (`stateVersion`), no el reloj.

Si alguna vez se cambiara a un pool compartido, este diseño **no sirve** y habría
que rehacerlo desde el modelo de datos. Queda anotado a propósito.

---

## 2. Mapa de features

| Feature | Responsabilidad | Tablas propias |
|---|---|---|
| `pairing` | Identidad del reto: `pairingId`, slots, nombres, fecha de inicio, `stateVersion`. Ceremonia de emparejamiento. | `ChallengeConfigRows` |
| `challenge` | El tablero propio: sorteo, pagos, progreso. | `OwnBoxes` |
| `sync` | Códec del QR, validación, réplica de la pareja. | `PartnerBoxes`, `PartnerSnapshots` |

Las capas Domain de los tres **no se importan entre sí**. El único acoplamiento
es en Data: el datasource de `challenge` escribe `stateVersion` en la tabla de
`pairing` para mantener la atomicidad. Está documentado en `docs/data-model.md`
§2.1 y es deliberado.

---

## 3. Contratos de Domain

Dart puro. Sin Flutter, sin Riverpod, sin Drift.

```dart
// challenge/domain/entities
enum BoxStatus { free, assigned, paid }

final class Box {
  const Box({required this.day, required this.status, this.drawnAt, this.paidAt});
  final int day;                 // 1..365 — y también el monto en MXN
  final BoxStatus status;
  final DateTime? drawnAt;
  final DateTime? paidAt;
  int get amountMxn => day;
}

final class ChallengeProgress {
  final int savedMxn, committedMxn, owedMxn, remainingMxn;
  final int drawn, paid, pendingDraws, challengeDay;
  static const totalMxn = 66795;   // sum(1..365)
}
```

```dart
// sync/domain/entities
enum SyncPayloadKind { sync, pair, restore }

final class SyncSnapshot {
  final int pairingId, slot, installId, stateVersion, startEpochDay;
  final List<BoxStatus> statuses;   // longitud exacta 365
}

final class RestorePayload {
  final int pairingId, senderSlot, senderInstallId,
            restoredStateVersion, startEpochDay, snapshotEpochDay;
  final String senderName;
  final List<BoxStatus> statuses;   // el tablero DEL RESTAURADO
}

sealed class SyncOutcome {}
final class SyncApplied      extends SyncOutcome { final int stateVersion; }
final class SyncNoChange     extends SyncOutcome {}          // reescaneo
final class SyncPartnerReset extends SyncOutcome {            // installId distinto
  final bool lostProgress;   // entrantes < guardadas → distingue pérdida de recuperación
}
final class RestoreApplied   extends SyncOutcome { final int daysStale; }
```

```dart
// core/error/failures.dart — se añaden a la jerarquía existente
sealed class SyncFailure extends Failure { … }
final class MalformedPayload   extends SyncFailure {}
final class UnsupportedSchema  extends SyncFailure {}
final class UnsupportedKind    extends SyncFailure {}
final class ChecksumMismatch   extends SyncFailure {}
final class ForeignPairing     extends SyncFailure {}
final class OwnPayloadScanned  extends SyncFailure {}
final class StaleSnapshot      extends SyncFailure {}
final class RestoreNotApplicable extends SyncFailure {}   // ya hay un reto en curso
final class NothingToRestore     extends SyncFailure {}   // no hay PartnerSnapshot que emitir

sealed class ChallengeFailure extends Failure { … }
final class NoDrawsPending     extends ChallengeFailure {}
final class NoBoxesLeft        extends ChallengeFailure {}
```

Cada `Failure` mapea a **exactamente un** mensaje de la tabla de copy de
`docs/design-system.md` §8. La UI hace `switch` exhaustivo sobre el sealed: si se
añade un caso, el compilador obliga a redactar su mensaje.

### Casos de uso

| Feature | Casos de uso |
|---|---|
| `pairing` | `WatchPairingState`, `CreateChallenge`, `JoinChallenge`, `BuildPairPayload`, `ApplyPairPayload`, `RenameParticipants`, `ResetChallenge` |
| `challenge` | `WatchBoxes`, `WatchProgress`, `DrawNextBox`, `MarkBoxPaid`, `UnmarkBoxPaid` |
| `sync` | `BuildSyncPayload`, `ApplySyncPayload`, `WatchPartnerSnapshot`, `WatchPartnerBoxes`, `BuildRestorePayload`, `ApplyRestorePayload` |

Los `Watch*` devuelven `Stream<T>` desde Drift; el resto devuelve
`Future<Result<T>>`, como el `UseCase` de la plantilla.

---

## 4. El códec

`sync/data/codec/sync_codec.dart` — Dart puro, sin dependencias, testeable solo.

```dart
abstract final class SyncCodec {
  static String encodeSync(SyncSnapshot s);
  static String encodePair(PairInvite p);
  static String encodeRestore(RestorePayload r);
  static Result<DecodedPayload> decode(String text);   // sealed: sync | pair | restore
}
```

`decode` devuelve un sealed con las tres variantes, para que quien lo consuma
tenga que decidir explícitamente qué hace con cada `kind`. `RESTORE` es de
longitud variable (122..145 bytes) por el nombre del emisor, así que el códec
valida la longitud **después** de leer `senderNameLen`, no antes.

`crc32.dart` implementa CRC-32/IEEE con tabla perezosa (~20 líneas). No se añade
una dependencia por esto.

**El códec no conoce Drift ni la configuración local.** Solo traduce bytes ↔
estructuras y valida integridad (comprobaciones 1–7 de `qr-sync-protocol.md` §7).
Las comprobaciones 8–10, que necesitan el estado local, viven en
`SyncRepositoryImpl`. Esa frontera es lo que permite probar el códec con
vectores de oro sin base de datos.

---

## 5. Tiempo

`core/time/clock.dart`:

```dart
abstract interface class Clock {
  DateTime now();
  int todayEpochDay();     // día civil local → días desde epoch UTC
}
```

Inyectado por provider. En pruebas se usa un `FakeClock`, incluido el caso de
reloj que retrocede.

Conversión, que es donde se cometen los errores:

```dart
int toEpochDay(DateTime local) =>
    DateTime.utc(local.year, local.month, local.day)
        .millisecondsSinceEpoch ~/ 86400000;
```

Se normaliza a la fecha **civil** y luego a medianoche UTC. Nunca `toUtc()` sobre
un instante: eso desplaza el día.

El reloj alimenta dos cosas y nada más: el cálculo de sorteos pendientes y la
etiqueta *"impreso hace N días"*. **Ninguna decisión de merge lo consulta.**

---

## 6. Presentation

Un `AsyncNotifier` por feature, con `riverpod_generator`.

```dart
@riverpod
class ChallengeNotifier extends _$ChallengeNotifier {
  @override
  Stream<ChallengeState> build() => …;      // boxes + progress

  Future<void> draw() async { … }           // AsyncValue.guard
  Future<void> markPaid(int day) async { … }
  Future<void> unmarkPaid(int day) async { … }
}
```

> Recordatorio de `riverpod_generator` v3: la clase `ChallengeNotifier` genera el
> provider **`challengeProvider`**.

El QR se memoiza aparte para no regenerarlo en cada frame:

```dart
@riverpod
String syncQrPayload(Ref ref) {
  final version = ref.watch(stateVersionProvider);   // solo cambia con mutaciones
  return SyncCodec.encodeSync(…);
}
```

El router redirige por estado de emparejamiento:

```dart
redirect: (context, state) {
  final paired = ref.read(pairingStatusProvider);
  if (!paired && !state.uri.path.startsWith('/onboarding')
              && !state.uri.path.startsWith('/pair')) return '/onboarding';
  if (paired && state.uri.path == '/onboarding') return '/';
  return null;
}
```

---

## 7. Escaneo

`mobile_scanner: ^7.4.0`. Requisitos de implementación:

- Se declara `<uses-permission android:name="android.permission.CAMERA" />` en
  `AndroidManifest.xml`.
- La pantalla explica el uso **antes** de disparar la solicitud del sistema.
- El `MobileScannerController` se libera en `dispose`. Solo escanea mientras la
  pantalla está en primer plano.
- **Antirrebote:** al primer código detectado se detiene el escáner. Sin esto, la
  cámara entrega el mismo QR decenas de veces por segundo. El merge es
  idempotente, así que no corrompe nada — pero sí produciría decenas de mensajes
  y trabajo inútil.
- `detectionSpeed: DetectionSpeed.noDuplicates` y formato limitado a
  `BarcodeFormat.qrCode`.

---

## 7.1 Recuperación (`RESTORE`)

Es la única operación de la app capaz de destruir datos propios, así que su
diseño es sobre todo el diseño de sus guardas.

**Guarda dura:** `ApplyRestorePayload` comprueba que **no exista**
`ChallengeConfigRows` antes de tocar nada. Si existe, devuelve
`RestoreNotApplicable` sin escribir. La comprobación va en el repositorio, no en
la UI — una guarda que vive en una pantalla no es una guarda.

**Guarda de camino:** el escáner de `RESTORE` solo se alcanza desde la tercera
opción de `/onboarding`. `SyncScanScreen` rechaza el `kind` `0x03` con
`RestoreNotApplicable`, y `RestoreScanScreen` rechaza `0x01` y `0x02`. Cada
pantalla acepta un solo tipo.

**El emisor no muta nada.** `BuildRestorePayload` es una lectura de
`PartnerBoxes` + `PartnerSnapshots`. No sube `stateVersion`. Si no hay
`PartnerSnapshots`, devuelve `NothingToRestore` y la entrada en Ajustes aparece
inactiva.

**Consecuencia que se propaga a toda la UI:** tras recuperar, las 365 casillas
tienen `status` correcto y `drawnAtMillis` / `paidAtMillis` en `null`. No es un
borde: es el estado normal de un tablero recuperado. `PendingPaymentsList` ordena
por `drawnAtMillis` **con respaldo a `day`**, y `FreshnessLabel` degrada a *"sin
fecha"*. Conviene escribir esa prueba antes que el propio `RESTORE`.

**Mensaje honesto.** `RestoreApplied` lleva `daysStale`, calculado desde
`snapshotEpochDay`. La app dice cuánto se recuperó y cuánto no, en lugar de
celebrar una recuperación completa que no ocurrió.

---

## 8. Tema

`AppTheme` deja de usar `ColorScheme.fromSeed` y construye el `ColorScheme` a
mano desde los tokens de `docs/design-system.md` §2. Las dos tintas van en un
`ThemeExtension`:

```dart
@immutable
final class InkColors extends ThemeExtension<InkColors> {
  final Color paper, plate, inkBlack, inkMuted, inkSelf, inkPartner,
              overprint, rule;
}
```

Uso: `Theme.of(context).extension<InkColors>()!.inkSelf`. Ningún widget nombra un
color literal.

---

## 9. Migración de la plantilla

1. Borrar `lib/features/counter/` completo y `test/widget_test.dart`.
2. Quitar `CounterEntries` de `@DriftDatabase` y el import correspondiente.
3. Subir `schemaVersion` de Drift a **2** y escribir la migración 1 → 2, que tira
   `counter_entries` y crea las cuatro tablas nuevas. Sin usuarios previos, puede
   ser destructiva. A partir de la 2, ya no.
4. Reemplazar la ruta `/` del router.

---

## 10. Estrategia de pruebas

| Nivel | Qué se prueba | Cómo |
|---|---|---|
| Unitaria pura | Matemática del progreso y de los sorteos pendientes, incluidos los seis casos límite de `docs/data-model.md` §4 | Dart puro, `FakeClock` |
| Unitaria pura | Códec: round-trip, longitud 158, vectores de oro V1 y V2, cobertura de las 365 casillas, relleno en cero, detección de bits volteados | Dart puro |
| Propiedad | Idempotencia (`apply∘apply == apply`) y monotonicidad (un `stateVersion` menor nunca escribe) | Generación de estados aleatorios con semilla fija |
| Integración | Datasources y transacciones: siembra de 365, atomicidad de sorteo + `stateVersion`, reemplazo de `PartnerBoxes` | `NativeDatabase.memory()` |
| Widget | `InkBox` en los tres estados y en los dos temas | Golden tests |
| Widget | `HomeScreen` con providers sobrescritos: botón activo, inactivo, y tablero terminado | `ProviderScope(overrides:)` |

Las pruebas obligatorias antes de dar por cerrado el MVP son las de idempotencia,
monotonicidad y los vectores de oro. Son las que protegen el dato de 365 días.
