/// Data Layer model.
/// Represents a single recurring "silent hours" meeting window.
/// Kept intentionally free of any personal/identifying data —
/// per the assignment's privacy requirement (no sensitive info stored locally).
class MeetingSchedule {
  final String id;
  final String title;
  final int startHour; // 0-23, local device time
  final int startMinute;
  final int endHour;
  final int endMinute;
  final List<int> weekdays; // 1 = Monday ... 7 = Sunday
  final bool silentMode; // true = silent, false = vibrate
  final bool notifyBefore;
  final int notifyMinutesBefore;

  MeetingSchedule({
    required this.id,
    required this.title,
    required this.startHour,
    required this.startMinute,
    required this.endHour,
    required this.endMinute,
    required this.weekdays,
    this.silentMode = true,
    this.notifyBefore = true,
    this.notifyMinutesBefore = 5,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'startHour': startHour,
        'startMinute': startMinute,
        'endHour': endHour,
        'endMinute': endMinute,
        'weekdays': weekdays,
        'silentMode': silentMode,
        'notifyBefore': notifyBefore,
        'notifyMinutesBefore': notifyMinutesBefore,
      };

  factory MeetingSchedule.fromJson(Map<String, dynamic> json) {
    return MeetingSchedule(
      id: json['id'] as String,
      title: json['title'] as String,
      startHour: json['startHour'] as int,
      startMinute: json['startMinute'] as int,
      endHour: json['endHour'] as int,
      endMinute: json['endMinute'] as int,
      weekdays: List<int>.from(json['weekdays'] as List),
      silentMode: json['silentMode'] as bool? ?? true,
      notifyBefore: json['notifyBefore'] as bool? ?? true,
      notifyMinutesBefore: json['notifyMinutesBefore'] as int? ?? 5,
    );
  }
}
