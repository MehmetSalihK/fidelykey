import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../../features/totp/presentation/providers/totp_providers.dart';
import 'secure_storage_service.dart';

// Provider definition
final pinServiceProvider = Provider<PinService>((ref) {
  final secureStorage = ref.watch(secureStorageServiceProvider);
  return PinService(secureStorage);
});

enum PinStatus { success, failure, duress }

class PinService {
  final SecureStorageService _storage;
  
  // Using the keys defined in SettingsScreen for consistency
  static const _pinHashKey = 'user_pin_hash';
  static const _duressHashKey = 'duress_pin_hash';
  
  static const _attemptsKey = 'pin_failed_attempts';
  static const _lockoutKey = 'pin_lockout_end';

  PinService(this._storage);

  Future<bool> hasPin() async {
    final pin = await _storage.getString(_pinHashKey);
    return pin != null && pin.isNotEmpty;
  }

  Future<PinStatus> verifyPin(String inputPinRaw) async {
    // 1. Check Lockout
    final lockoutEndStr = await _storage.getString(_lockoutKey);
    if (lockoutEndStr != null) {
      final lockoutEnd = DateTime.parse(lockoutEndStr);
      if (DateTime.now().isBefore(lockoutEnd)) {
        throw PinLockoutException(lockoutEnd);
      } else {
        await _storage.deleteString(_lockoutKey);
        await _storage.deleteString(_attemptsKey);
      }
    }

    // 2. Hash Input
    final bytes = utf8.encode(inputPinRaw);
    final inputHash = sha256.convert(bytes).toString();

    // 3. Compare with Stored PIN
    final storedPinHash = await _storage.getString(_pinHashKey);
    
    if (storedPinHash == inputHash) {
      _resetCounters();
      return PinStatus.success;
    }

    // 4. Compare with Duress PIN
    final duressHash = await _storage.getString(_duressHashKey);
    if (duressHash != null && duressHash == inputHash) {
       _resetCounters();
       return PinStatus.duress;
    }

    // 5. Failure Handling
    int attempts = int.tryParse(await _storage.getString(_attemptsKey) ?? '0') ?? 0;
    attempts++;
    await _storage.saveString(_attemptsKey, attempts.toString());

    if (attempts >= 5) {
      final lockoutEnd = DateTime.now().add(const Duration(minutes: 5));
      await _storage.saveString(_lockoutKey, lockoutEnd.toIso8601String());
      throw PinLockoutException(lockoutEnd);
    } else if (attempts >= 3) {
      final lockoutEnd = DateTime.now().add(const Duration(seconds: 30));
      await _storage.saveString(_lockoutKey, lockoutEnd.toIso8601String());
      throw PinLockoutException(lockoutEnd);
    }

    return PinStatus.failure;
  }

  Future<void> _resetCounters() async {
    await _storage.deleteString(_attemptsKey);
    await _storage.deleteString(_lockoutKey);
  }

  /// Note: Saving is primarily handled in SettingsScreen which creates the hash.
  /// But we keep removePin for Logout.
  Future<void> removePin() async {
    await _storage.deleteString(_pinHashKey);
    await _storage.deleteString(_duressHashKey);
    await _storage.deleteString(_attemptsKey);
    await _storage.deleteString(_lockoutKey);
  }

  Future<void> savePin(String pin) async {
    final bytes = utf8.encode(pin);
    final hash = sha256.convert(bytes).toString();
    await _storage.saveString(_pinHashKey, hash);
  }
}
class PinLockoutException implements Exception {
  final DateTime lockoutEnd;
  PinLockoutException(this.lockoutEnd);
  
  int get remainingSeconds => lockoutEnd.difference(DateTime.now()).inSeconds;
}
