import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/totp_account.dart';

part 'totp_account_model.freezed.dart';
part 'totp_account_model.g.dart';

// In Clean Architecture with Freezed, the Model often merges with the Entity 
// or simpler, the Entity IS the Freezed class and we add fromJson/toJson to it.
// However, strictly, the Model handles JSON serialization while the Entity represents domain logic.
// With Freezed, it's common to have one class handle both if they are identical 1:1.
// 
// If strict separation is needed:
// One approach: The Entity is a plain Dart class or Equatable. The Model extends it or maps to it.
// 
// Given the user asked for "code-moi le modèle... with fromJson, toJson", 
// and requested "id (uuid), factory for creation", I will implement it as a robust Freezed class 
// that can serve as the Data Model. Ideally, in pure Clean Arch, this `TotpAccountModel` 
// would extend `TotpAccount` (if `TotpAccount` was a plain class) or implementing it.
// 
// But since I made `TotpAccount` a Freezed class in the entity file (best practice for immutable domain objects in Flutter),
// I will make `TotpAccountModel` a subclass or wrapper, Or simpler:
// I will implement `TotpAccountModel` as a separate Freezed class that *implements* the TotpAccount interface-like contract 
// (though Freezed classes are sealed).
// 
// ACTUALLY, the most pragmatic "Clean Arch" in Flutter with Freezed is often:
// - Domain: `TotpAccount` (Freezed, no fromJson/toJson to avoid infrastructure dependency in Domain)
// - Data: `TotpAccountModel` (extends TotpAccount or maps to it, has fromJson/toJson).
// 
// However, since Freezed classes are final/sealed, you can't easily extend them.
// Pattern A: `TotpAccount` is the single source of truth, annotated with `@JsonSerializable` but put in Data? No, Domain shouldn't know JSON.
// Pattern B: `TotpAccount` is a plain class. `TotpAccountModel` extends it and adds `fromJson`.
// Pattern C: `TotpAccount` is a typedef or protocol.
// 
// Let's go with Pattern B (Plain Entity, Freezed Model) or Pattern D (DTO mapping).
// 
// Re-reading User Request: "Code-moi le modèle de données principal totp_account_model.dart... Inclure les méthodes : fromJson, toJson, et une factory pour la création."
// 
// I will make `TotpAccountModel` fully self-contained with the JSON logic.
// If I change the Entity to be a plain class, I can let Model extend it.
// But the user asked for "Coding the model", so I will focus on making `TotpAccountModel` perfect.
// I will rewrite `TotpAccount` (Entity) to be a plain class to allow `TotpAccountModel` to extend it, 
// which is the most correct "Strict Clean Architecture" way if we want to separate layers.
// 
// Wait, if I use Freezed for the Entity (as done in previous step), I can't extend it.
// I'll stick to the previous file being the Domain Entity.
// Now I'll create the Model. The Model will hold the JSON logic and `toDomain` / `fromDomain` mappers, 
// OR simpler: just replicate the fields and add the JSON logic, ensuring a conversion method exists.
// 
// Let's stick to the prompt's request: "Code-moi le modèle...". 
// I'll use Freezed for the Model too, as requested ("Code Generation si possible").

@freezed
class TotpAccountModel with _$TotpAccountModel {
  const TotpAccountModel._(); // Allow adding methods

  const factory TotpAccountModel({
    required String id,
    @JsonKey(name: 'secret_key') required String secretKey,
    @JsonKey(name: 'account_name') required String accountName,
    required String issuer,
    @Default('SHA1') String algorithm,
    @Default(6) int digits,
    @Default(30) int period,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @Default(0) int sortOrder,
    @Default(false) bool isFavorite,
    @Default(0) int usageCount,
  }) = _TotpAccountModel;

  factory TotpAccountModel.fromJson(Map<String, dynamic> json) => 
      _$TotpAccountModelFromJson(json);

  // Factory for creation with auto-generated UUID and Date
  factory TotpAccountModel.create({
    required String secretKey,
    required String accountName,
    required String issuer,
    String algorithm = 'SHA1',
    int digits = 6,
    int period = 30,
  }) {
    return TotpAccountModel(
      id: const Uuid().v4(),
      secretKey: secretKey,
      accountName: accountName,
      issuer: issuer,
      algorithm: algorithm,
      digits: digits,
      period: period,
      createdAt: DateTime.now(),
    );
  }

  // Mapper to Domain Entity (assuming the Entity is `TotpAccount`)
  // Note: We need to import the entity.
  // TotpAccount toEntity() {
  //   return TotpAccount(id: id, ...);
  // }
  // leaving this commented as the file structure implies referencing the entity directly.
}
