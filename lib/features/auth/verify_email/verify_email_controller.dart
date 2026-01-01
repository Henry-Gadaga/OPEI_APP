import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tt1/core/network/api_error.dart';
import 'package:tt1/core/providers/providers.dart';
import 'package:tt1/core/utils/retry_helper.dart';
import 'package:tt1/features/auth/verify_email/verify_email_state.dart';

class VerifyEmailNotifier extends Notifier<VerifyEmailState> {
  Timer? _countdownTimer;
  static DateTime? _sharedThrottleExpiry;
  static const String _throttleStorageKey = 'verify_email_throttle_expiry';

  /// Initializes the verify email screen with the provided email.
  /// If [autoSendCode] is true, automatically sends a verification code (useful for login flow).
  Future<void> initialize(String email, {bool autoSendCode = false}) async {
    debugPrint('🚀 Initializing verify email with: $email (autoSendCode: $autoSendCode)');
    state = VerifyEmailState.initial(email);
    
    final restored = await _restorePendingCountdown();

    if (autoSendCode && !restored) {
      debugPrint('📤 Auto-sending verification code...');
      await _sendCodeImmediately();
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
          resendCountdown: 0,
        );
        return true;
      }

        state = state.copyWith(
          isResending: false,
          errorMessage: response.message,
        resendCountdown: 0,
        );
        return false;
    } on ApiError catch (e) {
      debugPrint('❌ Send error: ${e.message}');
      if (_handleThrottle(e)) {
        return false;
      }
      state = state.copyWith(
        isResending: false,
        errorMessage: e.message,
        resendCountdown: 0,
      );
      return false;
    } catch (e) {
      debugPrint('❌ Unexpected send error: $e');
      state = state.copyWith(
        isResending: false,
        errorMessage: 'Failed to send code',
        resendCountdown: 0,
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
          resendCountdown: 0,
        );
        return true;
      }

        state = state.copyWith(
          isResending: false,
          errorMessage: response.message,
        resendCountdown: 0,
        );
        return false;
    } on ApiError catch (e) {
      debugPrint('❌ Resend error: ${e.message}');
      if (_handleThrottle(e)) {
        return false;
      }

      state = state.copyWith(
        isResending: false,
        errorMessage: e.message,
        resendCountdown: 0,
      );

      return false;
    } catch (e) {
      debugPrint('❌ Unexpected resend error: $e');
      state = state.copyWith(
        isResending: false,
        errorMessage: 'Failed to resend code',
        resendCountdown: 0,
      );
      return false;
    }
  }

  void _applyThrottleExpiry(DateTime? expiry) {
    _countdownTimer?.cancel();
    _sharedThrottleExpiry = expiry;
    unawaited(_persistThrottleExpiry(expiry));

    if (expiry == null) {
      state = state.copyWith(resendCountdown: 0);
      return;
    }

    _tickRemainingTime();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _tickRemainingTime();
    });
  }

  void _tickRemainingTime() {
    final expiry = _sharedThrottleExpiry;
    if (expiry == null) {
      _countdownTimer?.cancel();
      state = state.copyWith(resendCountdown: 0);
      return;
    }

    final remaining = expiry.difference(DateTime.now()).inSeconds;
    if (remaining <= 0) {
      _clearThrottleState();
    } else {
      state = state.copyWith(resendCountdown: remaining);
    }
  }

  bool _handleThrottle(ApiError error) {
    if (error.statusCode != 429) {
      return false;
    }

    final retryInfo = parseRetryInfo(error.errors);
    final countdown = deriveRetrySeconds(retryInfo, fallbackSeconds: 120);

    state = state.copyWith(
      isResending: false,
      errorMessage: buildRetryMessage(error.message, retryInfo),
    );

    final expiry = retryInfo.retryAt?.toLocal() ??
        DateTime.now().add(Duration(seconds: countdown));
    _applyThrottleExpiry(expiry);

    return true;
  }

  Future<bool> _restorePendingCountdown() async {
    final inMemory = _sharedThrottleExpiry;
    final stored = inMemory ?? await _loadThrottleExpiryFromStorage();
    if (stored == null) {
      _clearThrottleState();
      return false;
    }

    final remaining = stored.difference(DateTime.now()).inSeconds;
    if (remaining <= 0) {
      _clearThrottleState();
      return false;
    }

    _applyThrottleExpiry(stored);
    return true;
  }

  void _clearThrottleState() {
    _countdownTimer?.cancel();
    _sharedThrottleExpiry = null;
    unawaited(_persistThrottleExpiry(null));
    state = state.copyWith(resendCountdown: 0);
  }

  Future<void> _persistThrottleExpiry(DateTime? expiry) async {
    final secureStorage = ref.read(secureStorageServiceProvider).storage;
    if (expiry == null) {
      await secureStorage.delete(key: _throttleStorageKey);
      } else {
      await secureStorage.write(
        key: _throttleStorageKey,
        value: expiry.toUtc().toIso8601String(),
      );
    }
  }

  Future<DateTime?> _loadThrottleExpiryFromStorage() async {
    final secureStorage = ref.read(secureStorageServiceProvider).storage;
    final value = await secureStorage.read(key: _throttleStorageKey);
    if (value == null || value.isEmpty) {
      return null;
    }
    return DateTime.tryParse(value)?.toLocal();
      }
}

final verifyEmailControllerProvider = NotifierProvider<VerifyEmailNotifier, VerifyEmailState>(
  VerifyEmailNotifier.new,
);
