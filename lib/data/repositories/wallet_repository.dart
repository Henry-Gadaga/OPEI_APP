import 'package:flutter/foundation.dart';
import 'package:opei/core/network/api_client.dart';
import 'package:opei/core/network/api_error.dart';
import 'package:opei/core/utils/error_helper.dart';
import 'package:opei/data/models/wallet_balance.dart';

class WalletRepository {
  final ApiClient _apiClient;

  WalletRepository(this._apiClient);

  Future<WalletBalance?> getWallet(String userId) async {
    try {
      debugPrint('💼 Fetching wallet balance for $userId');
      final payload = await _apiClient.get<Map<String, dynamic>>('/wallets/$userId');

      if (payload.containsKey('data') && payload['data'] is Map<String, dynamic>) {
        return WalletBalance.fromJson(payload['data'] as Map<String, dynamic>);
      }

      return WalletBalance.fromJson(payload);
    } on ApiError catch (error) {
      if (error.statusCode == 404) {
        debugPrint('ℹ️ Wallet not found for user $userId (404). Returning null.');
        return null;
      }

      final message = ErrorHelper.getErrorMessage(error);
      debugPrint('❌ Wallet fetch failed: $message');
      rethrow;
    }
  }
}