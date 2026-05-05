import 'dart:async';
import 'dart:io' show SocketException;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opei/core/network/api_error.dart';
import 'package:opei/core/providers/providers.dart';
import 'package:opei/features/auth/quick_auth/quick_auth_state.dart';

class QuickAuthController extends Notifier<QuickAuthState> {
  static const int _maxPinAttempts = 5;
  int _failedPinAttempts = 0;

  @override
  QuickAuthState build() => QuickAuthPinEntry();

  void addDigit(String digit) {
    if (state is! QuickAuthPinEntry) return;
    
    final currentState = state as QuickAuthPinEntry;
    if (currentState.pin.length >= 6) return;
    
    final newPin = currentState.pin + digit;
    state = currentState.copyWith(pin: newPin, errorMessage: null);
    
    if (newPin.length == 6) {
      _verifyPin(newPin);
    }
  }

  void removeDigit() {
    if (state is! QuickAuthPinEntry) return;
    
    final currentState = state as QuickAuthPinEntry;
    if (currentState.pin.isEmpty) return;
    
    final newPin = currentState.pin.substring(0, currentState.pin.length - 1);
    state = currentState.copyWith(pin: newPin, errorMessage: null);
  }

  void _resetFailedAttempts() {
    _failedPinAttempts = 0;
  }

  Future<void> _verifyPin(String pin) async {
    state = QuickAuthLoading();
    final quickAuthStatusNotifier = ref.read(quickAuthStatusProvider.notifier);
    quickAuthStatusNotifier.setStatus(QuickAuthStatus.requiresVerification);

    try {
      final quickAuthService = ref.read(quickAuthServiceProvider);
      final authRepository = ref.read(authRepositoryProvider);
      final storage = ref.read(secureStorageServiceProvider);
      
      // Get user identifier
      final user = await storage.getUser();
      var userIdentifier = user?.id;
      userIdentifier ??= await quickAuthService.getRegisteredUserId();

      if (userIdentifier == null) {
        state = QuickAuthFailed('Session expired. Please login again.');
        return;
      }
      
      // Verify PIN using the new service
      final isValid = await quickAuthService.verifyPin(userIdentifier, pin);
      
      if (!isValid) {
        await _handleInvalidPinAttempt();
        return;
      }

      _resetFailedAttempts();

      final refreshToken = await storage.getRefreshToken();
      
      if (refreshToken == null) {
        state = QuickAuthFailed('Session expired. Please login again.');
        return;
      }

      debugPrint('🔄 Refreshing tokens with stored refresh token...');
      final response = await authRepository.refreshAccessToken(refreshToken);
      
      debugPrint('✅ Tokens refreshed successfully');
      await storage.saveUser(response.user);
      
      // Set auth session - this will trigger dependent providers to refresh
      ref.read(authSessionProvider.notifier).setSession(
            userId: response.user.id,
            accessToken: response.accessToken,
            userStage: response.user.userStage,
      );
      debugPrint('✅ Auth session set via quick auth PIN');
      
      quickAuthStatusNotifier.setStatus(QuickAuthStatus.satisfied);
      state = QuickAuthSuccess();
    } catch (e) {
      debugPrint('❌ Quick auth failed: $e');

      // Network/timeout/server errors should never log the user out: their
      // PIN was correct and their refresh token is still valid, they're
      // simply offline. Show an inline message and let them retry once
      // they're back online. Real auth errors (401/403) fall through to
      // the existing logout-and-redirect path.
      if (_isTransientNetworkError(e)) {
        quickAuthStatusNotifier.setStatus(QuickAuthStatus.requiresVerification);
        state = QuickAuthPinEntry(
          errorMessage:
              'No internet connection. Please check your network and try again.',
        );
        return;
      }

      quickAuthStatusNotifier.setStatus(QuickAuthStatus.requiresVerification);
      _resetFailedAttempts();
      state = QuickAuthFailed('Authentication failed. Please login again.');
    }
  }

  Future<void> verifyBiometric() async {
    state = QuickAuthLoading();
    final quickAuthStatusNotifier = ref.read(quickAuthStatusProvider.notifier);
    quickAuthStatusNotifier.setStatus(QuickAuthStatus.requiresVerification);

    try {
      final quickAuthService = ref.read(quickAuthServiceProvider);
      final authRepository = ref.read(authRepositoryProvider);
      final storage = ref.read(secureStorageServiceProvider);
      
      // Authenticate with biometric
      final isAuthenticated = await quickAuthService.authenticateWithBiometric(
        'Unlock Opei with biometric',
      );
      
      if (!isAuthenticated) {
        state =
            QuickAuthPinEntry(errorMessage: 'Biometric authentication failed');
        await Future.delayed(const Duration(seconds: 2));
        state = QuickAuthPinEntry();
        return;
      }

      final refreshToken = await storage.getRefreshToken();
      
      if (refreshToken == null) {
        state = QuickAuthFailed('Session expired. Please login again.');
        return;
      }

      debugPrint('🔄 Refreshing tokens with stored refresh token...');
      final response = await authRepository.refreshAccessToken(refreshToken);
      
      debugPrint('✅ Tokens refreshed successfully');
      await storage.saveUser(response.user);
      
      // Set auth session - this will trigger dependent providers to refresh
      ref.read(authSessionProvider.notifier).setSession(
            userId: response.user.id,
            accessToken: response.accessToken,
            userStage: response.user.userStage,
      );
      debugPrint('✅ Auth session set via biometric auth');
      
      quickAuthStatusNotifier.setStatus(QuickAuthStatus.satisfied);
      state = QuickAuthSuccess();
    } catch (e) {
      debugPrint('❌ Biometric auth failed: $e');

      // Same offline-friendly handling as PIN verification: keep the
      // session, surface a network error, let the user retry.
      if (_isTransientNetworkError(e)) {
        quickAuthStatusNotifier.setStatus(QuickAuthStatus.requiresVerification);
        state = QuickAuthPinEntry(
          errorMessage:
              'No internet connection. Please check your network and try again.',
        );
        return;
      }

      quickAuthStatusNotifier.setStatus(QuickAuthStatus.requiresVerification);
      state = QuickAuthFailed('Authentication failed. Please login again.');
    }
  }

  void reset() {
    _resetFailedAttempts();
    state = QuickAuthPinEntry();
  }

  Future<void> logoutAndResetPin() async {
    state = QuickAuthLoading();
    try {
      await ref.read(authRepositoryProvider).logout();
    } catch (e) {
      debugPrint('⚠️ Logout during Forgot PIN failed: $e');
    } finally {
      ref.read(authSessionProvider.notifier).clearSession();
      _resetFailedAttempts();
      state = QuickAuthFailed(
        'Logged out. Please sign in to create a new PIN.',
      );
    }
  }

  Future<void> _handleInvalidPinAttempt() async {
    _failedPinAttempts += 1;
    final remainingAttempts = _maxPinAttempts - _failedPinAttempts;

    if (_failedPinAttempts >= _maxPinAttempts) {
      await _forceLogoutAfterTooManyAttempts();
      return;
    }

    final attemptMessage = remainingAttempts == 1
        ? 'Invalid PIN. 1 attempt remaining.'
        : 'Invalid PIN. $remainingAttempts attempts remaining.';

    ref.read(quickAuthStatusProvider.notifier).setStatus(
          QuickAuthStatus.requiresVerification,
        );

    state = QuickAuthPinEntry(errorMessage: attemptMessage);
    await Future.delayed(const Duration(milliseconds: 1500));
    state = QuickAuthPinEntry();
  }

  /// Returns true when [error] looks like a transient network/server hiccup
  /// the user can retry — as opposed to a real authentication failure.
  ///
  /// `ApiClient` wraps Dio connection/timeout errors into [ApiError] with no
  /// `statusCode`, so the absence of a status code is the cleanest signal.
  /// 5xx responses are also treated as transient. Everything else (401/403
  /// auth failures, 400 validation, etc.) falls through and is handled by
  /// the existing logout flow.
  bool _isTransientNetworkError(Object error) {
    if (error is ApiError) {
      if (error.statusCode == null) return true;
      final code = error.statusCode!;
      if (code >= 500 && code < 600) return true;
      return false;
    }
    if (error is SocketException) return true;
    if (error is TimeoutException) return true;
    return false;
  }

  Future<void> _forceLogoutAfterTooManyAttempts() async {
    debugPrint(
        '🔐 Exceeded max PIN attempts ($_maxPinAttempts). Forcing logout.');
    final sessionNotifier = ref.read(authSessionProvider.notifier);

    // Immediately clear local session and update UI state so the screen can react
    sessionNotifier.clearSession();
    _resetFailedAttempts();
    state = QuickAuthFailed(
      'Too many incorrect PIN attempts. Please log in again to set a new PIN.',
    );

    // Fire-and-forget backend logout so a slow network call never blocks the UI
    unawaited(
      ref
          .read(authRepositoryProvider)
          .logout()
          .timeout(const Duration(seconds: 8))
          .catchError(
        (error, stackTrace) {
          debugPrint('⚠️ Forced logout encountered an error: $error');
          return null;
        },
      ),
    );
  }
}

final quickAuthControllerProvider =
    NotifierProvider.autoDispose<QuickAuthController, QuickAuthState>(
  QuickAuthController.new,
);
