import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ntp/ntp.dart';

final timeServiceProvider = Provider<TimeService>((ref) => TimeService());

class TimeService {
  int _offset = 0; // Offset in milliseconds

  int get offset => _offset;

  /// Synchronizes local time with NTP server.
  /// Should be called on app startup.
  Future<void> syncTime() async {
    try {
      _offset = await NTP.getNtpOffset(localTime: DateTime.now());
      print('NTP Sync: Offset is $_offset ms');
    } catch (e) {
      print('NTP Sync Failed: $e');
      // Fallback to 0 offset (device time)
      _offset = 0;
    }
  }

  /// Returns the corrected current time.
  DateTime now() {
    return DateTime.now().add(Duration(milliseconds: _offset));
  }
}
