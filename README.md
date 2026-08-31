<div align="center">
  <img src="assets/icon/ic_launcher_fg.png" width="120" alt="Mori" />
  <h1>Mori · Reto 365 para dos</h1>
  <p>Una app de ahorro <strong>offline, sin backend</strong>, para que dos personas lleven juntas el reto de los 365 días.</p>
</div>

---

Cada persona tiene **su propio tablero de 365 casillas**. El número de la casilla
es el monto en pesos: la casilla 45 son \$45 MXN. Completar las 365 = **\$66,795
MXN por persona**.

Cada día se **sortea** una casilla libre al azar (nunca dos montos caros
seguidos). La app no mueve dinero: solo lleva el registro. La única forma de ver
el avance de tu pareja es **mostrar y escanear un código QR** — sin servidor, sin
cuenta, sin internet.

## Pantallas

| Onboarding | Emparejar (QR) | Inicio | Sorteo | Tablero |
|---|---|---|---|---|
| ![](docs/screenshots/onboarding.png) | ![](docs/screenshots/pair-qr.png) | ![](docs/screenshots/home.png) | ![](docs/screenshots/draw-reveal.png) | ![](docs/screenshots/board.png) |

## Documentación

La fuente de verdad es `docs/` y el PRD; el código los referencia, no los
re-explica.

| Documento | Contenido |
|---|---|
| [`PRD.md`](PRD.md) | Producto, decisiones (D1–D21), alcance del MVP, requisitos no funcionales. |
| [`docs/design-system.md`](docs/design-system.md) | «Dos tintas»: tokens de color, tipografía, componentes, la pátina, redacción. |
| [`docs/data-model.md`](docs/data-model.md) | Las cuatro tablas Drift, invariantes, la matemática de progreso y sorteo. |
| [`docs/qr-sync-protocol.md`](docs/qr-sync-protocol.md) | Formato binario del payload (`SYNC` / `PAIR` / `RESTORE`), CRC-32, orden de validación, regla de merge. |
| [`.kiro/specs/reto-365/`](.kiro/specs/reto-365/) | `requirements.md`, `design.md`, `tasks.md` — el plan de ejecución por fases. |

## Principios que no se negocian

- **Sin backend.** Los datos del reto nunca cruzan la red. La sincronización por
  QR existe *porque* no hay servidor.
- **Idempotente y monótono.** El orden lo da un contador local (`stateVersion`),
  nunca el reloj. Reescanear un QR viejo es un no-op, no un error.
- **Pools independientes.** Cada quien sortea sus propias 365 → no hay conflicto
  de asignación, no hace falta CRDT.
- **Se valida antes de tocar la base.** Todo escaneo pasa magic + versión + CRC +
  `pairingId` + `slot` antes de escribir. Aplicar un snapshot es una sola
  transacción Drift.
- **Telemetría opt-in.** La única salida de red posible es un reporte de crash
  (Sentry), apagado por defecto, se pregunta una vez (PRD D21).

## Stack

| Área | Herramienta |
|---|---|
| Arquitectura | Clean Architecture (Core · Domain · Data · Presentation) |
| Estado + DI | Riverpod 3 (`riverpod_annotation` + `riverpod_generator`) |
| Rutas | `go_router` (expuesto como provider) |
| BD local | Drift + SQLite |
| QR | `mobile_scanner` (leer) · `qr_flutter` (dibujar) |
| Cámara / pantalla | `screen_brightness` (brillo al mostrar un QR) |
| Crash reporting | `sentry_flutter` (opt-in) |
| Plataforma | Android |

## Estructura

```
lib/
├── main.dart                 # opt-in de telemetría → ProviderScope → MaterialApp.router
├── core/                     # transversal, sin dominio propio
│   ├── database/             # AppDatabase (registra las tablas de cada feature)
│   ├── error/                # sealed Failure / Exception
│   ├── router/               # goRouterProvider + enum AppRoute + redirect por estado de pairing
│   ├── telemetry/            # TelemetryConsent + pantalla de opt-in
│   ├── theme/                # InkColors (ThemeExtension), tipografía «Dos tintas»
│   ├── time/                 # Clock inyectable + toEpochDay
│   └── widgets/              # InkButton, GhostButton, Amount, Eyebrow, InkBox, RuleOf365…
└── features/
    ├── pairing/              # crear / unirse / recuperar el reto; ceremonia de dos pasos
    ├── challenge/            # tablero, sorteo, pagos, ceremonia de sorteo
    └── sync/                 # códec del QR, merge de snapshots, panel de la pareja, la pátina
```

Cada feature tiene sus cuatro capas dentro (`domain/ data/ presentation/`).
**Domain** es Dart puro (no conoce Flutter, Drift ni Riverpod); el cableado de DI
vive en `presentation/providers/` para mantenerlo así.

```
Presentation ──▶ Domain ◀── Data
      │             ▲          │
      └──────▶ Core ◀──────────┘
```

## Arrancar

```bash
flutter pub get
dart run build_runner build          # genera *.g.dart (Riverpod, Drift); usa `watch` en desarrollo
flutter run -d <device_id>           # ver dispositivos con: flutter devices
```

Requiere un dispositivo o emulador Android. Permiso: solo `CAMERA`, se pide al
entrar a escanear.

## Pruebas

```bash
flutter analyze     # sin advertencias
flutter test        # unidad + widget + golden (InkBox en ambos temas)
```

Cobertura clave: vectores de oro del códec QR byte a byte, idempotencia y
monotonicidad del merge, guardas del sorteo (365 sin repetir, día 500, reloj
hacia atrás), recuperación con fechas nulas, y que el `redirect` del router no
expulse de una pantalla al emparejar.

## Ícono

El disco sellado rojo sobre `paper`. Fuente y regeneración:
[`assets/icon/README.md`](assets/icon/README.md).
