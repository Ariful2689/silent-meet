import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'models/app_settings.dart';
import 'services/storage_service.dart';
import 'services/notification_service.dart';
import 'services/ringer_service.dart';
import 'l10n/app_localizations.dart';
import 'screens/home_screen.dart';
import 'screens/world_clock_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/schedules_screen.dart';

void main() {
  runApp(const SilentMeetApp());
}

class SilentMeetApp extends StatefulWidget {
  const SilentMeetApp({super.key});

  @override
  State<SilentMeetApp> createState() => _SilentMeetAppState();
}

class _SilentMeetAppState extends State<SilentMeetApp> {
  final _storage = StorageService();
  final _notifications = NotificationService();
  final _ringer = RingerService();

  AppSettings _settings = AppSettings.defaults();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await initializeDateFormatting();
    await initializeDateFormatting('bn');
    await _notifications.init();
    final loaded = await _storage.loadSettings();
    setState(() {
      _settings = loaded;
      _loading = false;
    });
  }

  /// Passed down to Settings screen so it can flip the app language
  /// instantly and persist the choice to local JSON.
  Future<void> _updateSettings(AppSettings newSettings) async {
    await _storage.saveSettings(newSettings);
    setState(() => _settings = newSettings);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    final loc = AppLocalizations(_settings.languageCode);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: loc.t('app_title'),
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF3F51B5), // deep indigo
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
          scrolledUnderElevation: 1,
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: EdgeInsets.zero,
        ),
        navigationBarTheme: NavigationBarThemeData(
          height: 68,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      home: RootShell(
        settings: _settings,
        storage: _storage,
        notifications: _notifications,
        ringer: _ringer,
        loc: loc,
        onSettingsChanged: _updateSettings,
      ),
    );
  }
}

/// Presentation Layer.
/// Simple bottom-nav shell wiring the four main screens together.
/// Swap for go_router later if your group wants named routes for
/// the "Architecture, Navigation & State Management" rubric line.
class RootShell extends StatefulWidget {
  final AppSettings settings;
  final StorageService storage;
  final NotificationService notifications;
  final RingerService ringer;
  final AppLocalizations loc;
  final ValueChanged<AppSettings> onSettingsChanged;

  const RootShell({
    super.key,
    required this.settings,
    required this.storage,
    required this.notifications,
    required this.ringer,
    required this.loc,
    required this.onSettingsChanged,
  });

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(
        loc: widget.loc,
        storage: widget.storage,
        ringer: widget.ringer,
      ),
      SchedulesScreen(
        loc: widget.loc,
        storage: widget.storage,
        notifications: widget.notifications,
      ),
      WorldClockScreen(loc: widget.loc, settings: widget.settings),
      SettingsScreen(
        loc: widget.loc,
        settings: widget.settings,
        notifications: widget.notifications,
        onChanged: widget.onSettingsChanged,
      ),
    ];

    return Scaffold(
      body: SafeArea(child: screens[_index]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: widget.loc.t('home_tab'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.event_note_outlined),
            selectedIcon: const Icon(Icons.event_note),
            label: widget.loc.t('schedules_tab'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.public_outlined),
            selectedIcon: const Icon(Icons.public),
            label: widget.loc.t('world_clock_tab'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings),
            label: widget.loc.t('settings_tab'),
          ),
        ],
      ),
    );
  }
}
