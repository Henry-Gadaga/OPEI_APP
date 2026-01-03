import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tt1/core/providers/providers.dart';
import 'package:tt1/core/services/quick_auth_service.dart';
import 'package:tt1/core/storage/secure_storage_service.dart';
import 'package:tt1/features/auth/quick_auth_setup/quick_auth_setup_state.dart';

class QuickAuthSetupController extends Notifier<QuickAuthSetupState> {
  @override
  QuickAuthSetupState build() => QuickAuthSetupPinEntry();

  String? _userIdentifier;

  Future<String> _resolveUserIdentifier(
    QuickAuthService quickAuthService,
    SecureStorageService storage,
  ) async {
    final user = await storage.getUser();
    var identifier = user?.id ?? _userIdentifier;
    identifier ??= await quickAuthService.getRegisteredUserId();

    if (identifier == null) {
      throw Exception('No active user context available for quick auth setup');
    }

    return identifier;
  }

  void addDigit(String digit) {
    if (state is! QuickAuthSetupPinEntry) return;

    final currentState = state as QuickAuthSetupPinEntry;
    if (currentState.pin.length >= 6) return;

    final newPin = currentState.pin + digit;
    state = currentState.copyWith(pin: newPin, errorMessage: null);

    if (newPin.length == 6) {
      if (currentState.isConfirming) {
        _confirmPin(newPin, currentState.firstPin!);
      } else {
        _moveToConfirmation(newPin);
      }
    }
  }

  void removeDigit() {
    if (state is! QuickAuthSetupPinEntry) return;

    final currentState = state as QuickAuthSetupPinEntry;
    if (currentState.pin.isEmpty) return;

    final newPin = currentState.pin.substring(0, currentState.pin.length - 1);
    state = currentState.copyWith(pin: newPin, errorMessage: null);
  }

  void _moveToConfirmation(String pin) async {
    await Future.delayed(const Duration(milliseconds: 200));
    state = QuickAuthSetupPinEntry(
      isConfirming: true,
      firstPin: pin,
    );
  }

  Future<void> _confirmPin(String confirmPin, String firstPin) async {
    if (confirmPin != firstPin) {
      state = QuickAuthSetupPinEntry(
        errorMessage: 'PINs do not match. Please try again.',
      );
      await Future.delayed(const Duration(seconds: 2));
      state = QuickAuthSetupPinEntry();
      return;
    }

    state = QuickAuthSetupLoading();

    try {
      final quickAuthService = ref.read(quickAuthServiceProvider);
      final storage = ref.read(secureStorageServiceProvider);

      final userIdentifier =
          await _resolveUserIdentifier(quickAuthService, storage);

      // Setup PIN using the new service
      await quickAuthService.setupPin(userIdentifier, confirmPin);

      // Mark setup as completed
      await quickAuthService.markSetupCompleted(userIdentifier);
      ref.read(quickAuthStatusProvider.notifier).setStatus(
            QuickAuthStatus.satisfied,
          );

      debugPrint('✅ PIN saved successfully');
      state = QuickAuthSetupSuccess('PIN setup complete');
    } catch (e) {
      debugPrint('❌ Failed to save PIN: $e');
      state = QuickAuthSetupError('Failed to save PIN. Please try again.');
    }
  }

  Future<void> setupBiometric() async {
    state = QuickAuthSetupLoading();

    try {
      final quickAuthService = ref.read(quickAuthServiceProvider);
      final storage = ref.read(secureStorageServiceProvider);

      // Check if device supports biometric
      final canUseBiometric = await quickAuthService.canUseBiometric();

      if (!canUseBiometric) {
        state = QuickAuthSetupError(
            'Biometric authentication is not available on this device');
        return;
      }

      // Authenticate to setup
      final authenticated = await quickAuthService.authenticateWithBiometric(
        'Set up biometric authentication for quick access',
      );

      if (authenticated) {
        final userIdentifier =
            await _resolveUserIdentifier(quickAuthService, storage);

        // Enable biometric
        await quickAuthService.enableBiometric(userIdentifier);

        // Mark setup as completed
        await quickAuthService.markSetupCompleted(userIdentifier);
        ref.read(quickAuthStatusProvider.notifier).setStatus(
              QuickAuthStatus.satisfied,
            );

        debugPrint('✅ Biometric enabled successfully');
        state = QuickAuthSetupSuccess('Biometric authentication enabled');
      } else {
        state = QuickAuthSetupError('Biometric authentication failed');
      }
    } catch (e) {
      debugPrint('❌ Biometric setup failed: $e');
      state = QuickAuthSetupError('Failed to enable biometric authentication');
    }
  }

  void reset() {
    state = QuickAuthSetupPinEntry();
  }
}

final quickAuthSetupControllerProvider =
    NotifierProvider.autoDispose<QuickAuthSetupController, QuickAuthSetupState>(
  QuickAuthSetupController.new,
);
