// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transfer_fee_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TransferPreviewRequest _$TransferPreviewRequestFromJson(
        Map<String, dynamic> json) =>
    TransferPreviewRequest(
      toUserId: json['toUserId'] as String,
      amount: (json['amount'] as num).toInt(),
    );

Map<String, dynamic> _$TransferPreviewRequestToJson(
        TransferPreviewRequest instance) =>
    <String, dynamic>{
      'toUserId': instance.toUserId,
      'amount': instance.amount,
    };
