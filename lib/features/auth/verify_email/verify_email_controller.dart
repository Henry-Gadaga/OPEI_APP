import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tt1/core/network/api_error.dart';
import 'package:tt1/core/providers/providers.dart';
import 'package:tt1/features/auth/verify_email/verify_email_state.dart';

class VerifyEmailNotifier extends Notifier<VerifyEmailState> {
  Timer? _countdownTimer;

  /// Initializes the verify email screen with the provided email.
  /// If [autoSendCode] is true, automatically sends a verification code (useful for login flow).
  Future<void> initialize(String email, {bool autoSendCode = false}) async {
    debugPrint('🚀 Initializing verify email with: $email (autoSendCode: $autoSendCode)');
    state = VerifyEmailState.initial(email);
    
    if (autoSendCode) {
      debugPrint('📤 Auto-sending verification code...');
      await _sendCodeImmediately();
    } else {
      _startCountdown();
    }
  }

  /// Sends code immediately without countdown check (used for auto-send on login)
  Future<bool> _sendCodeImmediately() async {
    state = state.copyWith(isResending: true, clearError: true);

    try {
      final authRepository = ref.read(authRepositoryProvider);
      final response = await authRepository.resendVerificationCode(state.email);

      if (response.success) {
        debugPrint('✅ Verification code sent');
        state = state.copyWith(
          isResending: false,
          resendCountdown: 120,
        );
        _startCountdown();
        return true;
      } else {
        state = state.copyWith(
          isResending: false,
          errorMessage: response.message,
        );
        return false;
      }
    } on ApiError catch (e) {
      debugPrint('❌ Send error: ${e.message}');
      state = state.copyWith(
        isResending: false,
        errorMessage: e.message,
      );
      return false;
    } catch (e) {
      debugPrint('❌ Unexpected send error: $e');
      state = state.copyWith(
        isResending: false,
        errorMessage: 'Failed to send code',
      );
      return false;
    }
  }

  @override
  VerifyEmailState build() => VerifyEmailState.initial('');

  void updateDigit(int index, String digit) {
    if (index < 0 || index >= 6) return;

    final newDigits = List<String>.from(state.codeDigits);
    newDigits[index] = digit;

    state = state.copyWith(codeDigits: newDigits, clearError: true);

    if (state.isCodeComplete) {
      verifyCode();
    }
  }

  void clearDigit(int index) {
    if (index < 0 || index >= 6) return;

    final newDigits = List<String>.from(state.codeDigits);
    newDigits[index] = '';

    state = state.copyWith(codeDigits: newDigits, clearError: true);
  }

  Future<bool> verifyCode() async {
    if (!state.isCodeComplete || state.isVerifying) return false;

    state = state.copyWith(isVerifying: true, clearError: true);

    try {
      final authRepository = ref.read(authRepositoryProvider);
      final response = await authRepository.verifyEmail(state.fullCode);

      if (response.success) {
        debugPrint('✅ Email verified successfully');
        final newStage = response.data?['userStage'] as String?;
        if (newStage != null) {
          ref.read(authSessionProvider.notifier).updateUserStage(newStage);
        }
        state = state.copyWith(isVerifying: false);
        return true;
      } else {
        state = state.copyWith(
          isVerifying: false,
          errorMessage: response.message,
          codeDigits: List.filled(6, ''),
        );
        return false;
      }
    } on ApiError catch (e) {
      debugPrint('❌ Verification error: ${e.message}');

      String errorMessage;
      if (e.statusCode == 400) {
        errorMessage = 'Invalid or expired code';
      } else if (e.statusCode == 404) {
        errorMessage = 'User not found';
      } else if (e.statusCode == 500) {
        errorMessage = 'Server error. Try again';
      } else {
        errorMessage = e.message;
      }

      state = state.copyWith(
        isVerifying: false,
        errorMessage: errorMessage,
        codeDigits: List.filled(6, ''),
      );

      return false;
    } catch (e) {
      debugPrint('❌ Unexpected verification error: $e');
      state = state.copyWith(
        isVerifying: false,
        errorMessage: 'Unexpected error occurred',
        codeDigits: List.filled(6, ''),
      );
      return false;
    }
  }

  Future<bool> resendCode() async {
    if (!state.canResend) return false;

    state = state.copyWith(isResending: true, clearError: true);

    try {
      final authRepository = ref.read(authRepositoryProvider);
      final response = await authRepository.resendVerificationCode(state.email);

      if (response.success) {
        debugPrint('✅ Verification code resent');
        state = state.copyWith(
          isResending: false,
          resendCountdown: 120,
        );
        _startCountdown();
        return true;
      } else {
        state = state.copyWith(
          isResending: false,
          errorMessage: response.message,
        );
        return false;
      }
    } on ApiError catch (e) {
      debugPrint('❌ Resend error: ${e.message}');

      String errorMessage;
      if (e.statusCode == 429) {
        errorMessage = 'Too many requests. Try again later';
      } else {
        errorMessage = e.message;
      }

      state = state.copyWith(
        isResending: false,
        errorMessage: errorMessage,
      );

      return false;
    } catch (e) {
      debugPrint('❌ Unexpected resend error: $e');
      state = state.copyWith(
        isResending: false,
        errorMessage: 'Failed to resend code',
      );
      return false;
    }
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    
    debugPrint('🔔 Starting countdown from ${state.resendCountdown} seconds');

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.resendCountdown > 0) {
        final newCount = state.resendCountdown - 1;
        debugPrint('⏱️ Countdown: $newCount seconds remaining');
        state = state.copyWith(resendCountdown: newCount);
      } else {
        debugPrint('✅ Countdown finished - resend enabled');
        timer.cancel();
      }
    });
  }

}

final verifyEmailControllerProvider = NotifierProvider<VerifyEmailNotifier, VerifyEmailState>(
  VerifyEmailNotifier.new,
);
