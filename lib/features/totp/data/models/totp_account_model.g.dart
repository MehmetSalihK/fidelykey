// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'totp_account_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TotpAccountModelImpl _$$TotpAccountModelImplFromJson(
        Map<String, dynamic> json) =>
    _$TotpAccountModelImpl(
      id: json['id'] as String,
      secretKey: json['secret_key'] as String,
      accountName: json['account_name'] as String,
      issuer: json['issuer'] as String,
      algorithm: json['algorithm'] as String? ?? 'SHA1',
      digits: (json['digits'] as num?)?.toInt() ?? 6,
      period: (json['period'] as num?)?.toInt() ?? 30,
      createdAt: DateTime.parse(json['created_at'] as String),
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
      isFavorite: json['isFavorite'] as bool? ?? false,
      usageCount: (json['usageCount'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$TotpAccountModelImplToJson(
        _$TotpAccountModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'secret_key': instance.secretKey,
      'account_name': instance.accountName,
      'issuer': instance.issuer,
      'algorithm': instance.algorithm,
      'digits': instance.digits,
      'period': instance.period,
      'created_at': instance.createdAt.toIso8601String(),
      'sortOrder': instance.sortOrder,
      'isFavorite': instance.isFavorite,
      'usageCount': instance.usageCount,
    };
