---
inclusion: always
---

# Estructura del proyecto

```
lib/
├── main.dart
│
├── core/
│   ├── database/
│   │   ├── app_database.dart          # @DriftDatabase — registra TODAS las tablas
│   │   └── database_providers.dart
│   ├── error/
│   │   ├── failures.dart              # + SyncFailure, ChallengeFailure, PairingFailure
│   │   └── exceptions.dart
│   ├── router/
│   │   └── app_router.dart            # rutas + redirect por estado de emparejamiento
│   ├── theme/
│   │   ├── app_theme.dart             # ThemeData claro/oscuro desde los tokens
│   │   ├── ink_colors.dart            # ThemeExtension con las dos tintas
│   │   └── app_typography.dart        # escala tipográfica
│   ├── time/
│   │   └── clock.dart                 # Clock inyectable + utilidades de epochDay
│   ├── usecase/usecase.dart
│   ├── utils/result.dart
│   └── widgets/                       # componentes del sistema de diseño
│       ├── ink_box.dart               # LA casilla sellada
│       ├── ink_button.dart
│       ├── ghost_button.dart
│       ├── eyebrow.dart
│       ├── amount.dart
│       ├── patina_panel.dart
│       ├── rule_of_365.dart
│       └── empty_plate.dart
│
└── features/
    ├── pairing/
    │   ├── domain/
    │   │   ├── entities/       pairing_state.dart, pair_invite.dart
    │   │   ├── repositories/   pairing_repository.dart
    │   │   └── usecases/       watch_pairing_state.dart, create_challenge.dart,
    │   │                       join_challenge.dart, build_pair_payload.dart,
    │   │                       apply_pair_payload.dart, reset_challenge.dart
    │   ├── data/
    │   │   ├── tables/         challenge_config_table.dart
    │   │   ├── models/         pairing_model.dart
    │   │   ├── datasources/    pairing_local_data_source.dart
    │   │   └── repositories/   pairing_repository_impl.dart
    │   └── presentation/
    │       ├── providers/      pairing_notifier.dart
    │       └── screens/        onboarding_screen.dart, pair_show_screen.dart,
    │                           pair_scan_screen.dart
    │
    ├── challenge/
    │   ├── domain/
    │   │   ├── entities/       box.dart, box_status.dart, challenge_progress.dart
    │   │   ├── repositories/   challenge_repository.dart
    │   │   └── usecases/       watch_boxes.dart, watch_progress.dart,
    │   │                       draw_next_box.dart, mark_box_paid.dart,
    │   │                       unmark_box_paid.dart
    │   ├── data/
    │   │   ├── tables/         own_boxes_table.dart
    │   │   ├── models/         box_model.dart
    │   │   ├── datasources/    challenge_local_data_source.dart
    │   │   └── repositories/   challenge_repository_impl.dart
    │   └── presentation/
    │       ├── providers/      challenge_notifier.dart
    │       ├── screens/        home_screen.dart, board_screen.dart
    │       └── widgets/        draw_button.dart, pending_payments_list.dart,
    │                           progress_header.dart
    │
    └── sync/
        ├── domain/
        │   ├── entities/       sync_payload.dart, restore_payload.dart,
        │   │                   sync_outcome.dart, partner_snapshot.dart
        │   ├── repositories/   sync_repository.dart
        │   └── usecases/       build_sync_payload.dart, apply_sync_payload.dart,
        │                       build_restore_payload.dart, apply_restore_payload.dart,
        │                       watch_partner_snapshot.dart, watch_partner_boxes.dart
        ├── data/
        │   ├── codec/          sync_codec.dart, crc32.dart   # Dart puro
        │   ├── tables/         partner_boxes_table.dart, partner_snapshot_table.dart
        │   ├── datasources/    sync_local_data_source.dart
        │   └── repositories/   sync_repository_impl.dart
        └── presentation/
            ├── providers/      sync_notifier.dart, qr_payload_provider.dart
            ├── screens/        sync_hub_screen.dart, sync_show_screen.dart,
            │                   sync_scan_screen.dart, partner_board_screen.dart,
            │                   restore_show_screen.dart, restore_scan_screen.dart
            └── widgets/        qr_plate.dart, freshness_label.dart

assets/fonts/                   Archivo-{Regular,SemiBold,ExtraBold}.ttf
                                IBMPlexMono-{Regular,SemiBold}.ttf

docs/                           data-model.md, qr-sync-protocol.md, design-system.md
test/                           refleja lib/ uno a uno
```

## Rutas

| Ruta | Pantalla |
|---|---|
| `/onboarding` | `OnboardingScreen` |
| `/pair/show` | `PairShowScreen` |
| `/pair/scan` | `PairScanScreen` |
| `/` | `HomeScreen` |
| `/board` | `BoardScreen` |
| `/partner` | `PartnerBoardScreen` |
| `/sync` | `SyncHubScreen` |
| `/sync/show` | `SyncShowScreen` |
| `/sync/scan` | `SyncScanScreen` |
| `/restore/scan` | `RestoreScanScreen` — solo desde `/onboarding` |
| `/restore/show` | `RestoreShowScreen` — solo desde `/settings` |
| `/settings` | `SettingsScreen` |

`redirect` global: sin emparejar → `/onboarding`; emparejado y en `/onboarding`
→ `/`.

## Se elimina

`lib/features/counter/` completo, su ruta, su tabla en `app_database.dart` y
`test/widget_test.dart`. Es andamiaje de la plantilla, no código del producto.

## Dónde vive `stateVersion`

En `ChallengeConfigRows`, tabla del feature `pairing`, pero lo escribe el
datasource de `challenge` en la misma transacción que cada mutación. Es un
acoplamiento **deliberado y documentado** en `docs/data-model.md` §2.1: ocurre
solo en la capa Data, y romper la atomicidad entre "sortear" y "subir la
versión" sería un bug de verdad.
