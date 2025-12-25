import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tt1/core/providers/providers.dart';
import 'package:tt1/features/auth/quick_auth/quick_auth_state.dart';

class QuickAuthController extends Notifier<QuickAuthState> {
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

  Future<void> _verifyPin(String pin) async {
    state = QuickAuthLoading();

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
        state = QuickAuthPinEntry(errorMessage: 'Invalid PIN. Please try again.');
        await Future.delayed(const Duration(milliseconds: 1500));
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
        response.user.id,
        response.accessToken,
      );
      debugPrint('✅ Auth session set via quick auth PIN');
      
      state = QuickAuthSuccess();
    } catch (e) {
      debugPrint('❌ Quick auth failed: $e');
      state = QuickAuthFailed('Authentication failed. Please login again.');
    }
  }

  Future<void> verifyBiometric() async {
    state = QuickAuthLoading();

    try {
      final quickAuthService = ref.read(quickAuthServiceProvider);
      final authRepository = ref.read(authRepositoryProvider);
      final storage = ref.read(secureStorageServiceProvider);
      
      // Authenticate with biometric
      final isAuthenticated = await quickAuthService.authenticateWithBiometric(
        'Unlock Opei with biometric',
      );
      
      if (!isAuthenticated) {
        state = QuickAuthPinEntry(errorMessage: 'Biometric authentication failed');
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
        response.user.id,
        response.accessToken,
      );
      debugPrint('✅ Auth session set via biometric auth');
      
      state = QuickAuthSuccess();
    } catch (e) {
      debugPrint('❌ Biometric auth failed: $e');
      state = QuickAuthFailed('Authentication failed. Please login again.');
    }
  }

  void reset() {
    state = QuickAuthPinEntry();
  }
}

final quickAuthControllerProvider =
    NotifierProvider<QuickAuthController, QuickAuthState>(
  QuickAuthController.new,
);
