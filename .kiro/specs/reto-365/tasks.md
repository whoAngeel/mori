# Plan de implementación — Reto 365

> Cada tarea es un paso ejecutable que deja el proyecto compilando y con
> `flutter analyze` limpio. Se hacen en orden. Los `_Req_` apuntan a
> [`requirements.md`](requirements.md).
>
> Tras cualquier cambio en tablas, providers anotados o rutas:
> `dart run build_runner build --delete-conflicting-outputs`

---

## Fase 0 — Limpiar la plantilla

- [x] **0.1** Borrar `lib/features/counter/` completo y `test/widget_test.dart`.
  Quitar `CounterEntries` del `@DriftDatabase` y su import en
  `lib/core/database/app_database.dart`. Dejar el router apuntando a un
  `Placeholder` temporal.
  _Req: 10.8_

- [x] **0.2** Añadir `mobile_scanner: ^7.4.0` y `qr_flutter: ^4.1.0` a
  `pubspec.yaml`. Verificar que no entra ninguna dependencia de red.
  `flutter pub get`.
  _Req: 10.1_

- [x] **0.3** Descargar las fuentes OFL a `assets/fonts/`
  (`Archivo-{Regular,SemiBold,ExtraBold}.ttf`,
  `IBMPlexMono-{Regular,SemiBold}.ttf`) y declararlas en `pubspec.yaml` según
  `docs/design-system.md` §3. **No** usar `google_fonts`.
  _Req: 10.3_

- [x] **0.4** Declarar `<uses-permission android:name="android.permission.CAMERA" />`
  en `android/app/src/main/AndroidManifest.xml`.
  _Req: 7.1, 10.2_

---

## Fase 1 — Núcleo transversal

- [x] **1.1** `core/time/clock.dart`: interfaz `Clock`, `SystemClock`,
  `toEpochDay` y su provider. Pruebas de la conversión de fecha civil a
  `epochDay`, incluidos cambios de mes y de año.
  _Req: 3.1_

- [x] **1.2** Ampliar `core/error/failures.dart` con las jerarquías selladas
  `SyncFailure` y `ChallengeFailure` del diseño §3.
  _Req: 7.3_

- [x] **1.3** `core/theme/ink_colors.dart`: `ThemeExtension` con los ocho tokens,
  claro y oscuro, con los hex exactos de `docs/design-system.md` §2.
  Reescribir `app_theme.dart` sin `ColorScheme.fromSeed`.
  _Req: 10.4, 10.6_

- [x] **1.4** `core/theme/app_typography.dart`: la escala de
  `docs/design-system.md` §3, con `FontFeature.tabularFigures()` en los estilos
  de PlexMono.
  _Req: 5.2_

- [x] **1.5** Prueba: los seis pares de contraste de `docs/design-system.md` §2
  cumplen el mínimo anotado. Es una prueba aritmética, no visual — impide que
  alguien "ajuste un color" y rompa AA sin darse cuenta.
  _Req: 10.4_

---

## Fase 2 — Esquema

- [x] **2.1** Crear las cuatro tablas Drift según `docs/data-model.md` §2:
  `ChallengeConfigRows`, `OwnBoxes`, `PartnerBoxes`, `PartnerSnapshots`, cada una
  en su feature. Registrarlas en `app_database.dart`.
  _Req: 2.1_

- [x] **2.2** Subir el `schemaVersion` de Drift a **2** y escribir la migración
  1 → 2 (tira `counter_entries`, crea las cuatro tablas). Prueba con
  `NativeDatabase.memory()`.
  _Req: 10.8_

---

## Fase 3 — Códec del QR *(sin UI, todo probable en solitario)*

- [x] **3.1** `sync/data/codec/crc32.dart`: CRC-32/IEEE con tabla perezosa.
  Prueba contra valores conocidos.
  _Req: 7.3_

- [x] **3.2** `sync/data/codec/sync_codec.dart`: `encodeSync`, `encodePair`,
  `encodeRestore` y `decode`, siguiendo byte por byte `docs/qr-sync-protocol.md`
  §4 y §5. Incluye el empaquetado del bitmap de 2 bits. `decode` devuelve un
  sealed con las tres variantes; `RESTORE` es de longitud variable, así que su
  longitud se valida **después** de leer `senderNameLen`.
  _Req: 6.2, 11.3_

- [x] **3.3** Pruebas del códec — **obligatorias antes de seguir**:
  - round-trip de estados aleatorios con semilla fija, para los tres `kind`;
  - `encodeSync(...).length == 158` siempre;
  - vectores de oro V1, V2 y V3 de `docs/qr-sync-protocol.md` §11, byte a byte y
    también su texto base64url completo;
  - `RESTORE` con nombre de 1 byte → 122 bytes; con 24 bytes → 145 bytes; con
    emoji multibyte, decodifica idéntico;
  - los 365 días cubren los 92 bytes sin colisión ni hueco;
  - el día 365 cae en `bitmap[91]` con `shift = 6`;
  - los 6 bits de relleno siempre en cero;
  - voltear cualquier bit invalida el CRC;
  - `0b11` en cualquier par de bits produce `MalformedPayload`.
  _Req: 6.2, 7.3, 11.3_

- [x] **3.4** Orden de validación de `docs/qr-sync-protocol.md` §7,
  comprobaciones 1–7, dentro del códec. Una prueba por tipo de fallo.
  _Req: 7.3_

---

## Fase 4 — Emparejamiento

- [x] **4.1** Domain de `pairing`: entidades `PairingState` y `PairInvite`,
  contrato del repositorio, y los casos de uso `WatchPairingState`,
  `CreateChallenge`, `JoinChallenge`, `BuildPairPayload`, `ApplyPairPayload`,
  `RenameParticipants`, `ResetChallenge`.
  _Req: 1.2, 1.4, 1.5, 9.1_

- [x] **4.2** Data de `pairing`: datasource y repositorio.
  `CreateChallenge` siembra las 365 casillas y pone `stateVersion = 0` **en una
  sola transacción**. Prueba en memoria: exactamente 365 filas, todas `free`.
  _Req: 1.2, 2.1_

- [x] **4.3** `ApplyPairPayload` con las tres ramas: sin emparejamiento propio
  (adoptar), con emparejamiento y `pairingId` igual (solo guardar nombre e
  `installId`, **sin tocar las casillas**), `pairingId` distinto (rechazar sin
  escribir). Una prueba por rama.
  _Req: 1.4, 1.5, 1.7_

- [x] **4.4** Componentes del sistema de diseño que hacen falta ya:
  `InkButton`, `GhostButton`, `Eyebrow`, `EmptyPlate`
  (`docs/design-system.md` §7). Sin sombras, sin ripple.
  _Req: 10.5_

- [x] **4.5** `OnboardingScreen` con **tres** opciones (Yo empiezo / Me uno /
  Recuperar mi reto), `PairShowScreen` (QR con `qr_flutter`) y `PairScanScreen`.
  Copy exacto de `docs/design-system.md` §8. La tercera opción puede quedar
  apuntando a un `Placeholder` hasta la tarea 6.10.
  _Req: 1.1, 1.3, 1.6, 11.5_

- [x] **4.6** Router: rutas de `pairing` y `redirect` global por estado de
  emparejamiento (diseño §6).
  _Req: 1.1_

- [x] **4.7** Validación del nombre: 1 a 24 bytes UTF-8, con mensaje en la propia
  entrada. Prueba con emoji, que ocupan más de un byte.
  _Req: 1.9_

---

## Fase 5 — Tablero, sorteo y pagos

- [ ] **5.1** Domain de `challenge`: `Box`, `BoxStatus`, `ChallengeProgress` y
  la matemática de `docs/data-model.md` §4, en Dart puro.
  _Req: 5.1, 5.3_

- [ ] **5.2** Pruebas de `pendingDraws` — **obligatorias**: los seis casos límite
  de la tabla de `docs/data-model.md` §4, incluidos el reloj hacia atrás y el
  día 500.
  _Req: 3.1, 3.7_

- [ ] **5.3** Data de `challenge`: datasource con `watchBoxes`, `drawBox`,
  `markPaid`, `unmarkPaid`. Cada mutación sube `stateVersion` **en la misma
  transacción**. Prueba en memoria de esa atomicidad.
  _Req: 3.4, 4.1, 4.2_

- [ ] **5.4** Casos de uso `DrawNextBox`, `MarkBoxPaid`, `UnmarkBoxPaid`,
  `WatchBoxes`, `WatchProgress`. `Random` inyectado por provider.
  _Req: 3.4, 3.9, 4.1, 4.2_

- [ ] **5.5** Pruebas del sorteo: 365 sorteos consumen exactamente las 365
  casillas sin repetir; el 366.º falla con `NoBoxesLeft`; con `pending == 0`
  falla con `NoDrawsPending`; una casilla `assigned` nunca vuelve a `free`.
  _Req: 3.6, 3.8_

- [ ] **5.6** `InkBox`: la casilla sellada de `docs/design-system.md` §4, con el
  desfase determinista y los tres estados distinguidos por forma y relleno.
  Golden tests en los dos temas. Incluir `Semantics`.
  _Req: 2.3, 2.4_

- [ ] **5.7** `ChallengeNotifier` + `HomeScreen`: encabezado de progreso, botón
  de sorteo con su cuenta de pendientes, y lista de por pagar ordenada por
  antigüedad. Botón deshabilitado mientras la operación está en vuelo.
  _Req: 3.2, 3.3, 3.5, 4.3, 4.4, 5.1_

- [ ] **5.8** `BoardScreen`: `SliverGrid.builder` de 12 columnas, filtros, y
  `RuleOf365` al pie. Bajar a 7 columnas si el escalado de texto supera 1.3×.
  _Req: 2.2, 2.5, 2.6_

- [ ] **5.9** Estado final: al llegar a 365 casillas sorteadas, *"Terminaste los
  365. $66,795."* y sorteo desactivado para siempre. Prueba de widget.
  _Req: 3.8_

---

## Fase 6 — Sincronización

- [ ] **6.1** Domain de `sync`: `SyncSnapshot`, `SyncOutcome` sellado, contrato
  del repositorio, y los casos de uso `BuildSyncPayload`, `ApplySyncPayload`,
  `WatchPartnerSnapshot`, `WatchPartnerBoxes`.
  _Req: 6.1, 7.4_

- [ ] **6.2** `SyncRepositoryImpl` con la regla de aceptación de
  `docs/qr-sync-protocol.md` §8 y las comprobaciones 8–10 del §7.
  _Req: 7.5, 7.6, 7.7, 7.8, 7.9_

- [ ] **6.3** `SyncLocalDataSource.applySnapshot`: **una sola transacción** que
  reemplaza las 365 filas de `PartnerBoxes` y actualiza `PartnerSnapshots`.
  _Req: 7.4_

- [ ] **6.4** Pruebas de merge — **obligatorias antes de dar por cerrado el MVP**:
  - idempotencia: aplicar el mismo payload dos veces deja la base idéntica;
  - monotonicidad: un `stateVersion` menor no escribe nada;
  - `installId` distinto acepta aunque la versión baje, y reinicia la línea base;
  - un payload rechazado no deja ninguna escritura parcial;
  - `PartnerBoxes` nunca queda con un número de filas distinto de 0 o 365.
  _Req: 7.5, 7.6, 7.7, 7.12_

- [ ] **6.5** `syncQrPayloadProvider` memoizado por `stateVersion`, y
  `SyncShowScreen` con brillo al máximo, QR en negro sobre `plate`, corrección M
  y 16 dp de zona de silencio. Restaurar el brillo al salir.
  _Req: 6.1, 6.3, 6.4, 6.5_

- [ ] **6.6** `SyncScanScreen` con `mobile_scanner`: explicación previa al
  permiso, antirrebote que detiene el escáner al primer código,
  `DetectionSpeed.noDuplicates`, formato limitado a QR, liberación en `dispose`.
  _Req: 7.1, 7.2_

- [ ] **6.7** Mapear cada `SyncFailure` y cada `SyncOutcome` a su mensaje exacto
  de `docs/design-system.md` §8, con `switch` exhaustivo sobre el sealed.
  Incluir el recordatorio de completar el ritual en la otra dirección.
  _Req: 7.5, 7.6, 7.8, 7.9, 7.11_

- [ ] **6.8** `SyncHubScreen`: los dos pasos numerados y la fecha del último
  escaneo.
  _Req: 7.11_

- [ ] **6.9** `BuildRestorePayload`: lee `PartnerBoxes` + `PartnerSnapshots` y
  arma el `RESTORE` de `docs/qr-sync-protocol.md` §5.2. Devuelve
  `NothingToRestore` si no hay snapshot. Prueba: **no modifica ninguna tabla ni
  sube `stateVersion`**.
  _Req: 11.2, 11.3, 11.4_

- [ ] **6.10** `ApplyRestorePayload` con la guarda dura de
  `docs/qr-sync-protocol.md` §8.3, en el **repositorio**, no en la UI. Siembra
  las 365 casillas con fechas en `null`, genera un `localInstallId` nuevo, adopta
  `restoredStateVersion`, y **no** toca `PartnerBoxes` ni `PartnerSnapshots`.
  Todo en una transacción.
  _Req: 11.6, 11.7, 11.8_

- [ ] **6.11** Pruebas de `RESTORE` — **obligatorias**:
  - con `ChallengeConfigRows` presente, devuelve `RestoreNotApplicable` y la base
    queda byte a byte idéntica;
  - sin configuración, siembra 365 casillas con los estados correctos y **ambas
    fechas en `null`**;
  - el `localInstallId` resultante difiere del `senderInstallId`;
  - el `localSlot` es el contrario al del emisor;
  - `PartnerBoxes` y `PartnerSnapshots` siguen vacías tras recuperar.
  _Req: 11.6, 11.7, 11.8_

- [ ] **6.12** `RestoreShowScreen` (emisión desde Ajustes) y `RestoreScanScreen`
  (desde `/onboarding`, con entrada de nombre propio). Cada pantalla acepta **un
  solo `kind`** y rechaza los otros dos. Mensaje final con `daysStale`.
  _Req: 11.1, 11.5, 11.9, 11.10_

- [ ] **6.13** Tolerancia a fechas nulas en toda la UI: `PendingPaymentsList`
  ordena por `drawnAtMillis` con respaldo a `day`; la etiqueta de antigüedad
  degrada a *"sin fecha"*. Prueba de widget con un tablero recuperado.
  _Req: 11.11_

- [ ] **6.14** Mensaje diferenciado de reinstalación: comparar casillas no libres
  entrantes contra guardadas para distinguir pérdida de recuperación
  (`docs/qr-sync-protocol.md` §8.1). Una prueba por rama.
  _Req: 11.12_

---

## Fase 7 — La pareja

- [ ] **7.1** `PatinaPanel` y `FreshnessLabel`: la tabla de pátina de
  `docs/design-system.md` §5, con piso 0.35, opacidad **solo sobre las tintas** y
  la etiqueta de días siempre a contraste completo.
  _Req: 8.2, 8.3, 8.4_

- [ ] **7.2** Panel de la pareja en `HomeScreen` y `PartnerBoardScreen`, con el
  progreso calculado con **su** `startEpochDay`.
  _Req: 8.1, 8.5_

- [ ] **7.3** Aviso persistente cuando `startEpochDay` difiere, y aviso de
  reinstalación cuando cambió el `installId`.
  _Req: 7.7, 7.10_

---

## Fase 8 — Ajustes y cierre

- [ ] **8.1** `SettingsScreen`: editar nombres, ver `pairingId` / fecha de inicio
  / slot / día del reto, la explicación de que **el respaldo es el teléfono de la
  pareja**, y la entrada **Ayudar a [Nombre] a recuperar su reto** (inactiva si
  no hay `PartnerSnapshots`).
  _Req: 9.1, 9.2, 9.3, 11.1, 11.2_

- [ ] **8.2** Restablecer el reto con doble confirmación, borrado de las cuatro
  tablas y regreso a `/onboarding`.
  _Req: 1.8, 9.4_

- [ ] **8.3** Auditoría final:
  - `flutter analyze` sin advertencias;
  - `grep` sin resultados para `Colors.`, `fromSeed`, `BoxShadow`,
    `BackdropFilter`, `print(`;
  - `pubspec.yaml` sin dependencias de red;
  - `AndroidManifest.xml` con `CAMERA` como único permiso.
  _Req: 10.1, 10.2, 10.5, 10.6, 10.7_

- [ ] **8.4** Prueba completa en dispositivo con dos instalaciones: emparejar,
  sortear en ambas, pagar, sincronizar en las dos direcciones, reescanear un
  código viejo, y comprobar la pátina moviendo la fecha del sistema.
  _Req: 1.x, 7.x, 8.x_

- [ ] **8.5** Ensayo de desastre en dispositivo: desinstalar una de las dos apps,
  reinstalarla, recuperar con `RESTORE` desde la otra, comprobar que vuelven los
  365 estados sin fechas, volver a escanear a la pareja, y confirmar que la
  pareja ve *"reinstaló la app"* **sin** la frase de pérdida de avance.
  _Req: 11.6, 11.10, 11.11, 11.12_

- [ ] **8.6** Actualizar el `README.md`: sustituir la documentación de la
  plantilla por la del producto, con enlaces a `PRD.md` y a `docs/`.

---

## Orden de dependencias

```
Fase 0 ──▶ Fase 1 ──▶ Fase 2 ──▶ Fase 4 ──▶ Fase 5 ──▶ Fase 7 ──▶ Fase 8
                 └──▶ Fase 3 ──────────────▶ Fase 6 ──┘
```

La Fase 3 (códec) no depende de la base de datos ni de la UI: se puede hacer y
probar completa en paralelo con la 4 y la 5.

## Puertas de calidad

No se avanza de fase sin esto:

| Puerta | Antes de |
|---|---|
| Vectores de oro V1 y V2 en verde | Fase 6 |
| Los seis casos límite de `pendingDraws` en verde | Fase 5.3 |
| Idempotencia y monotonicidad del merge en verde | Fase 7 |
| `flutter analyze` limpio | cada commit |
