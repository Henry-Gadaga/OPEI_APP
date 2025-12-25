import 'package:tt1/core/money/money.dart';
import 'package:tt1/core/network/api_client.dart';
import 'package:tt1/data/models/crypto_address_response.dart';
import 'package:tt1/data/models/crypto_transfer_response.dart';

class CryptoRepository {
  final ApiClient _apiClient;

  CryptoRepository(this._apiClient);

  Future<CryptoAddressResponse> getDepositAddress({
    required String currency,
    required String network,
  }) async {
    final payload = await _apiClient.get<Map<String, dynamic>>(
      '/crypto/addresses/${network.toLowerCase()}',
      queryParameters: {
        'currency': currency.toLowerCase(),
      },
    );

    return CryptoAddressResponse.fromJson(payload);
  }

  Future<CryptoTransferResponse> createCryptoTransfer({
    required String chain,
    required String assetType,
    required Money amount,
    required String address,
    String? description,
  }) async {
    final data = <String, dynamic>{
      'chain': chain.toLowerCase(),
      'assetType': assetType.toUpperCase(),
      'amountCents': amount.cents,
      'address': address,
    };

    if (description != null && description.isNotEmpty) {
      data['description'] = description;
    }

    final payload = await _apiClient.post<Map<String, dynamic>>(
      '/crypto/transfers',
      data: data,
    );

    return CryptoTransferResponse.fromJson(payload);
  }
}
