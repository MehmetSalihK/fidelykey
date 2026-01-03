// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'totp_account.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$TotpAccount {
  String get id => throw _privateConstructorUsedError;
  String get secretKey => throw _privateConstructorUsedError;
  String get accountName => throw _privateConstructorUsedError;
  String? get issuer => throw _privateConstructorUsedError;
  int get period => throw _privateConstructorUsedError;
  int get digits => throw _privateConstructorUsedError;
  String get algorithm => throw _privateConstructorUsedError;
  int get sortOrder => throw _privateConstructorUsedError;
  bool get isFavorite => throw _privateConstructorUsedError;
  int get usageCount => throw _privateConstructorUsedError;

  /// Create a copy of TotpAccount
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TotpAccountCopyWith<TotpAccount> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TotpAccountCopyWith<$Res> {
  factory $TotpAccountCopyWith(
          TotpAccount value, $Res Function(TotpAccount) then) =
      _$TotpAccountCopyWithImpl<$Res, TotpAccount>;
  @useResult
  $Res call(
      {String id,
      String secretKey,
      String accountName,
      String? issuer,
      int period,
      int digits,
      String algorithm,
      int sortOrder,
      bool isFavorite,
      int usageCount});
}

/// @nodoc
class _$TotpAccountCopyWithImpl<$Res, $Val extends TotpAccount>
    implements $TotpAccountCopyWith<$Res> {
  _$TotpAccountCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TotpAccount
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? secretKey = null,
    Object? accountName = null,
    Object? issuer = freezed,
    Object? period = null,
    Object? digits = null,
    Object? algorithm = null,
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
      issuer: freezed == issuer
          ? _value.issuer
          : issuer // ignore: cast_nullable_to_non_nullable
              as String?,
      period: null == period
          ? _value.period
          : period // ignore: cast_nullable_to_non_nullable
              as int,
      digits: null == digits
          ? _value.digits
          : digits // ignore: cast_nullable_to_non_nullable
              as int,
      algorithm: null == algorithm
          ? _value.algorithm
          : algorithm // ignore: cast_nullable_to_non_nullable
              as String,
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
abstract class _$$TotpAccountImplCopyWith<$Res>
    implements $TotpAccountCopyWith<$Res> {
  factory _$$TotpAccountImplCopyWith(
          _$TotpAccountImpl value, $Res Function(_$TotpAccountImpl) then) =
      __$$TotpAccountImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String secretKey,
      String accountName,
      String? issuer,
      int period,
      int digits,
      String algorithm,
      int sortOrder,
      bool isFavorite,
      int usageCount});
}

/// @nodoc
class __$$TotpAccountImplCopyWithImpl<$Res>
    extends _$TotpAccountCopyWithImpl<$Res, _$TotpAccountImpl>
    implements _$$TotpAccountImplCopyWith<$Res> {
  __$$TotpAccountImplCopyWithImpl(
      _$TotpAccountImpl _value, $Res Function(_$TotpAccountImpl) _then)
      : super(_value, _then);

  /// Create a copy of TotpAccount
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? secretKey = null,
    Object? accountName = null,
    Object? issuer = freezed,
    Object? period = null,
    Object? digits = null,
    Object? algorithm = null,
    Object? sortOrder = null,
    Object? isFavorite = null,
    Object? usageCount = null,
  }) {
    return _then(_$TotpAccountImpl(
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
      issuer: freezed == issuer
          ? _value.issuer
          : issuer // ignore: cast_nullable_to_non_nullable
              as String?,
      period: null == period
          ? _value.period
          : period // ignore: cast_nullable_to_non_nullable
              as int,
      digits: null == digits
          ? _value.digits
          : digits // ignore: cast_nullable_to_non_nullable
              as int,
      algorithm: null == algorithm
          ? _value.algorithm
          : algorithm // ignore: cast_nullable_to_non_nullable
              as String,
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

class _$TotpAccountImpl implements _TotpAccount {
  const _$TotpAccountImpl(
      {required this.id,
      required this.secretKey,
      required this.accountName,
      this.issuer,
      this.period = 30,
      this.digits = 6,
      this.algorithm = 'sha1',
      this.sortOrder = 0,
      this.isFavorite = false,
      this.usageCount = 0});

  @override
  final String id;
  @override
  final String secretKey;
  @override
  final String accountName;
  @override
  final String? issuer;
  @override
  @JsonKey()
  final int period;
  @override
  @JsonKey()
  final int digits;
  @override
  @JsonKey()
  final String algorithm;
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
    return 'TotpAccount(id: $id, secretKey: $secretKey, accountName: $accountName, issuer: $issuer, period: $period, digits: $digits, algorithm: $algorithm, sortOrder: $sortOrder, isFavorite: $isFavorite, usageCount: $usageCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TotpAccountImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.secretKey, secretKey) ||
                other.secretKey == secretKey) &&
            (identical(other.accountName, accountName) ||
                other.accountName == accountName) &&
            (identical(other.issuer, issuer) || other.issuer == issuer) &&
            (identical(other.period, period) || other.period == period) &&
            (identical(other.digits, digits) || other.digits == digits) &&
            (identical(other.algorithm, algorithm) ||
                other.algorithm == algorithm) &&
            (identical(other.sortOrder, sortOrder) ||
                other.sortOrder == sortOrder) &&
            (identical(other.isFavorite, isFavorite) ||
                other.isFavorite == isFavorite) &&
            (identical(other.usageCount, usageCount) ||
                other.usageCount == usageCount));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, secretKey, accountName,
      issuer, period, digits, algorithm, sortOrder, isFavorite, usageCount);

  /// Create a copy of TotpAccount
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TotpAccountImplCopyWith<_$TotpAccountImpl> get copyWith =>
      __$$TotpAccountImplCopyWithImpl<_$TotpAccountImpl>(this, _$identity);
}

abstract class _TotpAccount implements TotpAccount {
  const factory _TotpAccount(
      {required final String id,
      required final String secretKey,
      required final String accountName,
      final String? issuer,
      final int period,
      final int digits,
      final String algorithm,
      final int sortOrder,
      final bool isFavorite,
      final int usageCount}) = _$TotpAccountImpl;

  @override
  String get id;
  @override
  String get secretKey;
  @override
  String get accountName;
  @override
  String? get issuer;
  @override
  int get period;
  @override
  int get digits;
  @override
  String get algorithm;
  @override
  int get sortOrder;
  @override
  bool get isFavorite;
  @override
  int get usageCount;

  /// Create a copy of TotpAccount
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TotpAccountImplCopyWith<_$TotpAccountImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
