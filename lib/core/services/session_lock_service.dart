import 'package:flutter/foundation.dart';
import 'package:tt1/core/services/quick_auth_service.dart';
import 'package:tt1/core/storage/secure_storage_service.dart';

enum SessionLockOutcome {
  none,
  quickAuth,
  forceLogout,
}

class SessionLockService {
  SessionLockService(
    this._storage,
    this._quickAuthService,
  );

  static const Duration inactivityThreshold = Duration(minutes: 1);

  final SecureStorageService _storage;
  final QuickAuthService _quickAuthService;

  Future<void> handleAppPaused() async {
    final userId = await _resolveActiveUserId();
    if (userId == null) return;

    final now = DateTime.now().toUtc();
    await _storage.saveSessionLockTimestamp(userId, now);
    debugPrint('⏸️ Session timestamp saved for $userId');
  }

  Future<SessionLockOutcome> handleAppResumed() async {
    final refreshToken = await _storage.getRefreshToken();
    if (refreshToken == null) {
      return SessionLockOutcome.none;
    }

    final userId = await _resolveActiveUserId();
    if (userId == null) {
      return SessionLockOutcome.none;
    }

    final lastActive = await _storage.getSessionLockTimestamp(userId);
    final now = DateTime.now().toUtc();
    await _storage.saveSessionLockTimestamp(userId, now);

    if (lastActive == null) {
      return SessionLockOutcome.none;
    }

    final elapsed = now.difference(lastActive);
    if (elapsed < inactivityThreshold) {
      return SessionLockOutcome.none;
    }

    final hasQuickAuth = await _quickAuthService.hasPinSetup(userId);
    debugPrint(
      '▶️ App resumed for $userId | elapsed: $elapsed | hasQuickAuth: $hasQuickAuth',
    );

    if (hasQuickAuth) {
      return SessionLockOutcome.quickAuth;
    }

    await _storage.clearSessionPreserveQuickAuth(removeStoredUser: true);
    await _quickAuthService.clearRegisteredUserContextIfMatch(userId);
    return SessionLockOutcome.forceLogout;
  }

  Future<void> clearForUser(String userId) async {
    await _storage.clearSessionLockTimestamp(userId);
  }

  Future<String?> _resolveActiveUserId() async {
    final storedUser = await _storage.getUser();
    if (storedUser?.id != null && storedUser!.id.isNotEmpty) {
      return storedUser.id;
    }

    return await _quickAuthService.getRegisteredUserId();
  }
}