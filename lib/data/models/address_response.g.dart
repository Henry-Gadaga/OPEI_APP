// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'address_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AddressResponse _$AddressResponseFromJson(Map<String, dynamic> json) =>
    AddressResponse(
      country: json['country'] as String,
      state: json['state'] as String?,
      city: json['city'] as String,
      zipCode: json['zipCode'] as String?,
      addressLine: json['addressLine'] as String,
      houseNumber: json['houseNumber'] as String,
      bvn: json['bvn'] as String?,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );

Map<String, dynamic> _$AddressResponseToJson(AddressResponse instance) =>
    <String, dynamic>{
      'country': instance.country,
      'state': instance.state,
      'city': instance.city,
      'zipCode': instance.zipCode,
      'addressLine': instance.addressLine,
      'houseNumber': instance.houseNumber,
      'bvn': instance.bvn,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
    };
