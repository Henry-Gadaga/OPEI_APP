// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kyc_session_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

KycSessionResponse _$KycSessionResponseFromJson(Map<String, dynamic> json) =>
    KycSessionResponse(
      sessionUrl: json['sessionUrl'] as String,
      status: json['status'] as String,
      workflowId: json['workflowId'] as String,
    );

Map<String, dynamic> _$KycSessionResponseToJson(KycSessionResponse instance) =>
    <String, dynamic>{
      'sessionUrl': instance.sessionUrl,
      'status': instance.status,
      'workflowId': instance.workflowId,
    };
