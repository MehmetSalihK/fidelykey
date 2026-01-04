import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';

// Services
import 'encryption_service.dart';
import '../../features/totp/domain/entities/totp_account.dart';
import '../../features/totp/data/repositories/totp_repository.dart'; // To save/read local data
import 'audit_service.dart';

final cloudServiceProvider = Provider((ref) => CloudService(ref));

class CloudService {
  final Ref _ref;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CloudService(this._ref);

  Future<User> _getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("User not logged in");
    return user;
  }

  DocumentReference _getVaultRef(String uid) {
    return _firestore.collection('users').doc(uid).collection('vault').doc('main');
  }

  /// Push current local data to Cloud (Encrypted)
  Future<void> pushToCloud(String password) async {
    final user = await _getCurrentUser();
    
    // 1. Get Local Data
    // Assuming we have a provider or repo to get all accounts
    // For now, let's assume we can fetch them via the repository.
    // NOTE: This usually requires the repository to be exposed.
    // Let's assume we fetch the list from the TotpRepository.
    
    // Note: We need a way to get *all* accounts.
    // Let's assume the repository has a method `getAllAccounts()`.
    // If not, we might need to rely on the current state of a provider.
    final accounts = await _ref.read(totpRepositoryProvider).getAccounts();
    
    if (accounts.isEmpty) return; // Nothing to sync? Or should we sync empty?

    // 2. Serialize
    final jsonList = accounts.map((a) => a.toJson()).toList();
    final jsonPayload = jsonEncode(jsonList);

    // 3. Encrypt
    final encryptedBlob = EncryptionService.encryptPayload(jsonPayload, password);

    // 4. Upload
    final deviceName = kIsWeb ? 'Web' : defaultTargetPlatform.name;
    
    await _getVaultRef(user.uid).set({
      'data': encryptedBlob,
      'updatedAt': FieldValue.serverTimestamp(),
      'deviceName': deviceName,
      'version': 1,
    });
    
    _ref.read(auditServiceProvider).log('CLOUD', 'Data Pushed to Cloud');
  }

  /// Pull data from Cloud, Decrypt, and Merge
  Future<void> pullFromCloud(String password) async {
    final user = await _getCurrentUser();
    final doc = await _getVaultRef(user.uid).get();

    if (!doc.exists) return;

    final data = doc.data() as Map<String, dynamic>;
    final encryptedBlob = data['data'] as String;
    // timestamp handling if needed for conflict resolution (server wins here for simplicity of "Pull")

    // 1. Decrypt
    final jsonPayload = EncryptionService.decryptPayload(encryptedBlob, password);

    // 2. Deserialize
    final List<dynamic> decoded = jsonDecode(jsonPayload);
    final cloudAccounts = decoded.map((e) => TotpAccount.fromJson(e)).toList();

    // 3. Merge Strategy
    // Simple Strategy for now:
    // - If account ID exists locally, update it if cloud is "newer" (but we don't track update time per account yet).
    // - Or simpliest: Union by Secret/Issuer? ID is safest if UUID.
    // - Let's do a smart UUID merge.
    
    final repo = _ref.read(totpRepositoryProvider);
    final localAccounts = await repo.getAccounts();
    
    int added = 0;
    int updated = 0;

    for (var cloudAcc in cloudAccounts) {
      final localIndex = localAccounts.indexWhere((l) => l.id == cloudAcc.id);
      
      if (localIndex == -1) {
        // New Account
        await repo.addAccount(cloudAcc);
        added++;
      } else {
        // Exists. Overwrite? 
        // Ideally we check a 'lastModified' field.
        // For this task, let's assume Cloud is Source of Truth when explicitly pulling.
        // Or we could check if they are identical to avoid write.
        if (localAccounts[localIndex] != cloudAcc) {
           await repo.updateAccount(cloudAcc);
           updated++;
        }
      }
    }
    
    // What about deletions? 
    // Secure sync typically doesn't auto-delete unless we track "tombstones".
    // We will ADD/UPDATE only for safety (Union).

    _ref.read(auditServiceProvider).log('CLOUD', 'Sync Complete: +$added new, ^$updated updated');
  }
}
