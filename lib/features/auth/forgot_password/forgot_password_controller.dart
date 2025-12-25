import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tt1/core/network/api_error.dart';
import 'package:tt1/core/providers/providers.dart';
import 'package:tt1/features/auth/forgot_password/forgot_password_state.dart';

class ForgotPasswordController extends Notifier<ForgotPasswordState> {
  @override
  ForgotPasswordState build() => ForgotPasswordState();

  void updateEmail(String email) {
    state = state.copyWith(
      email: email,
      emailError: null,
      errorMessage: null,
      successMessage: null,
    );
  }

  bool _validateEmail() {
    final email = state.email.trim();

    if (email.isEmpty) {
      state = state.copyWith(emailError: 'Email is required');
      return false;
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      state = state.copyWith(emailError: 'Please enter a valid email');
      return false;
    }

    return true;
  }

  Future<bool> requestPasswordReset() async {
    if (!_validateEmail()) {
      return false;
    }

    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      successMessage: null,
    );

    try {
      final repository = ref.read(passwordResetRepositoryProvider);
      final response = await repository.requestPasswordReset(state.email.trim());

      if (response.success) {
        state = state.copyWith(
          isLoading: false,
          successMessage: 'If an account exists, we sent a verification code to your email',
        );
        debugPrint('✅ Password reset request sent successfully');
        return true;
      }

      state = state.copyWith(
        isLoading: false,
        errorMessage: response.message,
      );
      return false;
    } on ApiError catch (e) {
      debugPrint('❌ Password reset request API error: ${e.statusCode} - ${e.message}');
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.message,
      );
      return false;
    } catch (e) {
      debugPrint('❌ Password reset request unexpected error: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Something went wrong. Please try again.',
      );
      return false;
    }
  }
}

final forgotPasswordControllerProvider =
    NotifierProvider<ForgotPasswordController, ForgotPasswordState>(
  ForgotPasswordController.new,
);
