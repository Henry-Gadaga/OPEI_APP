import 'package:json_annotation/json_annotation.dart';

part 'address_request.g.dart';

@JsonSerializable()
class AddressRequest {
  final String country;
  final String state;
  final String city;
  final String zipCode;
  final String addressLine;
  final String houseNumber;
  final String? bvn;

  AddressRequest({
    required this.country,
    required this.state,
    required this.city,
    required this.zipCode,
    required this.addressLine,
    required this.houseNumber,
    this.bvn,
  });

  factory AddressRequest.fromJson(Map<String, dynamic> json) => _$AddressRequestFromJson(json);
  Map<String, dynamic> toJson() => _$AddressRequestToJson(this);
}
