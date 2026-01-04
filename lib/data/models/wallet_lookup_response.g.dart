// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet_lookup_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WalletLookupResponse _$WalletLookupResponseFromJson(
        Map<String, dynamic> json) =>
    WalletLookupResponse(
      userId: json['userId'] as String,
      email: json['email'] as String,
      status: json['status'] as String,
      userStage: json['userStage'] as String,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      displayName: json['displayName'] as String?,
    );

Map<String, dynamic> _$WalletLookupResponseToJson(
        WalletLookupResponse instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'email': instance.email,
      'status': instance.status,
      'userStage': instance.userStage,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'displayName': instance.displayName,
    };
