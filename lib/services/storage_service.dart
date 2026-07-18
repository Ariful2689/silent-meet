import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_settings.dart';
import '../models/meeting_schedule.dart';

/// Data Layer.
/// Reads/writes app settings and meeting schedules as JSON, using
/// shared_preferences as the local storage backend. This works safely
/// across Android, iOS, Web, Windows, macOS, and Linux, unlike raw
/// file I/O which is unavailable on Flutter Web.
///
/// No network calls, no third-party analytics, no personal/sensitive data —
/// per the assignment's Security & Privacy requirements.
class StorageService {
  static const _settingsKey = 'silent_meet_settings';
  static const _schedulesKey = 'silent_meet_schedules';

  Future<AppSettings> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_settingsKey);
    if (raw == null || raw.isEmpty) return AppSettings.defaults();
    try {
      return AppSettings.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return AppSettings.defaults();
    }
  }

  Future<void> saveSettings(AppSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_settingsKey, jsonEncode(settings.toJson()));
  }

  Future<List<MeetingSchedule>> loadSchedules() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_schedulesKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list
          .map((e) => MeetingSchedule.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveSchedules(List<MeetingSchedule> schedules) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(schedules.map((s) => s.toJson()).toList());
    await prefs.setString(_schedulesKey, encoded);
  }
}
