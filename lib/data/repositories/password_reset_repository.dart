import 'package:flutter/foundation.dart';
import 'package:opei/core/network/api_client.dart';
import 'package:opei/core/network/api_response.dart';
import 'package:opei/data/models/password_reset_request.dart';

class PasswordResetRepository {
  final ApiClient _apiClient;

  PasswordResetRepository(this._apiClient);

  Future<ApiResponse<void>> requestPasswordReset(String email) async {
    try {
      final request = PasswordResetRequest(email: email);
      final response = await _apiClient.post<Map<String, dynamic>>(
        '/auth/request-password-reset',
        data: request.toJson(),
      );
      return ApiResponse(
        success: response['success'] as bool? ?? false,
        message: response['message'] as String? ?? '',
        data: null,
      );
    } catch (e, stackTrace) {
      debugPrint('❌ Request password reset error: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<ApiResponse<void>> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    try {
      final request = ResetPasswordDto(
        email: email,
        code: code,
        newPassword: newPassword,
      );
      final response = await _apiClient.post<Map<String, dynamic>>(
        '/auth/reset-password',
        data: request.toJson(),
      );
      return ApiResponse(
        success: response['success'] as bool? ?? false,
        message: response['message'] as String? ?? '',
        data: null,
      );
    } catch (e, stackTrace) {
      debugPrint('❌ Reset password error: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }
}
