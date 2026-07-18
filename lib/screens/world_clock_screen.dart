import 'dart:async';
import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/app_settings.dart';
import '../services/timezone_service.dart';

/// Presentation Layer.
/// Displays current time for each city saved in AppSettings.selectedCities.
/// Refreshes every second via a periodic timer so times stay live while
/// this screen is open, instead of only updating on tab switch.
class WorldClockScreen extends StatefulWidget {
  final AppLocalizations loc;
  final AppSettings settings;

  const WorldClockScreen(
      {super.key, required this.loc, required this.settings});

  @override
  State<WorldClockScreen> createState() => _WorldClockScreenState();
}

class _WorldClockScreenState extends State<WorldClockScreen> {
  final _tzService = TimezoneService();
  Timer? _tickTimer;

  static const _cityIcons = <String, IconData>{
    'Australia/Sydney': Icons.landscape_outlined,
    'Asia/Dhaka': Icons.temple_buddhist_outlined,
    'Europe/London': Icons.account_balance_outlined,
    'America/New_York': Icons.apartment_outlined,
  };

  @override
  void initState() {
    super.initState();
    _tickTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {}); // just triggers a rebuild to re-read time
    });
  }

  @override
  void dispose() {
    _tickTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.loc.t('world_clock_tab'))),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: widget.settings.selectedCities.length,
        itemBuilder: (context, i) {
          final city = widget.settings.selectedCities[i];
          final icon = _cityIcons[city] ?? Icons.public;

          return Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.12),
                  child:
                      Icon(icon, color: Theme.of(context).colorScheme.primary),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    _tzService.cityLabel(city),
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                Text(
                  _tzService.currentTimeIn(city,
                      locale: widget.settings.languageCode),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
