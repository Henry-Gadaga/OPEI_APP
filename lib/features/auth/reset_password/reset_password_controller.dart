import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opei/core/network/api_error.dart';
import 'package:opei/core/providers/providers.dart';
import 'package:opei/features/auth/reset_password/reset_password_state.dart';

class ResetPasswordController extends Notifier<ResetPasswordState> {
  late String _email;
  @override
  ResetPasswordState build() {
    return ResetPasswordState(email: _email);
  }

  void updateCode(String code) {
    state = state.copyWith(
      code: code,
      codeError: null,
      errorMessage: null,
    );
  }

  void updateNewPassword(String password) {
    state = state.copyWith(
      newPassword: password,
      passwordError: null,
      errorMessage: null,
    );
  }

  void updateConfirmPassword(String password) {
    state = state.copyWith(
      confirmPassword: password,
      confirmPasswordError: null,
      errorMessage: null,
    );
  }

  bool _validateInputs() {
    String? codeError;
    String? passwordError;
    String? confirmPasswordError;

    if (state.code.trim().isEmpty) {
      codeError = 'Verification code is required';
    } else if (state.code.trim().length != 6) {
      codeError = 'Code must be 6 digits';
    }

    if (state.newPassword.isEmpty) {
      passwordError = 'Password is required';
    } else if (state.newPassword.length < 8) {
      passwordError = 'Password must be at least 8 characters';
    } else if (!_isPasswordStrong(state.newPassword)) {
      passwordError = 'Password must contain uppercase, lowercase, number, and special character';
    }

    if (state.confirmPassword.isEmpty) {
      confirmPasswordError = 'Please confirm your password';
    } else if (state.confirmPassword != state.newPassword) {
      confirmPasswordError = 'Passwords do not match';
    }

    if (codeError != null || passwordError != null || confirmPasswordError != null) {
      state = state.copyWith(
        codeError: codeError,
        passwordError: passwordError,
        confirmPasswordError: confirmPasswordError,
      );
      return false;
    }

    return true;
  }

  bool _isPasswordStrong(String password) {
    final hasUppercase = password.contains(RegExp(r'[A-Z]'));
    final hasLowercase = password.contains(RegExp(r'[a-z]'));
    final hasDigit = password.contains(RegExp(r'[0-9]'));
    final hasSpecialChar = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

    return hasUppercase && hasLowercase && hasDigit && hasSpecialChar;
  }

  Future<bool> resetPassword() async {
    if (!_validateInputs()) {
      return false;
    }

    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
    );

    try {
      final repository = ref.read(passwordResetRepositoryProvider);
      final response = await repository.resetPassword(
        email: state.email.trim(),
        code: state.code.trim(),
        newPassword: state.newPassword,
      );

      if (response.success) {
        debugPrint('✅ Password reset successful - clearing session');
        
        final authRepository = ref.read(authRepositoryProvider);
        await authRepository.logout();
          ref.read(authSessionProvider.notifier).clearSession();
        
        state = state.copyWith(isLoading: false);
        return true;
      }

      state = state.copyWith(
        isLoading: false,
        errorMessage: response.message,
      );
      return false;
    } on ApiError catch (e) {
      debugPrint('❌ Password reset API error: ${e.statusCode} - ${e.message}');
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.message,
      );
      return false;
    } catch (e) {
      debugPrint('❌ Password reset unexpected error: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Something went wrong. Please try again.',
      );
      return false;
    }
  }
}

final resetPasswordControllerProvider =
    NotifierProvider.family<ResetPasswordController, ResetPasswordState, String>(
  (email) {
    final controller = ResetPasswordController();
    controller._email = email;
    return controller;
  },
);
