import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;

/// Business Logic Layer.
/// Provides current time-of-day for arbitrary IANA time zones,
/// used by the World Clock screen.
class TimezoneService {
  bool _initialized = false;

  void ensureInitialized() {
    if (_initialized) return;
    tzdata.initializeTimeZones();
    _initialized = true;
  }

  /// Returns a formatted "HH:mm" string for [ianaName], e.g. 'Asia/Dhaka'.
  String currentTimeIn(String ianaName, {String locale = 'en'}) {
    ensureInitialized();
    final location = tz.getLocation(ianaName);
    final now = tz.TZDateTime.now(location);
    return DateFormat.jm(locale).format(now);
  }

  String cityLabel(String ianaName) {
    final parts = ianaName.split('/');
    return parts.length > 1 ? parts.last.replaceAll('_', ' ') : ianaName;
  }

  /// Common cities offered in the "add city" picker.
  static const availableCities = [
    'Australia/Sydney',
    'Asia/Dhaka',
    'Asia/Kolkata',
    'Asia/Dubai',
    'Asia/Singapore',
    'Asia/Tokyo',
    'Europe/London',
    'Europe/Berlin',
    'America/New_York',
    'America/Los_Angeles',
  ];
}
