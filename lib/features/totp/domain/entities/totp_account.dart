import 'package:freezed_annotation/freezed_annotation.dart';

part 'totp_account.freezed.dart';

@freezed
class TotpAccount with _$TotpAccount {
  const factory TotpAccount({
    required String id,
    required String secretKey,
    required String accountName,
    String? issuer,
    @Default(30) int period,
    @Default(6) int digits,
    @Default('sha1') String algorithm,
    @Default(0) int sortOrder,
    @Default(false) bool isFavorite,
    @Default(0) int usageCount,
  }) = _TotpAccount;
}
