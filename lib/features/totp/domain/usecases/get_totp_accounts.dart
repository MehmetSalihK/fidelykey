import '../entities/totp_account.dart';
import '../repositories/totp_repository.dart';

class GetTotpAccounts {
  final TotpRepository _repository;

  GetTotpAccounts(this._repository);

  Future<List<TotpAccount>> call() {
    return _repository.getAccounts();
  }
}
