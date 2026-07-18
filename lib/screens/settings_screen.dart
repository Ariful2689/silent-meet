import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/app_settings.dart';
import '../services/notification_service.dart';

/// Presentation Layer.
/// Settings Manager UI — language toggle + permission request button.
class SettingsScreen extends StatelessWidget {
  final AppLocalizations loc;
  final AppSettings settings;
  final NotificationService notifications;
  final ValueChanged<AppSettings> onChanged;

  const SettingsScreen({
    super.key,
    required this.loc,
    required this.settings,
    required this.notifications,
    required this.onChanged,
  });

  Widget _sectionLabel(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8, top: 8),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(loc.t('settings_tab'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionLabel(context, loc.t('language')),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
            ),
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'en', label: Text('English')),
                ButtonSegment(value: 'bn', label: Text('বাংলা')),
              ],
              selected: {settings.languageCode},
              onSelectionChanged: (selection) {
                onChanged(settings.copyWith(languageCode: selection.first));
              },
            ),
          ),
          const SizedBox(height: 24),
          _sectionLabel(context, 'Permissions'),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: CircleAvatar(
                backgroundColor: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: 0.12),
                child: Icon(
                  Icons.notifications_active_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              title: Text(
                loc.t('permission_request_title'),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(loc.t('permission_request_body')),
              trailing: settings.dndPermissionGranted
                  ? const Icon(Icons.check_circle, color: Colors.green)
                  : FilledButton(
                      onPressed: () async {
                        final granted = await notifications.requestPermission();
                        onChanged(
                            settings.copyWith(dndPermissionGranted: granted));
                      },
                      child: const Text('Grant'),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
