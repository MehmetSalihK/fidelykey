import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'secure_storage_service.dart';
import '../../features/totp/presentation/providers/totp_providers.dart';

class AuditLog {
  final DateTime timestamp;
  final String type; // e.g., 'AUTH', 'ACCOUNT', 'SECURITY'
  final String description;

  AuditLog({required this.timestamp, required this.type, required this.description});

  Map<String, dynamic> toJson() => {
    'timestamp': timestamp.toIso8601String(),
    'type': type,
    'description': description,
  };

  factory AuditLog.fromJson(Map<String, dynamic> json) => AuditLog(
    timestamp: DateTime.parse(json['timestamp']),
    type: json['type'],
    description: json['description'],
  );
}

class AuditService {
  final SecureStorageService _storage;
  static const String _storageKey = 'audit_logs';

  AuditService(this._storage);

  Future<void> log(String type, String description) async {
    final logs = await getLogs();
    
    // Add new log
    logs.insert(0, AuditLog(
      timestamp: DateTime.now(),
      type: type,
      description: description,
    ));

    // Keep only last 50
    if (logs.length > 50) {
      logs.removeRange(50, logs.length);
    }

    // Save
    final jsonString = jsonEncode(logs.map((e) => e.toJson()).toList());
    await _storage.saveString(_storageKey, jsonString);
  }

  Future<List<AuditLog>> getLogs() async {
    final jsonString = await _storage.getString(_storageKey);
    if (jsonString == null || jsonString.isEmpty) return [];

    try {
      final List<dynamic> list = jsonDecode(jsonString);
      return list.map((e) => AuditLog.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> clearLogs() async {
    await _storage.saveString(_storageKey, '');
  }
}

final auditServiceProvider = Provider((ref) {
  return AuditService(ref.watch(secureStorageServiceProvider));
});
