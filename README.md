# Silent Meet

A cross-platform Flutter application that automatically switches a device to
silent or vibrate mode during scheduled meeting hours. Built for **ICT107 —
Assessment 3 (Group Project)** at Sydney Metropolitan Institute of
Technology.

Silent Meet also displays live world-clock times across multiple cities
(anchored to the university's own Sydney timezone), supports a fully
bilingual English/Bengali interface, stores all data locally with no
network calls, and sends pre-meeting notification alerts.

---

## Features

- 📅 **Recurring meeting schedules** — create, edit, and delete meetings with
  custom start/end times, repeat days, and a silent or vibrate mode choice.
- 🔇 **Real ringer-mode automation** — genuinely changes the Android device's
  system ringer mode (not just an in-app indicator), via a native Kotlin
  platform channel to `AudioManager`. Verified at the OS level using
  `adb shell dumpsys audio`.
- 🌏 **World Clock** — live, auto-updating time for Sydney (university
  location), Dhaka, London, and New York.
- 🌐 **Bilingual UI** — full English / বাংলা (Bengali) interface toggle,
  including dynamically entered user content.
- 🔔 **Pre-meeting notifications** — configurable reminder alerts fired a
  set number of minutes before each meeting.
- 🔒 **Privacy by design** — all data stored locally via `shared_preferences`
  as JSON; zero network requests anywhere in the codebase.

---

## Architecture

Silent Meet follows a three-layer architecture:

```
Presentation Layer   → lib/screens/, lib/main.dart
Business Logic Layer → lib/services/notification_service.dart
                        lib/services/ringer_service.dart
                        lib/services/timezone_service.dart
Data Layer            → lib/services/storage_service.dart
                        lib/models/
```

The `RingerService` communicates with native Android code
(`android/app/.../MainActivity.kt`) through a Flutter `MethodChannel` to
call Android's `AudioManager` and `NotificationManager` APIs directly —
this is what allows the app to actually silence the device rather than
just displaying a status message.

A full architecture diagram and detailed write-up are included in the
project report (see `/docs` or the submitted report PDF).

---

## Tech Stack

| Purpose | Package |
|---|---|
| Notifications | [`flutter_local_notifications`](https://pub.dev/packages/flutter_local_notifications) |
| Local storage | [`shared_preferences`](https://pub.dev/packages/shared_preferences) |
| Date/locale formatting | [`intl`](https://pub.dev/packages/intl) |
| Timezone-aware scheduling | [`timezone`](https://pub.dev/packages/timezone) |

Built with Flutter SDK (stable channel) and Dart. Native Android
integration written in Kotlin.

---

## Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) installed and
  on your PATH
- Android Studio (for the Android SDK, an emulator, or a physical device)
- VS Code (recommended) with the Flutter and Dart extensions

### Setup
```bash
git clone https://github.com/Ariful2689/silent-meet.git
cd silent-meet
flutter pub get
```

### Run
```bash
flutter run -d chrome          # web
flutter run                    # connected Android device/emulator
```

### Build a release APK
```bash
flutter build apk --release
```
Output: `build/app/outputs/flutter-apk/app-release.apk`

---

## Project Structure

```
lib/
 ├─ main.dart                     # App entry point, theming, navigation shell
 ├─ models/
 │   ├─ meeting_schedule.dart
 │   └─ app_settings.dart
 ├─ services/
 │   ├─ storage_service.dart      # Local JSON persistence
 │   ├─ notification_service.dart # Pre-meeting alert scheduling
 │   ├─ ringer_service.dart       # Native ringer-mode bridge
 │   └─ timezone_service.dart     # World clock time calculations
 ├─ l10n/
 │   ├─ strings_en.dart
 │   ├─ strings_bn.dart
 │   ├─ app_localizations.dart
 │   └─ weekday_labels.dart
 └─ screens/
     ├─ home_screen.dart
     ├─ schedules_screen.dart
     ├─ add_edit_schedule_screen.dart
     ├─ world_clock_screen.dart
     └─ settings_screen.dart

android/
 └─ app/src/main/kotlin/.../MainActivity.kt   # Native AudioManager bridge
```

---

## Testing

Core functionality was tested manually on both the Android emulator
(Pixel 7, API 37) and Chrome (web). The ringer-mode feature was verified
two ways:
1. Visually, via the mute/DND icons appearing in the Android status bar.
2. Programmatically, via `adb shell dumpsys audio`, confirming
   `Ringer mode: mode (internal) = SILENT` with `com.example.silent_meet`
   logged as the calling package.

Full testing methodology and results are documented in the project report.

---

## Known Limitations / Future Work

- Ringer mode is currently re-evaluated only while the Home screen is open
  in the foreground (via a periodic timer), not through a true Android
  background service such as WorkManager. This is a documented
  architectural trade-off, not an oversight.
- iOS does not permit any third-party application to programmatically
  change ringer mode under any circumstances — this is a platform
  restriction, not an implementation gap.
- Localisation currently uses simple Dart string maps rather than
  Flutter's official ARB/gen-l10n pipeline; migrating would improve
  maintainability if more languages are added later.

---

## Team

| Member | Role |
|---|---|
| [Name 1] | Architecture, Navigation & App Shell |
| [Name 2] | Data Persistence & Schedules |
| [Name 3] | Notifications, Ringer Service & Time Zones |
| [Name 4] | UI/UX Design & Localisation |

---

## Assignment Context

**Unit:** ICT107
**Assessment:** Assessment 3 — Group Project (Report & Presentation)
**Institution:** Sydney Metropolitan Institute of Technology

This repository is one of four required submission deliverables, alongside
the release APK, the written report (PDF), and the presentation slides.

---

## License

Educational project submitted for academic assessment. Not intended for
production or commercial distribution.
