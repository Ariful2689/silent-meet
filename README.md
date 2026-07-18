# Silent Meet

Cross-platform Flutter app (ICT107 Assessment 3) that automatically switches a
device to silent/vibrate during scheduled meeting hours, displays world time
across cities, supports English + Bengali UI, stores all preferences in local
JSON, and sends pre-meeting notification alerts.

## Architecture

- **Presentation Layer** — `lib/screens/`, `lib/main.dart` (Flutter widgets, navigation)
- **Business Logic Layer** — `lib/services/notification_service.dart`,
  `lib/services/timezone_service.dart`
- **Data Layer** — `lib/services/storage_service.dart` (local JSON file via
  `path_provider`), `lib/models/`

## Key Modules

| Module | File |
|---|---|
| Settings Manager | `lib/screens/settings_screen.dart`, `lib/models/app_settings.dart` |
| Time Zone Module | `lib/services/timezone_service.dart` |
| Notification Scheduler | `lib/services/notification_service.dart` |
| Localization Engine | `lib/l10n/` |

## Getting started

```bash
flutter pub get
flutter run -d chrome      # or an emulator/device id from `flutter devices`
```

## Team

| Member | Role | Modules owned |
|---|---|---|
| TBD | | |
| TBD | | |
| TBD | | |
| TBD | | |

## Status

Starter skeleton — see TODOs in each screen file. Not yet feature-complete.

## Privacy & Security

- No network requests, no analytics.
- All data stored locally in a sandboxed JSON file (app documents directory).
- No sensitive/personal data is persisted — only scheduling preferences.
- Notification permission is explicitly requested from the user, not assumed.
