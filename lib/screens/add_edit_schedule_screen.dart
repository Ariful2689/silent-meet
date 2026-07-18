import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../l10n/weekday_labels.dart';
import '../models/meeting_schedule.dart';

/// Presentation Layer.
/// Full add/edit form for a MeetingSchedule. Returns the new/updated
/// MeetingSchedule via Navigator.pop when saved, or null if cancelled.
class AddEditScheduleScreen extends StatefulWidget {
  final AppLocalizations loc;
  final MeetingSchedule? existing;

  const AddEditScheduleScreen({super.key, required this.loc, this.existing});

  @override
  State<AddEditScheduleScreen> createState() => _AddEditScheduleScreenState();
}

class _AddEditScheduleScreenState extends State<AddEditScheduleScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  late Set<int> _selectedWeekdays; // 1=Mon ... 7=Sun
  late bool _silentMode;
  late bool _notifyBefore;
  late int _notifyMinutesBefore;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _titleController = TextEditingController(text: e?.title ?? '');
    _startTime =
        TimeOfDay(hour: e?.startHour ?? 9, minute: e?.startMinute ?? 0);
    _endTime = TimeOfDay(hour: e?.endHour ?? 9, minute: e?.endMinute ?? 30);
    _selectedWeekdays = (e?.weekdays ?? const [1, 2, 3, 4, 5]).toSet();
    _silentMode = e?.silentMode ?? true;
    _notifyBefore = e?.notifyBefore ?? true;
    _notifyMinutesBefore = e?.notifyMinutesBefore ?? 5;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _pickTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _startTime = picked;
      } else {
        _endTime = picked;
      }
    });
  }

  String _formatTime(TimeOfDay t) {
    final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final m = t.minute.toString().padLeft(2, '0');
    final period = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$h:$m $period';
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedWeekdays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.loc.t('select_day_required'))),
      );
      return;
    }

    final schedule = MeetingSchedule(
      id: widget.existing?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      startHour: _startTime.hour,
      startMinute: _startTime.minute,
      endHour: _endTime.hour,
      endMinute: _endTime.minute,
      weekdays: _selectedWeekdays.toList()..sort(),
      silentMode: _silentMode,
      notifyBefore: _notifyBefore,
      notifyMinutesBefore: _notifyMinutesBefore,
    );

    Navigator.pop(context, schedule);
  }

  @override
  Widget build(BuildContext context) {
    final loc = widget.loc;
    final labels = weekdayLabels(loc.languageCode);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.existing == null
              ? loc.t('add_schedule')
              : loc.t('edit_schedule'),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: loc.t('meeting_title'),
                border: const OutlineInputBorder(),
              ),
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? loc.t('title_required')
                  : null,
            ),
            const SizedBox(height: 20),
            Text(loc.t('start_time'),
                style: Theme.of(context).textTheme.labelLarge),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.access_time),
              title: Text(_formatTime(_startTime)),
              onTap: () => _pickTime(true),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Theme.of(context).dividerColor),
              ),
              tileColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
            const SizedBox(height: 12),
            Text(loc.t('end_time'),
                style: Theme.of(context).textTheme.labelLarge),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.access_time_filled),
              title: Text(_formatTime(_endTime)),
              onTap: () => _pickTime(false),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Theme.of(context).dividerColor),
              ),
              tileColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
            const SizedBox(height: 20),
            Text(loc.t('select_days'),
                style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: List.generate(7, (i) {
                final weekdayNum = i + 1; // 1=Mon ... 7=Sun
                final selected = _selectedWeekdays.contains(weekdayNum);
                return FilterChip(
                  label: Text(labels[i]),
                  selected: selected,
                  onSelected: (isSelected) {
                    setState(() {
                      if (isSelected) {
                        _selectedWeekdays.add(weekdayNum);
                      } else {
                        _selectedWeekdays.remove(weekdayNum);
                      }
                    });
                  },
                );
              }),
            ),
            const SizedBox(height: 20),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                  _silentMode ? loc.t('silent_mode') : loc.t('vibrate_mode')),
              secondary:
                  Icon(_silentMode ? Icons.notifications_off : Icons.vibration),
              value: _silentMode,
              onChanged: (v) => setState(() => _silentMode = v),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(loc.t('notify_before')),
              secondary: const Icon(Icons.notifications_active_outlined),
              value: _notifyBefore,
              onChanged: (v) => setState(() => _notifyBefore = v),
            ),
            if (_notifyBefore)
              Padding(
                padding: const EdgeInsets.only(left: 8, top: 4),
                child: Row(
                  children: [
                    Text(loc.t('minutes_before')),
                    Expanded(
                      child: Slider(
                        value: _notifyMinutesBefore.toDouble(),
                        min: 1,
                        max: 30,
                        divisions: 29,
                        label: '$_notifyMinutesBefore',
                        onChanged: (v) =>
                            setState(() => _notifyMinutesBefore = v.round()),
                      ),
                    ),
                    Text('$_notifyMinutesBefore'),
                  ],
                ),
              ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _save,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text(loc.t('save')),
            ),
          ],
        ),
      ),
    );
  }
}
