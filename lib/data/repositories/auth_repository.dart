import 'package:flutter/foundation.dart';
import 'package:tt1/core/network/api_client.dart';
import 'package:tt1/core/network/api_response.dart';
import 'package:tt1/core/services/quick_auth_service.dart';
import 'package:tt1/core/storage/secure_storage_service.dart';
import 'package:tt1/data/models/auth_response.dart';
import 'package:tt1/data/models/login_request.dart';
import 'package:tt1/data/models/refresh_request.dart';
import 'package:tt1/data/models/signup_request.dart';

class AuthRepository {
  final ApiClient _apiClient;
  final SecureStorageService _storage;
  final QuickAuthService _quickAuthService;

  AuthRepository(this._apiClient, this._storage, this._quickAuthService);

  Future<AuthResponse> signup(SignupRequest request) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/auth/signup',
      data: request.toJson(),
    );

    final apiResponse = ApiResponse<AuthResponse>.fromJson(
      response,
      (json) => AuthResponse.fromJson(json as Map<String, dynamic>),
    );

    if (!apiResponse.success || apiResponse.data == null) {
      throw Exception(apiResponse.message);
    }

    final authResponse = apiResponse.data!;
    
    await _storage.saveToken(authResponse.accessToken);
    await _storage.saveRefreshToken(authResponse.refreshToken);
    await _storage.saveUser(authResponse.user);
    await _quickAuthService.clearUserData(
      authResponse.user.id,
      removeSetupFlag: true,
    );
    await _quickAuthService.registerUserContext(authResponse.user.id);
    await _storage.clearSessionLockTimestamp(authResponse.user.id);

    return authResponse;
  }

  Future<AuthResponse> login(LoginRequest request) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/auth/login',
      data: request.toJson(),
    );

    final apiResponse = ApiResponse<AuthResponse>.fromJson(
      response,
      (json) => AuthResponse.fromJson(json as Map<String, dynamic>),
    );

    if (!apiResponse.success || apiResponse.data == null) {
      throw Exception(apiResponse.message);
    }

    final authResponse = apiResponse.data!;
    
    await _storage.saveToken(authResponse.accessToken);
    await _storage.saveRefreshToken(authResponse.refreshToken);
    await _storage.saveUser(authResponse.user);
    await _quickAuthService.registerUserContext(authResponse.user.id);
    await _storage.clearSessionLockTimestamp(authResponse.user.id);

    return authResponse;
  }

  Future<ApiResponse<Map<String, dynamic>>> verifyEmail(String code) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/auth/verify-email',
      data: {'code': code},
    );

    final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
      response,
      (json) => json as Map<String, dynamic>,
    );

    if (apiResponse.success && apiResponse.data != null) {
      final isEmailVerified = apiResponse.data!['isEmailVerified'];
      final userStage = apiResponse.data!['userStage'];

      final currentUser = await _storage.getUser();
      if (currentUser != null) {
        final updatedUser = currentUser.copyWith(
          isEmailVerified: isEmailVerified,
          userStage: userStage,
        );
        await _storage.saveUser(updatedUser);
      }
    }

    return apiResponse;
  }

  Future<ApiResponse<void>> resendVerificationCode(String email) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/auth/resend-email-verification',
      data: {'email': email},
    );

    return ApiResponse<void>.fromJson(
      response,
      (_) {},
    );
  }

  Future<AuthResponse> refreshAccessToken(String refreshToken) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/auth/refresh',
      data: RefreshRequest(refreshToken: refreshToken).toJson(),
    );

    final apiResponse = ApiResponse<AuthResponse>.fromJson(
      response,
      (json) => AuthResponse.fromJson(json as Map<String, dynamic>),
    );

    if (!apiResponse.success || apiResponse.data == null) {
      throw Exception(apiResponse.message);
    }

    final authResponse = apiResponse.data!;
    
    await _storage.saveToken(authResponse.accessToken);
    await _storage.saveRefreshToken(authResponse.refreshToken);

    return authResponse;
  }

  Future<void> logout() async {
    try {
      await _apiClient.post<Map<String, dynamic>>('/auth/logout');
    } catch (e) {
      debugPrint('Logout API error: $e');
    } finally {
      var userId = await _quickAuthService.getRegisteredUserId();
      userId ??= (await _storage.getUser())?.id;
      if (userId != null) {
        await _quickAuthService.clearUserData(
          userId,
          removeSetupFlag: true,
        );
        await _quickAuthService.clearRegisteredUserContextIfMatch(userId);
        await _storage.clearSessionLockTimestamp(userId);
      } else {
        await _quickAuthService.clearRegisteredUserContext();
      }

      await _storage.clearToken();
      await _storage.clearRefreshToken();
      await _storage.clearUser();
      await _storage.clearEmail();
    }
  }
}
