// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'full_profile_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IdentityData _$IdentityDataFromJson(Map<String, dynamic> json) => IdentityData(
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      dateOfBirth: DateTime.parse(json['dateOfBirth'] as String),
      gender: json['gender'] as String,
      nationality: json['nationality'] as String,
      idType: json['idType'] as String,
      idNumber: json['idNumber'] as String,
      selfieUrl: json['selfieUrl'] as String?,
      frontImage: json['frontImage'] as String?,
    );

Map<String, dynamic> _$IdentityDataToJson(IdentityData instance) =>
    <String, dynamic>{
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'dateOfBirth': instance.dateOfBirth.toIso8601String(),
      'gender': instance.gender,
      'nationality': instance.nationality,
      'idType': instance.idType,
      'idNumber': instance.idNumber,
      'selfieUrl': instance.selfieUrl,
      'frontImage': instance.frontImage,
    };

AddressData _$AddressDataFromJson(Map<String, dynamic> json) => AddressData(
      country: json['country'] as String?,
      state: json['state'] as String?,
      city: json['city'] as String?,
      zipCode: json['zipCode'] as String?,
      addressLine: json['addressLine'] as String?,
      houseNumber: json['houseNumber'] as String?,
      bvn: json['bvn'] as String?,
    );

Map<String, dynamic> _$AddressDataToJson(AddressData instance) =>
    <String, dynamic>{
      'country': instance.country,
      'state': instance.state,
      'city': instance.city,
      'zipCode': instance.zipCode,
      'addressLine': instance.addressLine,
      'houseNumber': instance.houseNumber,
      'bvn': instance.bvn,
    };

FullProfileResponse _$FullProfileResponseFromJson(Map<String, dynamic> json) =>
    FullProfileResponse(
      userId: json['userId'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      userStage: json['userStage'] as String,
      identity: json['identity'] == null
          ? null
          : IdentityData.fromJson(json['identity'] as Map<String, dynamic>),
      address: json['address'] == null
          ? null
          : AddressData.fromJson(json['address'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$FullProfileResponseToJson(
        FullProfileResponse instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'email': instance.email,
      'phone': instance.phone,
      'userStage': instance.userStage,
      'identity': instance.identity,
      'address': instance.address,
    };
