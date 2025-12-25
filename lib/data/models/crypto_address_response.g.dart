part of 'crypto_address_response.dart';

CryptoAddressResponse _$CryptoAddressResponseFromJson(Map<String, dynamic> json) => CryptoAddressResponse(
      status: json['status'] as String,
      chain: json['chain'] as String,
      address: json['address'] as String,
      providerId: json['providerId'] as String,
      createdAt: json['createdAt'] as String,
    );

Map<String, dynamic> _$CryptoAddressResponseToJson(CryptoAddressResponse instance) => <String, dynamic>{
      'status': instance.status,
      'chain': instance.chain,
      'address': instance.address,
      'providerId': instance.providerId,
      'createdAt': instance.createdAt,
    };
