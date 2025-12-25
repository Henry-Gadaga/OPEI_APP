// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transfer_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TransferRequest _$TransferRequestFromJson(Map<String, dynamic> json) => TransferRequest(
      toUserId: json['toUserId'] as String,
      amount: (json['amount'] as num).toInt(),
      description: json['description'] as String?,
    );

Map<String, dynamic> _$TransferRequestToJson(TransferRequest instance) =>
    <String, dynamic>{
      'toUserId': instance.toUserId,
      'amount': instance.amount,
      'description': instance.description,
    };
