import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

/// Device-level Quick Auth Service
/// Handles PIN hashing, biometric setup, and per-user storage
class QuickAuthService {
  final FlutterSecureStorage _storage;
  final LocalAuthentication _localAuth;

  QuickAuthService(this._storage, this._localAuth);

  static const String _currentUserKey = 'quick_auth_current_user_id';

  // ========== HELPER: Get user-specific storage key ==========
  String _getUserKey(String userIdentifier, String suffix) => 
      'quick_auth_${userIdentifier}_$suffix';

  // ========== USER CONTEXT ==========
  Future<void> registerUserContext(String userIdentifier) async {
    try {
      await _storage.write(key: _currentUserKey, value: userIdentifier);
      debugPrint('✅ Registered quick auth context for $userIdentifier');
    } catch (e) {
      debugPrint('❌ Error registering quick auth context: $e');
    }
  }

  Future<String?> getRegisteredUserId() async {
    try {
      return await _storage.read(key: _currentUserKey);
    } catch (e) {
      debugPrint('❌ Error reading registered quick auth user: $e');
      return null;
    }
  }

  Future<void> clearRegisteredUserContext() async {
    try {
      await _storage.delete(key: _currentUserKey);
    } catch (e) {
      debugPrint('❌ Error clearing registered quick auth user: $e');
    }
  }

  Future<void> clearRegisteredUserContextIfMatch(String userIdentifier) async {
    try {
      final current = await getRegisteredUserId();
      if (current == userIdentifier) {
        await clearRegisteredUserContext();
      }
    } catch (e) {
      debugPrint('❌ Error clearing quick auth context if match: $e');
    }
  }

  // ========== SETUP COMPLETION FLAG ==========
  Future<void> markSetupCompleted(String userIdentifier) async {
    try {
      final key = _getUserKey(userIdentifier, 'setup_completed');
      await _storage.write(key: key, value: 'true');
      debugPrint('✅ Quick auth setup marked as completed for user: $userIdentifier');
    } catch (e) {
      debugPrint('❌ Error marking setup completed: $e');
    }
  }

  Future<bool> isSetupCompleted(String userIdentifier) async {
    try {
      final hasPin = await hasPinSetup(userIdentifier);
      if (!hasPin) {
        return false;
      }
      final key = _getUserKey(userIdentifier, 'setup_completed');
      debugPrint('🔍 Checking setup completed with key: $key');
      final value = await _storage.read(key: key);
      debugPrint('🔍 Storage value for setup_completed: $value');
      final isCompleted = value == 'true';
      debugPrint('🔍 isSetupCompleted returning: $isCompleted');
      return isCompleted;
    } catch (e) {
      debugPrint('❌ Error checking setup completed: $e');
      return false;
    }
  }

  // ========== PIN MANAGEMENT ==========
  Future<void> setupPin(String userIdentifier, String pin) async {
    try {
      // Generate random salt (16 bytes = 32 hex chars)
      final salt = _generateSalt();
      
      // Hash PIN with PBKDF2
      final pinHash = _hashPin(pin, salt);
      
      // Store both salt and hash
      final saltKey = _getUserKey(userIdentifier, 'pin_salt');
      final hashKey = _getUserKey(userIdentifier, 'pin_hash');
      
      await _storage.write(key: saltKey, value: salt);
      await _storage.write(key: hashKey, value: pinHash);
      
      debugPrint('✅ PIN setup complete for user: $userIdentifier');
    } catch (e) {
      debugPrint('❌ Error setting up PIN: $e');
      rethrow;
    }
  }

  Future<bool> verifyPin(String userIdentifier, String pin) async {
    try {
      final saltKey = _getUserKey(userIdentifier, 'pin_salt');
      final hashKey = _getUserKey(userIdentifier, 'pin_hash');
      
      final salt = await _storage.read(key: saltKey);
      final storedHash = await _storage.read(key: hashKey);
      
      if (salt == null || storedHash == null) {
        debugPrint('❌ PIN not set up for user: $userIdentifier');
        return false;
      }
      
      final enteredHash = _hashPin(pin, salt);
      final isValid = enteredHash == storedHash;
      
      debugPrint(isValid 
          ? '✅ PIN verified successfully' 
          : '❌ PIN verification failed');
      
      return isValid;
    } catch (e) {
      debugPrint('❌ Error verifying PIN: $e');
      return false;
    }
  }

  Future<bool> hasPinSetup(String userIdentifier) async {
    try {
      final hashKey = _getUserKey(userIdentifier, 'pin_hash');
      final hash = await _storage.read(key: hashKey);
      return hash != null;
    } catch (e) {
      debugPrint('❌ Error checking PIN setup: $e');
      return false;
    }
  }

  // ========== BIOMETRIC MANAGEMENT ==========
  Future<bool> canUseBiometric() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isSupported = await _localAuth.isDeviceSupported();
      return canCheck && isSupported;
    } catch (e) {
      debugPrint('❌ Error checking biometric availability: $e');
      return false;
    }
  }

  /// Returns true when the device's primary biometric is Face ID (iOS) or
  /// face unlock (Android). Used purely to pick the right icon and copy
  /// in the UI (face vs fingerprint).
  Future<bool> hasFaceBiometric() async {
    try {
      final available = await _localAuth.getAvailableBiometrics();
      return available.contains(BiometricType.face);
    } catch (e) {
      debugPrint('❌ Error reading biometric types: $e');
      return false;
    }
  }

  /// Records that we've shown the "Enable biometric login" banner to this
  /// user once. Used so existing users only see the inline prompt one
  /// time on the quick-auth screen (they can still toggle it on later
  /// from Profile > Security Settings).
  Future<void> markBiometricPromptShown(String userIdentifier) async {
    try {
      final key = _getUserKey(userIdentifier, 'biometric_prompt_shown');
      await _storage.write(key: key, value: 'true');
    } catch (e) {
      debugPrint('❌ Error marking biometric prompt shown: $e');
    }
  }

  Future<bool> wasBiometricPromptShown(String userIdentifier) async {
    try {
      final key = _getUserKey(userIdentifier, 'biometric_prompt_shown');
      final value = await _storage.read(key: key);
      return value == 'true';
    } catch (e) {
      debugPrint('❌ Error reading biometric prompt-shown flag: $e');
      return false;
    }
  }

  Future<void> enableBiometric(String userIdentifier) async {
    try {
      final key = _getUserKey(userIdentifier, 'biometric_enabled');
      await _storage.write(key: key, value: 'true');
      debugPrint('✅ Biometric enabled for user: $userIdentifier');
    } catch (e) {
      debugPrint('❌ Error enabling biometric: $e');
      rethrow;
    }
  }

  Future<bool> isBiometricEnabled(String userIdentifier) async {
    try {
      final key = _getUserKey(userIdentifier, 'biometric_enabled');
      final value = await _storage.read(key: key);
      return value == 'true';
    } catch (e) {
      debugPrint('❌ Error checking biometric enabled: $e');
      return false;
    }
  }

  Future<bool> authenticateWithBiometric(String reason) async {
    try {
      final authenticated = await _localAuth.authenticate(
        localizedReason: reason,
        persistAcrossBackgrounding: true,
        biometricOnly: false,
      );
      
      debugPrint(authenticated 
          ? '✅ Biometric authentication successful' 
          : '❌ Biometric authentication failed');
      
      return authenticated;
    } catch (e) {
      debugPrint('❌ Biometric authentication error: $e');
      return false;
    }
  }

  // ========== CHECK IF ANY QUICK AUTH IS SET UP ==========
  Future<bool> hasAnyQuickAuthSetup(String userIdentifier) async {
    final hasPin = await hasPinSetup(userIdentifier);
    final hasBiometric = await isBiometricEnabled(userIdentifier);
    return hasPin || hasBiometric;
  }

  // ========== CHANGE PIN ==========
  Future<bool> changePin(String userIdentifier, String oldPin, String newPin) async {
    try {
      // Verify old PIN first
      final isOldPinValid = await verifyPin(userIdentifier, oldPin);
      if (!isOldPinValid) {
        debugPrint('❌ Old PIN verification failed');
        return false;
      }
      
      // Setup new PIN
      await setupPin(userIdentifier, newPin);
      debugPrint('✅ PIN changed successfully');
      return true;
    } catch (e) {
      debugPrint('❌ Error changing PIN: $e');
      return false;
    }
  }

  // ========== DISABLE BIOMETRIC ==========
  Future<void> disableBiometric(String userIdentifier) async {
    try {
      final key = _getUserKey(userIdentifier, 'biometric_enabled');
      await _storage.delete(key: key);
      debugPrint('✅ Biometric disabled for user: $userIdentifier');
    } catch (e) {
      debugPrint('❌ Error disabling biometric: $e');
      rethrow;
    }
  }

  // ========== DISABLE QUICK AUTH COMPLETELY ==========
  Future<void> disableQuickAuth(String userIdentifier) async {
    try {
      final keys = [
        _getUserKey(userIdentifier, 'setup_completed'),
        _getUserKey(userIdentifier, 'pin_salt'),
        _getUserKey(userIdentifier, 'pin_hash'),
        _getUserKey(userIdentifier, 'biometric_enabled'),
        _getUserKey(userIdentifier, 'biometric_prompt_shown'),
      ];
      
      for (final key in keys) {
        await _storage.delete(key: key);
      }
      
      debugPrint('✅ Quick auth completely disabled for user: $userIdentifier');
    } catch (e) {
      debugPrint('❌ Error disabling quick auth: $e');
      rethrow;
    }
  }

  // ========== CLEAR USER DATA (on logout) ==========
  /// Clears quick auth data for a user. When [removeSetupFlag] is true the setup flag is
  /// wiped as well which forces a fresh enrollment on the next login.
  Future<void> clearUserData(String userIdentifier, {bool removeSetupFlag = false}) async {
    try {
      final keys = [
        _getUserKey(userIdentifier, 'pin_salt'),
        _getUserKey(userIdentifier, 'pin_hash'),
        _getUserKey(userIdentifier, 'biometric_enabled'),
        _getUserKey(userIdentifier, 'biometric_prompt_shown'),
      ];

      if (removeSetupFlag) {
        keys.add(_getUserKey(userIdentifier, 'setup_completed'));
      }
      
      for (final key in keys) {
        await _storage.delete(key: key);
      }
      
      debugPrint('✅ Cleared quick auth data for user: $userIdentifier (removeSetupFlag: $removeSetupFlag)');
    } catch (e) {
      debugPrint('❌ Error clearing user data: $e');
    }
  }

  // ========== CRYPTO HELPERS ==========
  String _generateSalt() {
    final random = Random.secure();
    final saltBytes = List<int>.generate(16, (_) => random.nextInt(256));
    return base64Url.encode(saltBytes);
  }

  String _hashPin(String pin, String salt) {
    // PBKDF2 with 10,000 iterations
    final iterations = 10000;
    final keyLength = 32; // 256 bits
    
    final saltBytes = base64Url.decode(salt);
    final pinBytes = utf8.encode(pin);
    
    // Simple PBKDF2 implementation using SHA-256
    var result = <int>[];
    var block = <int>[];
    
    for (var i = 1; result.length < keyLength; i++) {
      block = _pbkdf2Block(pinBytes, saltBytes, iterations, i);
      result.addAll(block);
    }
    
    return base64Url.encode(result.sublist(0, keyLength));
  }

  List<int> _pbkdf2Block(List<int> password, List<int> salt, int iterations, int blockNumber) {
    final hmac = Hmac(sha256, password);
    
    // First iteration: HMAC(password, salt || blockNumber)
    var block = hmac.convert([...salt, blockNumber >> 24, blockNumber >> 16, blockNumber >> 8, blockNumber]).bytes;
    var result = List<int>.from(block);
    
    // Remaining iterations
    for (var i = 1; i < iterations; i++) {
      block = hmac.convert(block).bytes;
      for (var j = 0; j < result.length; j++) {
        result[j] ^= block[j];
      }
    }
    
    return result;
  }
}
