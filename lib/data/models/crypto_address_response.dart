import 'package:json_annotation/json_annotation.dart';

part 'crypto_address_response.g.dart';

@JsonSerializable()
class CryptoAddressResponse {
  final String status;
  final String chain;
  final String address;
  final String providerId;
  final String createdAt;

  CryptoAddressResponse({
    required this.status,
    required this.chain,
    required this.address,
    required this.providerId,
    required this.createdAt,
  });

  factory CryptoAddressResponse.fromJson(Map<String, dynamic> json) => _$CryptoAddressResponseFromJson(json);
  Map<String, dynamic> toJson() => _$CryptoAddressResponseToJson(this);
}
