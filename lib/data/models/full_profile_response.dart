import 'package:json_annotation/json_annotation.dart';

part 'full_profile_response.g.dart';

@JsonSerializable()
class IdentityData {
  final String firstName;
  final String lastName;
  final DateTime dateOfBirth;
  final String gender;
  final String nationality;
  final String idType;
  final String idNumber;
  final String? selfieUrl;
  final String? frontImage;

  IdentityData({
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
    required this.gender,
    required this.nationality,
    required this.idType,
    required this.idNumber,
    this.selfieUrl,
    this.frontImage,
  });

  factory IdentityData.fromJson(Map<String, dynamic> json) =>
      _$IdentityDataFromJson(json);

  Map<String, dynamic> toJson() => _$IdentityDataToJson(this);
}

@JsonSerializable()
class AddressData {
  final String? country;
  final String? state;
  final String? city;
  final String? zipCode;
  final String? addressLine;
  final String? houseNumber;
  final String? bvn;

  AddressData({
    this.country,
    this.state,
    this.city,
    this.zipCode,
    this.addressLine,
    this.houseNumber,
    this.bvn,
  });

  factory AddressData.fromJson(Map<String, dynamic> json) =>
      _$AddressDataFromJson(json);

  Map<String, dynamic> toJson() => _$AddressDataToJson(this);
}

@JsonSerializable()
class FullProfileResponse {
  final String userId;
  final String email;
  final String phone;
  final String userStage;
  final IdentityData? identity;
  final AddressData? address;

  FullProfileResponse({
    required this.userId,
    required this.email,
    required this.phone,
    required this.userStage,
    this.identity,
    this.address,
  });

  factory FullProfileResponse.fromJson(Map<String, dynamic> json) =>
      _$FullProfileResponseFromJson(json);

  Map<String, dynamic> toJson() => _$FullProfileResponseToJson(this);

  String get displayName {
    if (identity != null) {
      return '${identity!.firstName} ${identity!.lastName}';
    }
    return email.split('@').first;
  }
}
