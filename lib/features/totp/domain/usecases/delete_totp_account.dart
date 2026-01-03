import '../repositories/totp_repository.dart';

class DeleteTotpAccount {
  final TotpRepository _repository;

  DeleteTotpAccount(this._repository);

  Future<void> call(String id) {
    return _repository.deleteAccount(id);
  }
}
