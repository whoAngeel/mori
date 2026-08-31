# Modelo de datos

> Esquema Drift, invariantes y matemática del progreso. Complemento de
> [`qr-sync-protocol.md`](qr-sync-protocol.md), que cubre el formato de cable.

---

## 1. La idea que simplifica todo

Cada persona tiene **sus propios 365**. De ahí se sigue todo lo demás:

> **Cada dispositivo es el autor único de su tablero. El tablero de la pareja es
> una réplica de solo lectura que se reemplaza completa.**

Consecuencias:

- **No existe conflicto de asignación.** Dos personas pueden sacar el día 45 el
  mismo día y no pasa nada: son casillas distintas en tableros distintos.
- **No hace falta un CRDT.** No hay escritura concurrente sobre el mismo dato.
- **No hace falta un reloj vectorial.** Un contador escalar por autor basta.
- **El merge es un reemplazo, no una fusión.** Y por eso es trivialmente
  idempotente, asociativo y conmutativo respecto al orden de escaneos.

La palabra "merge" en este proyecto significa *"reemplazar la réplica de la
pareja si el snapshot entrante es más nuevo"*. Nada más.

---

## 2. Tablas

Cuatro tablas. Dos son fila única (`id == 1`), siguiendo el patrón que ya usa
`CounterEntries` en la plantilla.

### 2.1 `ChallengeConfigRows` — fila única

*Feature dueño:* `pairing`

| Columna | Tipo | Notas |
|---|---|---|
| `id` | `int` PK | Siempre `1` |
| `pairingId` | `int` | uint32 lógico. Generado por quien crea el reto. |
| `localSlot` | `int` | `0` = A, `1` = B |
| `localInstallId` | `int` | uint64 lógico, aleatorio por instalación |
| `localName` | `text` | ≤ 24 bytes UTF-8 |
| `partnerName` | `text` nullable | `null` hasta cerrar el emparejamiento |
| `partnerInstallId` | `int` nullable | `null` hasta cerrar el emparejamiento |
| `startEpochDay` | `int` | Días desde 1970-01-01 UTC |
| `stateVersion` | `int` | **Contador monótono de mutaciones locales** |
| `createdAtMillis` | `int` | Solo informativo |

> **Nota de arquitectura.** `stateVersion` vive aquí aunque lo escriba el feature
> `challenge` y lo lea el feature `sync`. Es una dependencia cruzada
> **deliberada y documentada**: separarla en su propia tabla no eliminaría el
> acoplamiento, solo lo escondería, y romper la atomicidad entre "sortear" y
> "subir la versión" sí sería un bug real. La regla que se mantiene es que el
> acoplamiento ocurre en la capa **Data** (los datasources comparten la tabla);
> las capas Domain de cada feature siguen sin conocerse.

Que `partnerName` sea `null` es el estado *"emparejamiento a medias"*: yo ya te
invité pero todavía no escaneo tu respuesta. La UI lo refleja explícitamente.

### 2.2 `OwnBoxes` — 365 filas

*Feature dueño:* `challenge`

| Columna | Tipo | Notas |
|---|---|---|
| `day` | `int` PK | `1..365`. **Es también el monto en MXN.** |
| `status` | `int` | `0` free · `1` assigned · `2` paid |
| `drawnAtMillis` | `int` nullable | Solo local. No viaja en el QR. |
| `paidAtMillis` | `int` nullable | Solo local. No viaja en el QR. |

Las 365 filas se siembran de golpe al emparejar. Nunca se insertan ni se borran
filas después: solo se actualiza `status`.

> **Las fechas son opcionales de verdad.** Tras una recuperación con `RESTORE`,
> las 365 casillas vuelven con su `status` correcto pero con las dos fechas en
> `null`, porque el protocolo no transporta historial (decisión D10). No es un
> caso raro: es el estado normal de un tablero recuperado. La lista de por pagar
> ordena por `drawnAtMillis` y **cae a ordenar por `day`** cuando es `null`, y
> la etiqueta *"sorteado hace N días"* degrada a *"sin fecha"*.

### 2.3 `PartnerBoxes` — 365 filas

*Feature dueño:* `sync`

| Columna | Tipo | Notas |
|---|---|---|
| `day` | `int` PK | `1..365` |
| `status` | `int` | `0` free · `1` assigned · `2` paid |

Sin fechas: el protocolo no las transporta (decisión D10 del PRD). Esta tabla es
**derivada** — su única fuente es el último bitmap aceptado.

### 2.4 `PartnerSnapshots` — fila única

*Feature dueño:* `sync`

| Columna | Tipo | Notas |
|---|---|---|
| `id` | `int` PK | Siempre `1` |
| `stateVersion` | `int` | Del último snapshot aceptado |
| `installId` | `int` | Para detectar reinstalaciones |
| `startEpochDay` | `int` | La fecha de inicio *de ella*, según su payload |
| `receivedAtMillis` | `int` | Reloj local. **Solo para mostrar.** |

Si la fila no existe, nunca se ha sincronizado.

---

## 3. Invariantes

Se prueban con tests, no solo con buenas intenciones.

| # | Invariante | Cómo se sostiene |
|---|---|---|
| **I1** | `OwnBoxes` tiene exactamente 365 filas, `day` de 1 a 365, siempre. | Siembra transaccional al emparejar. Sin `insert`/`delete` posteriores. |
| **I2** | Una casilla nunca vuelve de `assigned` a `free`. | La transición no existe en el código. Sortear es irreversible (D7). |
| **I3** | `paid → assigned` sí está permitido (deshacer pago, supuesto A1). | Único retroceso de estado, y no toca la monotonicidad de I2. |
| **I4** | `stateVersion` es estrictamente creciente y sube en la misma transacción que la mutación. | Todas las mutaciones pasan por un único método que hace ambas cosas. |
| **I5** | `PartnerBoxes` tiene 0 o 365 filas. Nunca un número intermedio. | Se reemplaza dentro de una transacción. |
| **I6** | `PartnerSnapshots.stateVersion` nunca baja, salvo si cambia `installId`. | Regla de aceptación del §8 del protocolo. |
| **I7** | Aplicar dos veces el mismo payload deja la base idéntica. | La rama `==` de la regla de aceptación no escribe. |
| **I8** | Una casilla `assigned` o `paid` **puede** tener `drawnAtMillis` en `null`. | Es el estado normal tras recuperar con `RESTORE`: las fechas nunca cruzan el QR. Toda la UI debe tolerarlo. |
| **I9** | Un `RESTORE` solo se aplica si no existe `ChallengeConfigRows`. | Es la única operación capaz de destruir el tablero propio. Ver `qr-sync-protocol.md` §8.3. |

---

## 4. Matemática del progreso

Toda en Domain, Dart puro, sin Flutter ni Drift. Es la parte con más aristas y la
que más pruebas merece.

```dart
final drawn  = boxes.where((b) => b.status != BoxStatus.free).length;
final paid   = boxes.where((b) => b.status == BoxStatus.paid).length;

final savedMxn      = boxes.where((b) => b.status == BoxStatus.paid)
                           .fold(0, (s, b) => s + b.day);
final committedMxn  = boxes.where((b) => b.status != BoxStatus.free)
                           .fold(0, (s, b) => s + b.day);
const totalMxn      = 66795;   // sum(1..365)

final owedMxn       = committedMxn - savedMxn;   // sorteado y sin pagar
final remainingMxn  = totalMxn - committedMxn;   // ni sorteado
```

### Sorteos pendientes

Es la regla D3: uno por día natural, y los días no jugados se acumulan.

```dart
final elapsed  = todayEpochDay - startEpochDay;    // 0 el primer día
final earned   = (elapsed + 1).clamp(0, 365);      // sorteos ganados hasta hoy
final pending  = (earned - drawn).clamp(0, 365 - drawn);
```

Casos límite que las pruebas deben cubrir:

| Caso | `elapsed` | `earned` | Resultado |
|---|---|---|---|
| Primer día, nada sorteado | 0 | 1 | `pending == 1` |
| Día 10, sorteó 4 veces | 9 | 10 | `pending == 6` (acumulados) |
| Día 10, sorteó las 10 | 9 | 10 | `pending == 0` |
| Reloj movido hacia atrás | −5 | 0 | `pending == 0`, nunca negativo |
| Día 500 del calendario | 499 | 365 | `earned` topado en 365 |
| 365 casillas sorteadas | — | 365 | `pending == 0`, botón deshabilitado |

El `clamp` superior a `365 - drawn` es lo que impide que alguien que dejó pasar
tres meses vacíe el tablero de un tirón más allá de lo que existe.

> **El progreso de la pareja se calcula con la fecha de inicio de ella**
> (`PartnerSnapshots.startEpochDay`), no con la propia. Si las fechas coinciden
> —que es lo normal— da igual; si no, cada quien se mide contra su propio reto.

---

## 5. El sorteo

```dart
final free = boxes.where((b) => b.status == BoxStatus.free).toList();
if (free.isEmpty) return const Err(NoBoxesLeftFailure());
if (pending == 0) return const Err(NoDrawsPendingFailure());

final chosen = free[random.nextInt(free.length)];
```

`Random` se inyecta por provider. En producción es `Random()`; en pruebas es
`Random(seed)` para que el sorteo sea determinista. `Random.secure()` sería
teatro criptográfico en una app donde el reloj ya es manipulable a propósito.

La escritura es una transacción: `status = assigned`, `drawnAtMillis = ahora`,
`stateVersion += 1`.

**Nunca hay dos sorteos en vuelo.** El notifier deshabilita el botón mientras la
operación está pendiente; la selección y la escritura ocurren dentro de la misma
transacción Drift, así que dos toques rápidos no pueden asignar la misma casilla
dos veces.

---

## 6. Migraciones

`schemaVersion` de Drift arranca en **2**: la `1` es la plantilla con
`CounterEntries`. El feature `counter` se elimina completo, así que la migración
de 1 → 2 tira `counter_entries` y crea las cuatro tablas nuevas.

> **No confundir los dos `schemaVersion`:** el de Drift (esquema de SQLite) y el
> del payload QR (formato de cable) son contadores independientes y se mueven
> por razones distintas. Cambiar una columna sube el de Drift; cambiar un byte
> del payload sube el del QR.

Como no hay usuarios previos, la migración de 1 → 2 puede ser destructiva sin
ceremonia. A partir de la 2, cada cambio de esquema necesita su paso de
migración de verdad — el reto dura un año y borrar datos no es una opción.

---

## 7. Flujo end-to-end

```
Sortear
  CounterScreen-style ConsumerWidget
    → challengeProvider (AsyncNotifier)
      → DrawNextBox (usecase)
        → ChallengeRepository            (contrato, Domain)
          → ChallengeRepositoryImpl      (Exception → Failure, Data)
            → ChallengeLocalDataSource   (transacción Drift)
              → OwnBoxes + ChallengeConfigRows.stateVersion

Escanear
  SyncScanScreen (mobile_scanner)
    → syncProvider
      → ApplySyncPayload (usecase)
        → SyncRepository
          → SyncRepositoryImpl
            → SyncCodec.decode  (Dart puro, sin Drift)
            → validación (§7 del protocolo)
            → SyncLocalDataSource (transacción: PartnerBoxes + PartnerSnapshots)
```

Las capas Domain de `challenge`, `sync` y `pairing` **no se importan entre sí**.
Lo único compartido es `core/`.
