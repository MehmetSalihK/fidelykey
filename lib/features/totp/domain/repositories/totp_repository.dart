import '../entities/totp_account.dart';

abstract class TotpRepository {
  Future<List<TotpAccount>> getAccounts();
  Future<void> saveAccount(TotpAccount account);
  Future<void> saveAllAccounts(List<TotpAccount> accounts); // New for reordering
  Future<void> deleteAccount(String id);
}
