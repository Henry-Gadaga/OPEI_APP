import 'package:json_annotation/json_annotation.dart';

part 'address_response.g.dart';

@JsonSerializable()
class AddressResponse {
  final String country;
  final String? state;
  final String city;
  final String? zipCode;
  final String addressLine;
  final String houseNumber;
  final String? bvn;
  final String createdAt;
  final String updatedAt;

  AddressResponse({
    required this.country,
    this.state,
    required this.city,
    this.zipCode,
    required this.addressLine,
    required this.houseNumber,
    this.bvn,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AddressResponse.fromJson(Map<String, dynamic> json) => _$AddressResponseFromJson(json);
  Map<String, dynamic> toJson() => _$AddressResponseToJson(this);
}
