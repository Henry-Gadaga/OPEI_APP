import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tt1/core/network/api_error.dart';
import 'package:tt1/core/providers/providers.dart';
import 'package:tt1/data/models/login_request.dart';
import 'package:tt1/features/auth/login/login_state.dart';

class LoginController extends Notifier<LoginState> {
  @override
  LoginState build() => LoginState();

  void updateEmail(String email) {
    state = state.copyWith(email: email, clearErrors: true);
  }

  void updatePassword(String password) {
    state = state.copyWith(password: password, clearErrors: true);
  }

  void resetPasswordField() {
    state = state.copyWith(password: '', clearErrors: false);
  }

  /// Attempts to log in the user with the provided credentials.
  /// Returns a map with 'success', 'userStage', and 'isEmailVerified' on success.
  /// 
  /// User stages from backend:
  /// - PENDING_EMAIL: User needs to verify email
  /// - PENDING_ADDRESS: User needs to submit address
  /// - PENDING_KYC: User needs to complete KYC verification
  /// - VERIFIED: User has completed all onboarding (can access dashboard)
  Future<Map<String, dynamic>?> login() async {
    if (!state.isValid) {
      String? emailError;
      String? passwordError;

      if (state.email.isEmpty) {
        emailError = 'Email is required';
      } else if (!_isValidEmail(state.email)) {
        emailError = 'Please enter a valid email';
      }

      if (state.password.isEmpty) {
        passwordError = 'Password is required';
      } else if (state.password.length < 8) {
        passwordError = 'Password must be at least 8 characters';
      }

      state = state.copyWith(
        emailError: emailError,
        passwordError: passwordError,
      );
      return null;
    }

    state = state.copyWith(isLoading: true, clearErrors: true);

    try {
      final authRepository = ref.read(authRepositoryProvider);
      final request = LoginRequest(
        email: state.email.trim(),
        password: state.password,
      );

      debugPrint('🔐 Attempting login for: ${request.email}');
      final response = await authRepository.login(request);

      debugPrint('✅ Login successful - User: ${response.user.email}');
      debugPrint('📊 User stage: ${response.user.userStage}');
      
      // Persist email for downstream flows (e.g., verify email screen)
      // This ensures VerifyEmailScreen can recover the email even if route args are missing.
      try {
        final storage = ref.read(secureStorageServiceProvider);
        await storage.saveEmail(response.user.email);
      } catch (e) {
        debugPrint('⚠️ Failed to persist email to storage: $e');
      }
      
      // Set auth session - this will trigger dependent providers to refresh
      ref.read(authSessionProvider.notifier).setSession(
        userId: response.user.id,
        accessToken: response.accessToken,
        userStage: response.user.userStage,
      );
      debugPrint('✅ Auth session set - providers will refresh with new user data');
      
      state = state.copyWith(isLoading: false);

      return {
        'success': true,
        'userStage': response.user.userStage,
        'isEmailVerified': response.user.isEmailVerified,
      };
    } on ApiError catch (e) {
      debugPrint('❌ Login API error: ${e.statusCode} - ${e.message}');
      state = state.copyWith(
        isLoading: false,
        errorMessage: _mapApiErrorToMessage(e),
      );
      return null;
    } catch (e) {
      debugPrint('❌ Login unexpected error: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Something went wrong. Please try again.',
      );
      return null;
    }
  }

  String _mapApiErrorToMessage(ApiError error) {
    switch (error.statusCode) {
      case 401:
        return 'Invalid email or password. Please try again.';
      case 403:
        return 'Your account is not active. Please contact support.';
      case 429:
        return 'Too many login attempts. Please try again in a few minutes.';
      case 500:
      case 502:
      case 503:
        return 'Server error. Please try again later.';
      default:
        return error.message;
    }
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    return emailRegex.hasMatch(email);
  }

  void clearError() {
    state = state.copyWith(clearErrors: true);
  }
}

final loginControllerProvider = NotifierProvider<LoginController, LoginState>(
  LoginController.new,
);
