import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:opei/core/constants/app_constants.dart';
import 'package:opei/data/models/user_model.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService(this._storage);

  static const String _quickAuthCurrentUserIdKey = 'quick_auth_current_user_id';
  // In-memory fallbacks for web or transient read failures
  static String? _inMemoryAccessToken;
  static String? _inMemoryRefreshToken;

  String _sessionLockKey(String userId) => 'session_lock_${userId}_last_active';

  // Expose storage for one-time reset operations
  FlutterSecureStorage get storage => _storage;

  Future<void> saveToken(String token) async {
    try {
      await _storage.write(key: AppConstants.tokenKey, value: token);
    } catch (e) {
      debugPrint('Error saving token: $e');
    }
    // Always mirror to memory for immediate availability (especially on web)
    _inMemoryAccessToken = token;
  }

  Future<String?> getToken() async {
    try {
      final stored = await _storage.read(key: AppConstants.tokenKey);
      if (stored != null && stored.isNotEmpty) {
        _inMemoryAccessToken = stored;
        return stored;
      }
    } catch (e) {
      debugPrint('Error reading token: $e');
    }
    // Fallback to in-memory cache if secure storage is unavailable on this platform
    return _inMemoryAccessToken;
  }

  Future<void> clearToken() async {
    try {
      await _storage.delete(key: AppConstants.tokenKey);
    } catch (e) {
      debugPrint('Error clearing token: $e');
    }
    _inMemoryAccessToken = null;
  }

  Future<void> saveUser(UserModel user) async {
    try {
      final userJson = jsonEncode(user.toJson());
      await _storage.write(key: AppConstants.userKey, value: userJson);
    } catch (e) {
      debugPrint('Error saving user: $e');
    }
  }

  Future<UserModel?> getUser() async {
    try {
      final userJson = await _storage.read(key: AppConstants.userKey);
      if (userJson != null) {
        return UserModel.fromJson(jsonDecode(userJson));
      }
      return null;
    } catch (e) {
      debugPrint('Error reading user: $e');
      return null;
    }
  }

  Future<void> clearUser() async {
    try {
      await _storage.delete(key: AppConstants.userKey);
    } catch (e) {
      debugPrint('Error clearing user: $e');
    }
  }

  Future<void> saveEmail(String email) async {
    try {
      await _storage.write(key: AppConstants.emailKey, value: email);
    } catch (e) {
      debugPrint('Error saving email: $e');
    }
  }

  Future<String?> getEmail() async {
    try {
      return await _storage.read(key: AppConstants.emailKey);
    } catch (e) {
      debugPrint('Error reading email: $e');
      return null;
    }
  }

  Future<void> clearEmail() async {
    try {
      await _storage.delete(key: AppConstants.emailKey);
    } catch (e) {
      debugPrint('Error clearing email: $e');
    }
  }

  Future<void> saveRefreshToken(String token) async {
    try {
      await _storage.write(key: AppConstants.refreshTokenKey, value: token);
    } catch (e) {
      debugPrint('Error saving refresh token: $e');
    }
    _inMemoryRefreshToken = token;
  }

  Future<String?> getRefreshToken() async {
    try {
      final stored = await _storage.read(key: AppConstants.refreshTokenKey);
      if (stored != null && stored.isNotEmpty) {
        _inMemoryRefreshToken = stored;
        return stored;
      }
    } catch (e) {
      debugPrint('Error reading refresh token: $e');
    }
    return _inMemoryRefreshToken;
  }

  Future<void> clearRefreshToken() async {
    try {
      await _storage.delete(key: AppConstants.refreshTokenKey);
    } catch (e) {
      debugPrint('Error clearing refresh token: $e');
    }
    _inMemoryRefreshToken = null;
  }

  Future<void> setCurrentQuickAuthUserId(String userId) async {
    try {
      await _storage.write(key: _quickAuthCurrentUserIdKey, value: userId);
    } catch (e) {
      debugPrint('Error saving current quick auth user id: $e');
    }
  }

  Future<String?> getCurrentQuickAuthUserId() async {
    try {
      return await _storage.read(key: _quickAuthCurrentUserIdKey);
    } catch (e) {
      debugPrint('Error reading current quick auth user id: $e');
      return null;
    }
  }

  Future<void> clearCurrentQuickAuthUserId() async {
    try {
      await _storage.delete(key: _quickAuthCurrentUserIdKey);
    } catch (e) {
      debugPrint('Error clearing current quick auth user id: $e');
    }
  }

  Future<void> saveSessionLockTimestamp(String userId, DateTime timestamp) async {
    try {
      await _storage.write(
        key: _sessionLockKey(userId),
        value: timestamp.toUtc().toIso8601String(),
      );
    } catch (e) {
      debugPrint('Error saving session lock timestamp: $e');
    }
  }

  Future<DateTime?> getSessionLockTimestamp(String userId) async {
    try {
      final value = await _storage.read(key: _sessionLockKey(userId));
      if (value == null) return null;
      return DateTime.tryParse(value)?.toUtc();
    } catch (e) {
      debugPrint('Error reading session lock timestamp: $e');
      return null;
    }
  }

  Future<void> clearSessionLockTimestamp(String userId) async {
    try {
      await _storage.delete(key: _sessionLockKey(userId));
    } catch (e) {
      debugPrint('Error clearing session lock timestamp: $e');
    }
  }

  Future<void> clearSessionPreserveQuickAuth({bool removeStoredUser = false}) async {
    await clearToken();
    await clearRefreshToken();
    if (removeStoredUser) {
      await clearUser();
      await clearEmail();
    }
  }

  Future<void> saveLanguage(String language) async {
    try {
      await _storage.write(key: AppConstants.languageKey, value: language);
    } catch (e) {
      debugPrint('Error saving language: $e');
    }
  }

  Future<String?> getLanguage() async {
    try {
      return await _storage.read(key: AppConstants.languageKey);
    } catch (e) {
      debugPrint('Error reading language: $e');
      return null;
    }
  }

  /// Clears all auth/session data but preserves device-level Quick Auth setup flags
  Future<void> clearAll() async {
    try {
      // Read all keys
      final allData = await _storage.readAll();
      
      // Filter and save quick auth setup_completed flags
      final quickAuthSetupFlags = <String, String>{};
      allData.forEach((key, value) {
        if (key.startsWith('quick_auth_') && key.endsWith('_setup_completed')) {
          quickAuthSetupFlags[key] = value;
        }
      });
      
      // Clear everything
      await _storage.deleteAll();
      
      // Restore setup_completed flags (device-level, should persist across logins)
      for (final entry in quickAuthSetupFlags.entries) {
        await _storage.write(key: entry.key, value: entry.value);
      }
      
      debugPrint('✅ Cleared all storage (preserved ${quickAuthSetupFlags.length} quick auth setup flags)');
    } catch (e) {
      debugPrint('Error clearing all storage: $e');
    }
  }
}
