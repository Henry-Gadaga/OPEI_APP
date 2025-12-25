import 'package:flutter/foundation.dart';
import 'package:tt1/core/network/api_client.dart';
import 'package:tt1/core/network/api_response.dart';
import 'package:tt1/data/models/kyc_session_response.dart';

class KycRepository {
  final ApiClient _apiClient;

  KycRepository(this._apiClient);

  Future<ApiResponse<KycSessionResponse>> createKycSession() async {
    try {
      debugPrint('🔐 Creating KYC session...');
      
      final response = await _apiClient.post<Map<String, dynamic>>(
        '/kyc/session',
        data: {},
      );

      final apiResponse = ApiResponse<KycSessionResponse>.fromJson(
        response,
        (json) => KycSessionResponse.fromJson(json as Map<String, dynamic>),
      );

      if (apiResponse.success && apiResponse.data != null) {
        debugPrint('✅ KYC session created: ${apiResponse.data!.sessionUrl}');
        debugPrint('📊 Session status: ${apiResponse.data!.status}');
      }

      return apiResponse;
    } catch (e) {
      debugPrint('❌ KYC session creation error: $e');
      rethrow;
    }
  }
}
