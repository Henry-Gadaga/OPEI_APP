import 'package:flutter/foundation.dart';
import 'package:opei/core/network/api_client.dart';
import 'package:opei/core/network/api_response.dart';
import 'package:opei/core/storage/secure_storage_service.dart';
import 'package:opei/data/models/address_request.dart';
import 'package:opei/data/models/address_response.dart';

class AddressRepository {
  final ApiClient _apiClient;
  final SecureStorageService _storage;

  AddressRepository(this._apiClient, this._storage);

  Future<ApiResponse<AddressResponse>> submitAddress(AddressRequest request) async {
    try {
      debugPrint('📍 Submitting address...');
      
      final response = await _apiClient.post<Map<String, dynamic>>(
        '/address',
        data: request.toJson(),
      );

      final apiResponse = ApiResponse<AddressResponse>.fromJson(
        response,
        (json) => AddressResponse.fromJson(json as Map<String, dynamic>),
      );

      if (apiResponse.success && apiResponse.data != null) {
        debugPrint('✅ Address submitted successfully');
        
        final currentUser = await _storage.getUser();
        if (currentUser != null) {
          final updatedUser = currentUser.copyWith(
            userStage: 'PENDING_KYC',
          );
          await _storage.saveUser(updatedUser);
          debugPrint('✅ User stage updated to PENDING_KYC');
        }
      }

      return apiResponse;
    } catch (e) {
      debugPrint('❌ Address submission error: $e');
      rethrow;
    }
  }

  Future<AddressResponse> getUserAddress() async {
    try {
      debugPrint('📍 Fetching user address...');
      
      final response = await _apiClient.get<Map<String, dynamic>>('/address/me');

      final apiResponse = ApiResponse<AddressResponse>.fromJson(
        response,
        (json) => AddressResponse.fromJson(json as Map<String, dynamic>),
      );

      if (!apiResponse.success || apiResponse.data == null) {
        throw Exception(apiResponse.message);
      }

      debugPrint('✅ Address fetched successfully');
      return apiResponse.data!;
    } catch (e) {
      debugPrint('❌ Address fetch error: $e');
      rethrow;
    }
  }
}
