import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/totp_account.dart';
import '../../domain/usecases/get_totp_accounts.dart';
import '../../domain/usecases/save_totp_account.dart';
import '../../domain/usecases/delete_totp_account.dart';
import '../../data/repositories/account_repository_impl.dart';
import '../../../../core/services/secure_storage_service.dart';
import '../../../../core/services/totp_service.dart';
import '../../../../core/services/home_widget_service.dart';
import '../../../../core/services/audit_service.dart';
import '../../../../core/services/time_service.dart';
import '../../domain/repositories/totp_repository.dart';

part 'totp_providers.g.dart';

// --- 1. Injection de Dépendance (DI) ---

@riverpod
SecureStorageService secureStorageService(SecureStorageServiceRef ref) {
  return SecureStorageService();
}

@riverpod
TotpService totpService(TotpServiceRef ref) {
  return TotpService();
}

@riverpod
TotpRepository totpRepository(TotpRepositoryRef ref) {
  return AccountRepository(ref.watch(secureStorageServiceProvider));
}

// --- 2. Accounts Provider (Logiciel Maitre) ---

// DURESS MODE PROVIDER
@riverpod
class DuressMode extends _$DuressMode {
  @override
  bool build() => false;

  void activate() => state = true;
  void deactivate() => state = false;
}

@riverpod
class Accounts extends _$Accounts {
  @override
  Future<List<TotpAccount>> build() async {
    // INITIALIZE SERVICES
    // Fire and forget time sync
    ref.read(timeServiceProvider).syncTime();

    // DURESS CHECK
    final isDuress = ref.watch(duressModeProvider);
    if (isDuress) return []; // Return empty if under duress

    final repository = ref.read(totpRepositoryProvider);
    return repository.getAccounts();
  }

  /// Ajoute un nouveau compte
  Future<void> addAccount({
    required String secret,
    required String name,
    required String issuer,
    String algorithm = 'SHA1',
    int digits = 6,
    int period = 30,
    String category = 'Général',
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(totpRepositoryProvider);
      
      final newAccount = TotpAccount(
        id: const Uuid().v4(),
        secretKey: secret,
        accountName: name,
        issuer: issuer,
        algorithm: algorithm,
        digits: digits,
        period: period,
        category: category,
        // sortOrder will be handled by repository (appending)
      );

      await repository.saveAccount(newAccount);
      _syncWidgets(await repository.getAccounts());
      
      // LOG
      ref.read(auditServiceProvider).log('ACCOUNT', 'Ajout du compte: $name');

      return repository.getAccounts();
    });
  }

  Future<void> saveAccount(TotpAccount account) async {
    // Optimistic update
    final currentList = state.valueOrNull;
    if (currentList != null) {
      final index = currentList.indexWhere((a) => a.id == account.id);
      if (index != -1) {
         final updatedList = List<TotpAccount>.from(currentList);
         updatedList[index] = account;
         state = AsyncValue.data(updatedList);
      }
    }

    final repository = ref.read(totpRepositoryProvider);
    await repository.saveAccount(account);
    _syncWidgets(await repository.getAccounts());
  }

  /// Met à jour les infos d'un compte
  Future<void> updateAccount({
    required String id,
    required String newName,
    required String newIssuer,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(totpRepositoryProvider);
      
      final accounts = await repository.getAccounts();
      final accountToUpdate = accounts.firstWhere((a) => a.id == id);

      final updatedAccount = accountToUpdate.copyWith(
        accountName: newName,
        issuer: newIssuer,
      );

      await repository.saveAccount(updatedAccount);
      _syncWidgets(await repository.getAccounts());
      
      // LOG
      ref.read(auditServiceProvider).log('ACCOUNT', 'Modification du compte: $newName');

      return repository.getAccounts();
    });
  }

  Future<void> deleteAccount(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(totpRepositoryProvider);
      await repository.deleteAccount(id);
      _syncWidgets(await repository.getAccounts());
      
      // LOG
      ref.read(auditServiceProvider).log('ACCOUNT', 'Suppression d\'un compte (ID: ${id.substring(0,4)}...)');

      return repository.getAccounts();
    });
  }

  Future<void> incrementUsage(String id) async {
    final currentList = state.valueOrNull;
    if (currentList == null) return;

    final index = currentList.indexWhere((a) => a.id == id);
    if (index == -1) return;

    final account = currentList[index];
    final updatedAccount = account.copyWith(usageCount: account.usageCount + 1);
    
    // Update local state optimizing for speed
    // const sorting is handled by filteredAccounts, so we just update the item
    // However, since we use Freezed, we need to replace it in the list
    final updatedList = List<TotpAccount>.from(currentList);
    updatedList[index] = updatedAccount;
    
    state = AsyncValue.data(updatedList);

    // Save to repo silently (fire and forget or await?)
    // Creating a fire-and-forget style for responsiveness, but Riverpod guard requires await usually.
    // We'll just await it to be safe.
    final repository = ref.read(totpRepositoryProvider);
    await repository.saveAccount(updatedAccount);
    
    // We might not need to sync widgets for just usage count unless we show it.
  }

  /// Réorganise les comptes (Drag & Drop)
  Future<void> reorderAccounts(int oldIndex, int newIndex) async {
    final currentList = state.valueOrNull;
    if (currentList == null) return;

    final items = List<TotpAccount>.from(currentList);
    
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = items.removeAt(oldIndex);
    items.insert(newIndex, item);

    // Update sortOrder for all
    final updatedItems = items.asMap().entries.map((e) {
      return e.value.copyWith(sortOrder: e.key);
    }).toList();

    // Optimistically update state
    state = AsyncValue.data(updatedItems);

    // Save to repo
    final repository = ref.read(totpRepositoryProvider);
    await repository.saveAllAccounts(updatedItems);
    _syncWidgets(updatedItems);
  }

  void _syncWidgets(List<TotpAccount> accounts) {
    HomeWidgetService().updateWidgetData(accounts);
  }
}

// --- SEARCH & FILTER PROVIDERS ---

@riverpod
class SearchQuery extends _$SearchQuery {
  @override
  String build() => '';

  void set(String query) => state = query;
}

@riverpod
class SelectedCategory extends _$SelectedCategory {
  @override
  String build() => 'Tous';

  void set(String category) => state = category;
}

@riverpod
List<TotpAccount> filteredAccounts(FilteredAccountsRef ref) {
  final accountsAsync = ref.watch(accountsProvider);
  final query = ref.watch(searchQueryProvider).toLowerCase().trim();
  final category = ref.watch(selectedCategoryProvider);

  return accountsAsync.maybeWhen(
    data: (accounts) {
      // 1. Filter
      var filtered = accounts;
      
      // Filter by Category
      if (category != 'Tous') {
        filtered = filtered.where((a) => a.category == category).toList();
      }

      // Filter by Search Query
      if (query.isNotEmpty) {
        filtered = filtered.where((a) {
          final name = a.accountName.toLowerCase();
          final issuer = (a.issuer ?? '').toLowerCase();
          return name.contains(query) || issuer.contains(query);
        }).toList();
      }

      // 2. Sort: Favorites first, then Usage Count (Desc), then Name
      final sorted = List<TotpAccount>.from(filtered)..sort((a, b) {
        // Priority 1: Favorites
        if (a.isFavorite && !b.isFavorite) return -1;
        if (!a.isFavorite && b.isFavorite) return 1;
        
        // Priority 2: Usage Count (Higher is better)
        if (a.usageCount != b.usageCount) {
          return b.usageCount.compareTo(a.usageCount);
        }
        
        // Priority 3: Name
        return a.accountName.toLowerCase().compareTo(b.accountName.toLowerCase());
      });

      return sorted;
    },
    orElse: () => [],
  );
}

// --- 3. TOTP Timer Provider (Synchronisation Globale) ---

@riverpod
Stream<int> totpTimer(TotpTimerRef ref) {
  return Stream.periodic(const Duration(milliseconds: 500), (_) {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return 30 - (now % 30);
  }).distinct();
}

@riverpod
Stream<double> totpProgress(TotpProgressRef ref) {
  return Stream.periodic(const Duration(milliseconds: 100), (_) {
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    final periodMs = 30000;
    final remainder = nowMs % periodMs;
    return 1.0 - (remainder / periodMs);
  }).distinct();
}

// --- 4. TOTP Code Provider (Generation Réactive) ---

@riverpod
String totpCode(TotpCodeRef ref, TotpAccount account) {
  ref.watch(totpTimerProvider);
  final service = ref.watch(totpServiceProvider);
  final timeService = ref.watch(timeServiceProvider);
  
  return service.generateCode(
    account.secretKey,
    interval: account.period,
    digits: account.digits,
    algorithm: account.algorithm,
    now: timeService.now(),
  );
}
