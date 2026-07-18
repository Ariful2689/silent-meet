import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../l10n/weekday_labels.dart';
import '../models/meeting_schedule.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';
import 'add_edit_schedule_screen.dart';

/// Presentation Layer.
/// Lists schedules loaded from local storage; supports add, edit, delete.
class SchedulesScreen extends StatefulWidget {
  final AppLocalizations loc;
  final StorageService storage;
  final NotificationService notifications;

  const SchedulesScreen({
    super.key,
    required this.loc,
    required this.storage,
    required this.notifications,
  });

  @override
  State<SchedulesScreen> createState() => _SchedulesScreenState();
}

class _SchedulesScreenState extends State<SchedulesScreen> {
  List<MeetingSchedule> _schedules = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final loaded = await widget.storage.loadSchedules();
    if (!mounted) return;
    setState(() {
      _schedules = loaded;
      _loading = false;
    });
  }

  Future<void> _openForm({MeetingSchedule? existing}) async {
    final result = await Navigator.push<MeetingSchedule>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            AddEditScheduleScreen(loc: widget.loc, existing: existing),
      ),
    );
    if (result == null) return;

    final updated = [..._schedules];
    if (existing != null) {
      final index = updated.indexWhere((s) => s.id == existing.id);
      if (index != -1) updated[index] = result;
    } else {
      updated.add(result);
    }

    await widget.storage.saveSchedules(updated);

    // Refresh the UI immediately, regardless of whether notification
    // scheduling below succeeds — a notification failure (e.g. missing
    // exact-alarm permission on newer Android versions) should never
    // block the schedule from appearing on screen.
    if (mounted) {
      setState(() => _schedules = updated);
    }

    try {
      await widget.notifications.scheduleMeetingAlert(result);
    } catch (e) {
      debugPrint('Failed to schedule notification: $e');
    }
  }

  Future<void> _delete(MeetingSchedule schedule) async {
    final updated = _schedules.where((s) => s.id != schedule.id).toList();
    await widget.storage.saveSchedules(updated);
    if (mounted) {
      setState(() => _schedules = updated);
    }
  }

  String _formatHM(int h, int m) =>
      '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final labels = weekdayLabels(widget.loc.languageCode);

    return Scaffold(
      appBar: AppBar(title: Text(widget.loc.t('schedules_tab'))),
      body: _schedules.isEmpty
          ? Center(child: Text(widget.loc.t('no_schedules')))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _schedules.length,
              itemBuilder: (context, i) {
                final s = _schedules[i];
                final dayLabels =
                    s.weekdays.map((d) => labels[d - 1]).join(', ');
                final accentColor = s.silentMode
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.tertiary;

                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(16),
                    border:
                        Border(left: BorderSide(color: accentColor, width: 4)),
                  ),
                  child: ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: CircleAvatar(
                      backgroundColor: accentColor.withValues(alpha: 0.15),
                      child: Icon(
                        s.silentMode
                            ? Icons.notifications_off
                            : Icons.vibration,
                        color: accentColor,
                      ),
                    ),
                    title: Text(
                      s.title,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '${_formatHM(s.startHour, s.startMinute)} - '
                        '${_formatHM(s.endHour, s.endMinute)}  •  $dayLabels',
                      ),
                    ),
                    onTap: () => _openForm(existing: s),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => _delete(s),
                      tooltip: widget.loc.t('delete'),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(),
        tooltip: widget.loc.t('add_schedule'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
