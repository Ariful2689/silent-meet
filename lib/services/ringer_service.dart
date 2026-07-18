import 'package:flutter/services.dart';

/// Business Logic Layer.
/// Dart-side wrapper around the native Android platform channel that
/// actually changes the device's ringer mode. Has no effect on iOS/Web —
/// Apple does not permit any app to change ringer mode programmatically,
/// and browsers have no concept of a device ringer at all.
class RingerService {
  static const _channel = MethodChannel('silent_meet/ringer');

  Future<bool> hasDndAccess() async {
    try {
      final result = await _channel.invokeMethod<bool>('hasDndAccess');
      return result ?? false;
    } on PlatformException {
      return false; // e.g. running on web/iOS where this channel doesn't exist
    } on MissingPluginException {
      return false;
    }
  }

  Future<void> requestDndAccess() async {
    try {
      await _channel.invokeMethod('requestDndAccess');
    } on PlatformException {
      // Ignore — not supported on this platform.
    } on MissingPluginException {
      // Ignore.
    }
  }

  /// mode must be 'silent', 'vibrate', or 'normal'.
  Future<bool> setRingerMode(String mode) async {
    try {
      await _channel.invokeMethod('setRingerMode', {'mode': mode});
      return true;
    } on PlatformException {
      return false; // permission not granted, or platform doesn't support it
    } on MissingPluginException {
      return false;
    }
  }
}
