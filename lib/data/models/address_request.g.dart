// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'address_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AddressRequest _$AddressRequestFromJson(Map<String, dynamic> json) =>
    AddressRequest(
      country: json['country'] as String,
      state: json['state'] as String,
      city: json['city'] as String,
      zipCode: json['zipCode'] as String,
      addressLine: json['addressLine'] as String,
      houseNumber: json['houseNumber'] as String,
      bvn: json['bvn'] as String?,
    );

Map<String, dynamic> _$AddressRequestToJson(AddressRequest instance) =>
    <String, dynamic>{
      'country': instance.country,
      'state': instance.state,
      'city': instance.city,
      'zipCode': instance.zipCode,
      'addressLine': instance.addressLine,
      'houseNumber': instance.houseNumber,
      'bvn': instance.bvn,
    };
