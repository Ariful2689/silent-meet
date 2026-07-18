import 'dart:async';
import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;
import '../l10n/app_localizations.dart';
import '../models/meeting_schedule.dart';
import '../services/storage_service.dart';
import '../services/ringer_service.dart';

/// Presentation Layer.
/// Shows either the meeting currently in progress (if any) or the
/// soonest upcoming one, computed from saved schedules.
///
/// All "is this meeting active right now" logic compares against
/// Australia/Sydney time (the university's timezone), not the device's
/// own local time, per the assignment requirement.
class HomeScreen extends StatefulWidget {
  final AppLocalizations loc;
  final StorageService storage;
  final RingerService ringer;

  const HomeScreen({
    super.key,
    required this.loc,
    required this.storage,
    required this.ringer,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _zoneName = 'Australia/Sydney';

  List<MeetingSchedule> _schedules = [];
  bool _loading = true;
  Timer? _refreshTimer;

  tz.TZDateTime get _nowSydney => tz.TZDateTime.now(tz.getLocation(_zoneName));

  @override
  void initState() {
    super.initState();
    _load();
    _refreshTimer = Timer.periodic(const Duration(seconds: 20), (_) => _load());
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    final loaded = await widget.storage.loadSchedules();
    if (!mounted) return;
    setState(() {
      _schedules = loaded;
      _loading = false;
    });
    await _applyRingerModeForNow();
  }

  Future<void> _applyRingerModeForNow() async {
    final active = _schedules.where(_isActiveNow).toList();
    if (active.isNotEmpty) {
      final mode = active.first.silentMode ? 'silent' : 'vibrate';
      await widget.ringer.setRingerMode(mode);
    } else {
      await widget.ringer.setRingerMode('normal');
    }
  }

  bool _isActiveNow(MeetingSchedule s) {
    final now = _nowSydney;
    if (!s.weekdays.contains(now.weekday)) return false;
    final nowMin = now.hour * 60 + now.minute;
    final startMin = s.startHour * 60 + s.startMinute;
    final endMin = s.endHour * 60 + s.endMinute;
    return nowMin >= startMin && nowMin < endMin;
  }

  tz.TZDateTime? _nextOccurrence(MeetingSchedule s) {
    final now = _nowSydney;
    final sydney = tz.getLocation(_zoneName);
    for (int i = 0; i < 8; i++) {
      final day = now.add(Duration(days: i));
      if (!s.weekdays.contains(day.weekday)) continue;
      final candidate = tz.TZDateTime(
        sydney,
        day.year,
        day.month,
        day.day,
        s.startHour,
        s.startMinute,
      );
      if (candidate.isAfter(now)) return candidate;
    }
    return null;
  }

  String _formatHM(int h, int m) =>
      '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final active = _schedules.where(_isActiveNow).toList();

    MeetingSchedule? upcoming;
    tz.TZDateTime? upcomingTime;
    for (final s in _schedules) {
      final next = _nextOccurrence(s);
      if (next == null) continue;
      if (upcomingTime == null || next.isBefore(upcomingTime)) {
        upcoming = s;
        upcomingTime = next;
      }
    }

    return FutureBuilder<bool>(
      future: widget.ringer.hasDndAccess(),
      builder: (context, snapshot) {
        final hasAccess = snapshot.data ?? false;
        final statusColor = active.isNotEmpty
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.outline;

        return Scaffold(
          appBar: AppBar(title: Text(widget.loc.t('app_title'))),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                if (!hasAccess)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: Theme.of(context).colorScheme.onErrorContainer,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Grant "Do Not Disturb access" in Settings to '
                          'let this app actually change your ringer mode.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color:
                                Theme.of(context).colorScheme.onErrorContainer,
                          ),
                        ),
                        const SizedBox(height: 12),
                        FilledButton(
                          onPressed: () async {
                            await widget.ringer.requestDndAccess();
                          },
                          child: const Text('Open Settings'),
                        ),
                      ],
                    ),
                  ),
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          active.isNotEmpty
                              ? (active.first.silentMode
                                  ? Icons.notifications_off
                                  : Icons.vibration)
                              : Icons.notifications_none_outlined,
                          size: 56,
                          color: statusColor,
                        ),
                      ),
                      const SizedBox(height: 24),
                      if (active.isNotEmpty) ...[
                        Chip(
                          label: Text(widget.loc.t('currently_active')),
                          backgroundColor: statusColor.withValues(alpha: 0.15),
                          labelStyle: TextStyle(color: statusColor),
                          side: BorderSide.none,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          active.first.title,
                          style: Theme.of(context).textTheme.headlineSmall,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${widget.loc.t('until')} '
                          '${_formatHM(active.first.endHour, active.first.endMinute)}',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ] else if (upcoming != null && upcomingTime != null) ...[
                        Text(
                          widget.loc.t('next_meeting'),
                          style: Theme.of(context)
                              .textTheme
                              .labelLarge
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          upcoming.title,
                          style: Theme.of(context).textTheme.headlineSmall,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_formatHM(upcoming.startHour, upcoming.startMinute)} - '
                          '${_formatHM(upcoming.endHour, upcoming.endMinute)}',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ] else
                        Text(
                          widget.loc.t('no_upcoming'),
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
