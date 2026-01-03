import '../entities/totp_account.dart';
import '../repositories/totp_repository.dart';

class SaveTotpAccount {
  final TotpRepository _repository;

  SaveTotpAccount(this._repository);

  Future<void> call(TotpAccount account) {
    return _repository.saveAccount(account);
  }
}
