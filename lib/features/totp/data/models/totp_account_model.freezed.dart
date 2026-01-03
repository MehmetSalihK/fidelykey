// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'totp_account_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

TotpAccountModel _$TotpAccountModelFromJson(Map<String, dynamic> json) {
  return _TotpAccountModel.fromJson(json);
}

/// @nodoc
mixin _$TotpAccountModel {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'secret_key')
  String get secretKey => throw _privateConstructorUsedError;
  @JsonKey(name: 'account_name')
  String get accountName => throw _privateConstructorUsedError;
  String get issuer => throw _privateConstructorUsedError;
  String get algorithm => throw _privateConstructorUsedError;
  int get digits => throw _privateConstructorUsedError;
  int get period => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;
  int get sortOrder => throw _privateConstructorUsedError;
  bool get isFavorite => throw _privateConstructorUsedError;
  int get usageCount => throw _privateConstructorUsedError;

  /// Serializes this TotpAccountModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TotpAccountModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TotpAccountModelCopyWith<TotpAccountModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TotpAccountModelCopyWith<$Res> {
  factory $TotpAccountModelCopyWith(
          TotpAccountModel value, $Res Function(TotpAccountModel) then) =
      _$TotpAccountModelCopyWithImpl<$Res, TotpAccountModel>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'secret_key') String secretKey,
      @JsonKey(name: 'account_name') String accountName,
      String issuer,
      String algorithm,
      int digits,
      int period,
      @JsonKey(name: 'created_at') DateTime createdAt,
      int sortOrder,
      bool isFavorite,
      int usageCount});
}

/// @nodoc
class _$TotpAccountModelCopyWithImpl<$Res, $Val extends TotpAccountModel>
    implements $TotpAccountModelCopyWith<$Res> {
  _$TotpAccountModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TotpAccountModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? secretKey = null,
    Object? accountName = null,
    Object? issuer = null,
    Object? algorithm = null,
    Object? digits = null,
    Object? period = null,
    Object? createdAt = null,
    Object? sortOrder = null,
    Object? isFavorite = null,
    Object? usageCount = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      secretKey: null == secretKey
          ? _value.secretKey
          : secretKey // ignore: cast_nullable_to_non_nullable
              as String,
      accountName: null == accountName
          ? _value.accountName
          : accountName // ignore: cast_nullable_to_non_nullable
              as String,
      issuer: null == issuer
          ? _value.issuer
          : issuer // ignore: cast_nullable_to_non_nullable
              as String,
      algorithm: null == algorithm
          ? _value.algorithm
          : algorithm // ignore: cast_nullable_to_non_nullable
              as String,
      digits: null == digits
          ? _value.digits
          : digits // ignore: cast_nullable_to_non_nullable
              as int,
      period: null == period
          ? _value.period
          : period // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      sortOrder: null == sortOrder
          ? _value.sortOrder
          : sortOrder // ignore: cast_nullable_to_non_nullable
              as int,
      isFavorite: null == isFavorite
          ? _value.isFavorite
          : isFavorite // ignore: cast_nullable_to_non_nullable
              as bool,
      usageCount: null == usageCount
          ? _value.usageCount
          : usageCount // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TotpAccountModelImplCopyWith<$Res>
    implements $TotpAccountModelCopyWith<$Res> {
  factory _$$TotpAccountModelImplCopyWith(_$TotpAccountModelImpl value,
          $Res Function(_$TotpAccountModelImpl) then) =
      __$$TotpAccountModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'secret_key') String secretKey,
      @JsonKey(name: 'account_name') String accountName,
      String issuer,
      String algorithm,
      int digits,
      int period,
      @JsonKey(name: 'created_at') DateTime createdAt,
      int sortOrder,
      bool isFavorite,
      int usageCount});
}

/// @nodoc
class __$$TotpAccountModelImplCopyWithImpl<$Res>
    extends _$TotpAccountModelCopyWithImpl<$Res, _$TotpAccountModelImpl>
    implements _$$TotpAccountModelImplCopyWith<$Res> {
  __$$TotpAccountModelImplCopyWithImpl(_$TotpAccountModelImpl _value,
      $Res Function(_$TotpAccountModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of TotpAccountModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? secretKey = null,
    Object? accountName = null,
    Object? issuer = null,
    Object? algorithm = null,
    Object? digits = null,
    Object? period = null,
    Object? createdAt = null,
    Object? sortOrder = null,
    Object? isFavorite = null,
    Object? usageCount = null,
  }) {
    return _then(_$TotpAccountModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      secretKey: null == secretKey
          ? _value.secretKey
          : secretKey // ignore: cast_nullable_to_non_nullable
              as String,
      accountName: null == accountName
          ? _value.accountName
          : accountName // ignore: cast_nullable_to_non_nullable
              as String,
      issuer: null == issuer
          ? _value.issuer
          : issuer // ignore: cast_nullable_to_non_nullable
              as String,
      algorithm: null == algorithm
          ? _value.algorithm
          : algorithm // ignore: cast_nullable_to_non_nullable
              as String,
      digits: null == digits
          ? _value.digits
          : digits // ignore: cast_nullable_to_non_nullable
              as int,
      period: null == period
          ? _value.period
          : period // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      sortOrder: null == sortOrder
          ? _value.sortOrder
          : sortOrder // ignore: cast_nullable_to_non_nullable
              as int,
      isFavorite: null == isFavorite
          ? _value.isFavorite
          : isFavorite // ignore: cast_nullable_to_non_nullable
              as bool,
      usageCount: null == usageCount
          ? _value.usageCount
          : usageCount // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TotpAccountModelImpl extends _TotpAccountModel {
  const _$TotpAccountModelImpl(
      {required this.id,
      @JsonKey(name: 'secret_key') required this.secretKey,
      @JsonKey(name: 'account_name') required this.accountName,
      required this.issuer,
      this.algorithm = 'SHA1',
      this.digits = 6,
      this.period = 30,
      @JsonKey(name: 'created_at') required this.createdAt,
      this.sortOrder = 0,
      this.isFavorite = false,
      this.usageCount = 0})
      : super._();

  factory _$TotpAccountModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$TotpAccountModelImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'secret_key')
  final String secretKey;
  @override
  @JsonKey(name: 'account_name')
  final String accountName;
  @override
  final String issuer;
  @override
  @JsonKey()
  final String algorithm;
  @override
  @JsonKey()
  final int digits;
  @override
  @JsonKey()
  final int period;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @override
  @JsonKey()
  final int sortOrder;
  @override
  @JsonKey()
  final bool isFavorite;
  @override
  @JsonKey()
  final int usageCount;

  @override
  String toString() {
    return 'TotpAccountModel(id: $id, secretKey: $secretKey, accountName: $accountName, issuer: $issuer, algorithm: $algorithm, digits: $digits, period: $period, createdAt: $createdAt, sortOrder: $sortOrder, isFavorite: $isFavorite, usageCount: $usageCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TotpAccountModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.secretKey, secretKey) ||
                other.secretKey == secretKey) &&
            (identical(other.accountName, accountName) ||
                other.accountName == accountName) &&
            (identical(other.issuer, issuer) || other.issuer == issuer) &&
            (identical(other.algorithm, algorithm) ||
                other.algorithm == algorithm) &&
            (identical(other.digits, digits) || other.digits == digits) &&
            (identical(other.period, period) || other.period == period) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.sortOrder, sortOrder) ||
                other.sortOrder == sortOrder) &&
            (identical(other.isFavorite, isFavorite) ||
                other.isFavorite == isFavorite) &&
            (identical(other.usageCount, usageCount) ||
                other.usageCount == usageCount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      secretKey,
      accountName,
      issuer,
      algorithm,
      digits,
      period,
      createdAt,
      sortOrder,
      isFavorite,
      usageCount);

  /// Create a copy of TotpAccountModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TotpAccountModelImplCopyWith<_$TotpAccountModelImpl> get copyWith =>
      __$$TotpAccountModelImplCopyWithImpl<_$TotpAccountModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TotpAccountModelImplToJson(
      this,
    );
  }
}

abstract class _TotpAccountModel extends TotpAccountModel {
  const factory _TotpAccountModel(
      {required final String id,
      @JsonKey(name: 'secret_key') required final String secretKey,
      @JsonKey(name: 'account_name') required final String accountName,
      required final String issuer,
      final String algorithm,
      final int digits,
      final int period,
      @JsonKey(name: 'created_at') required final DateTime createdAt,
      final int sortOrder,
      final bool isFavorite,
      final int usageCount}) = _$TotpAccountModelImpl;
  const _TotpAccountModel._() : super._();

  factory _TotpAccountModel.fromJson(Map<String, dynamic> json) =
      _$TotpAccountModelImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'secret_key')
  String get secretKey;
  @override
  @JsonKey(name: 'account_name')
  String get accountName;
  @override
  String get issuer;
  @override
  String get algorithm;
  @override
  int get digits;
  @override
  int get period;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  int get sortOrder;
  @override
  bool get isFavorite;
  @override
  int get usageCount;

  /// Create a copy of TotpAccountModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TotpAccountModelImplCopyWith<_$TotpAccountModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
