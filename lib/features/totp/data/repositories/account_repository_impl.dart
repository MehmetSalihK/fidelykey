import 'dart:convert';
import 'package:flutter/foundation.dart'; // For compute
import '../../../../core/services/secure_storage_service.dart';
import '../../domain/entities/totp_account.dart';
import '../../domain/repositories/totp_repository.dart';
import '../models/totp_account_model.dart';

/// Repository gérant la persistance des comptes TOTP.
class AccountRepository implements TotpRepository {
  final SecureStorageService _storageService;

  // Clé unique pour stocker toute la blob de données
  static const String _storageKey = 'fidely_accounts_data';

  AccountRepository(this._storageService);

  @override
  Future<List<TotpAccount>> getAccounts() async {
    try {
      final jsonString = await _storageService.getString(_storageKey);

      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }

      // Run JSON parsing in background isolate
      final accounts = await compute(_parseAccounts, jsonString);
      
      return accounts;
    } catch (e) {
      print('Erreur lors de la récupération des comptes: $e');
      return [];
    }
  }

  // Static function for isolate
  static List<TotpAccount> _parseAccounts(String jsonString) {
      final List<dynamic> jsonList = jsonDecode(jsonString);

      final accounts = jsonList.map((json) {
        final model = TotpAccountModel.fromJson(json as Map<String, dynamic>);
        return TotpAccount(
          id: model.id,
          secretKey: model.secretKey,
          accountName: model.accountName,
          issuer: model.issuer,
          algorithm: model.algorithm,
          digits: model.digits,
          period: model.period,
          sortOrder: model.sortOrder,
        );
      }).toList();

      accounts.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      return accounts;
  }

  @override
  Future<void> saveAccount(TotpAccount account) async {
    try {
      final currentAccounts = await getAccounts();
      final index = currentAccounts.indexWhere((a) => a.id == account.id);

      List<TotpAccount> updatedList;
      if (index != -1) {
        // Update exists
        updatedList = List.from(currentAccounts);
        updatedList[index] = account; // Replace
      } else {
        // Add new
        int newSortOrder = account.sortOrder;
        if (currentAccounts.isNotEmpty) {
           newSortOrder = currentAccounts.last.sortOrder + 1;
        }
        updatedList = [...currentAccounts, account.copyWith(sortOrder: newSortOrder)];
      }

      await saveAllAccounts(updatedList);
    } catch (e) {
      print('Erreur lors de la sauvegarde: $e');
      rethrow;
    }
  }

  @override
  Future<void> saveAllAccounts(List<TotpAccount> accounts) async {
    try {
      // Map to Models
      final models = accounts.map((entity) => TotpAccountModel(
        id: entity.id,
        secretKey: entity.secretKey,
        accountName: entity.accountName,
        issuer: entity.issuer ?? '', // Handle nullable -> required
        algorithm: entity.algorithm,
        digits: entity.digits,
        period: entity.period,
        sortOrder: entity.sortOrder,
        createdAt: DateTime.now(), // Added missing field
      )).toList();

      final jsonString = jsonEncode(models.map((e) => e.toJson()).toList());
      await _storageService.saveString(_storageKey, jsonString);
    } catch (e) {
      print('Erreur lors de la sauvegarde globale: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteAccount(String id) async {
    try {
      final currentAccounts = await getAccounts();
      final updatedList = currentAccounts.where((a) => a.id != id).toList();
      await saveAllAccounts(updatedList);
    } catch (e) {
      print('Erreur lors de la suppression: $e');
      rethrow;
    }
  }
}
