---
inclusion: always
---

# Stack y convenciones técnicas

## Entorno verificado

| | |
|---|---|
| Flutter | 3.44.2 (stable) |
| Dart SDK | `^3.12.2` |
| Plataforma | Android únicamente |

## Dependencias

Ya en `pubspec.yaml`:

```yaml
flutter_riverpod: ^3.0.0
riverpod_annotation: ^3.0.0
go_router: ^17.0.0
drift: ^2.26.0
drift_flutter: ^0.2.8
path_provider: ^2.1.5
```

A añadir:

```yaml
mobile_scanner: ^7.4.0   # escanear QR (requiere Flutter >= 3.29)
qr_flutter: ^4.1.0       # dibujar QR
```

**Prohibidas:** cualquier dependencia de red (`http`, `dio`, `google_fonts`),
de analítica o de crash reporting. Las tipografías van empaquetadas en
`assets/fonts/`.

## Arquitectura

Clean Architecture tal como está documentada en `README.md`. Un feature = un
vertical con sus cuatro capas dentro.

```
Presentation ──▶ Domain ◀── Data
      │             ▲          │
      └──────▶ Core ◀──────────┘
```

- **Domain** es Dart puro. Cero imports de Flutter, Riverpod, Drift o `dart:ui`.
- **Data** implementa los contratos de Domain, captura `Exception` y devuelve
  `Result<Ok|Err>` con un `Failure`.
- **Presentation** llama casos de uso, nunca repositorios ni datasources.
- El cableado de DI de los casos de uso vive en Presentation, para que Domain
  siga puro.
- Las capas Domain de features distintos **no se importan entre sí**.

Se sigue el feature `counter` como plantilla de referencia — y luego **se
elimina**, junto con su tabla, su ruta y su pantalla.

## Codegen

```bash
dart run build_runner build --delete-conflicting-outputs
```

Genera los `*.g.dart` de Riverpod y de Drift. Tras cualquier cambio en tablas,
providers o rutas anotadas, hay que correrlo.

> `riverpod_generator` v3 recorta el sufijo `Notifier`: la clase
> `ChallengeNotifier` genera el provider **`challengeProvider`**.

## Base de datos

Drift. `schemaVersion` arranca en **2** (la 1 es la plantilla con
`CounterEntries`). Toda tabla nueva se registra en
`lib/core/database/app_database.dart` — es la única dependencia permitida de
`core` hacia `features`.

Esquema completo e invariantes: `docs/data-model.md`.

## Protocolo QR

`docs/qr-sync-protocol.md` es **normativo**. Formato binario, orden de
validación, regla de aceptación y vectores de oro. Si el código y el documento
discrepan, se arregla uno de los dos — no se dejan divergir.

El códec es Dart puro (`dart:convert` + `dart:typed_data`), sin dependencias.
El CRC-32 se implementa a mano.

## Estilo

- `flutter analyze` limpio. `custom_lint` incluido.
- Todo tipo público lleva doc comment, en el estilo de `core/` (inglés, empieza
  con una frase que dice qué es).
- Identificadores y comentarios de código en **inglés**; documentación de
  producto y textos de UI en **español**.
- Sin `print`. Sin `TODO` sin ticket.
- Nada de `Colors.*` ni `ColorScheme.fromSeed` en widgets: los colores salen de
  los tokens de `docs/design-system.md`.

## Pruebas

- Casos de uso y la matemática del progreso: `test/` con Dart puro.
- Drift: `NativeDatabase.memory()`.
- Códec y merge: pruebas de propiedad (round-trip, idempotencia, monotonicidad)
  más los vectores de oro del protocolo.
- El sorteo se prueba con `Random(seed)` inyectado.

## Comandos

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test
flutter run -d <device>
```
