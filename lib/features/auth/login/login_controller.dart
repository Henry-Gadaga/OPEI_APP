import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opei/core/locale/app_locale_controller.dart';
import 'package:opei/core/network/api_error.dart';
import 'package:opei/core/providers/providers.dart';
import 'package:opei/core/utils/error_helper.dart';
import 'package:opei/data/models/login_request.dart';
import 'package:opei/features/auth/login/login_state.dart';

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
      final l10n = ErrorHelper.l10n;
      String? emailError;
      String? passwordError;

      if (state.email.isEmpty) {
        emailError = l10n.emailRequiredError;
      } else if (!_isValidEmail(state.email)) {
        emailError = l10n.emailInvalidError;
      }

      if (state.password.isEmpty) {
        passwordError = l10n.pinRequiredError;
      } else if (!RegExp(r'^\d{6}$').hasMatch(state.password)) {
        passwordError = l10n.pinInvalidError;
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

      // Pre-clear the quick-auth gate for verified users BEFORE setSession
      // refreshes the router. Otherwise, if the previous app boot left
      // quickAuthStatus = requiresVerification (e.g. user came here via
      // "Use password instead"), the redirect guard would immediately
      // bounce the new session to /quick-auth, causing the "no quick PIN
      // set up" UI to flash for the new account before enrollment finishes.
      if (response.user.userStage.toUpperCase() == 'VERIFIED') {
        ref
            .read(quickAuthStatusProvider.notifier)
            .setStatus(QuickAuthStatus.satisfied);
      } else {
        ref.read(quickAuthStatusProvider.notifier).reset();
      }

      // Set auth session - this will trigger dependent providers to refresh
      ref
          .read(authSessionProvider.notifier)
          .setSession(
            userId: response.user.id,
            accessToken: response.accessToken,
            userStage: response.user.userStage,
          );
      await ref
          .read(appLocaleControllerProvider.notifier)
          .syncFromBackend(userId: response.user.id);
      debugPrint(
        '✅ Auth session set - providers will refresh with new user data',
      );

      await _silentlyEnrollQuickAuthPin(
        userId: response.user.id,
        pin: state.password,
        userStage: response.user.userStage,
      );

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
        errorMessage: ErrorHelper.l10n.errGenericRetry,
      );
      return null;
    }
  }

  String _mapApiErrorToMessage(ApiError error) {
    final l10n = ErrorHelper.l10n;
    switch (error.statusCode) {
      case 401:
        return l10n.loginInvalidCredentialsError;
      case 403:
        return l10n.loginAccountInactiveError;
      case 429:
        return l10n.loginTooManyAttemptsError;
      case 500:
      case 502:
      case 503:
        return l10n.errServerSideShortly;
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

  Future<void> _silentlyEnrollQuickAuthPin({
    required String userId,
    required String pin,
    required String userStage,
  }) async {
    try {
      final quickAuthService = ref.read(quickAuthServiceProvider);
      final hasPin = await quickAuthService.hasPinSetup(userId);
      if (!hasPin) {
        await quickAuthService.setupPin(userId, pin);
      }

      if (userStage.toUpperCase() == 'VERIFIED') {
        await quickAuthService.markSetupCompleted(userId);
      }
    } catch (e) {
      // Local quick-auth enrollment should never block a successful login.
      debugPrint('⚠️ Quick auth PIN enrollment skipped after login: $e');
    }
  }
}

final loginControllerProvider = NotifierProvider<LoginController, LoginState>(
  LoginController.new,
);
