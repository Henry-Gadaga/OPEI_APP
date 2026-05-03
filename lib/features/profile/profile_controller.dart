import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opei/core/providers/providers.dart';
import 'package:opei/core/storage/secure_storage_service.dart';
import 'package:opei/core/utils/error_helper.dart';
import 'package:opei/data/repositories/user_repository.dart';

export 'package:opei/features/profile/profile_state.dart';

class ProfileController extends Notifier<ProfileState> {
  late UserRepository _userRepository;
  late AuthRepository _authRepository;
  late SecureStorageService _storage;

  @override
  ProfileState build() {
    _userRepository = ref.read(userRepositoryProvider);
    _authRepository = ref.read(authRepositoryProvider);
    _storage = ref.read(secureStorageServiceProvider);
    
    // Listen to auth session changes - when session changes, reload profile
    final sessionNonce = ref.watch(authSessionProvider.select((session) => session.sessionNonce));
    
    // Load profile only on first build or after login (when sessionNonce changes and user is logged in)
    Future.microtask(() {
      final hasToken = ref.read(authSessionProvider).accessToken != null;
      if (hasToken && sessionNonce > 0) {
        _loadProfile();
      }
      _loadLanguage();
    });
    
    return ProfileState();
  }

  Future<void> _loadProfile() async {
    // Don't load if already loading or already loaded
    if (state.isLoading || state.profile != null) return;
    
    state = state.copyWith(isLoading: true, error: null);

    try {
      // First get userId from /user/me
      debugPrint('👤 Fetching user ID...');
      final user = await _userRepository.getCurrentUser();
      debugPrint('✅ User ID obtained: ${user.id}');

      // Then get full profile with identity and address
      debugPrint('📋 Fetching full profile...');
      final profile = await _userRepository.getFullProfile(user.id);
      debugPrint('✅ Full profile loaded: ${profile.email}');
      debugPrint('   - Identity: ${profile.identity != null ? profile.displayName : "Not set"}');
      debugPrint('   - Address: ${profile.address != null ? profile.address!.city : "Not set"}');
      
      state = state.copyWith(profile: profile, isLoading: false);
    } catch (e, stackTrace) {
      final errorMessage = ErrorHelper.getErrorMessage(e);
      debugPrint('❌ Load profile error: $errorMessage');
      debugPrint('❌ Exception type: ${e.runtimeType}');
      debugPrint('❌ Exception details: $e');
      debugPrint('❌ Stack trace: $stackTrace');
      state = state.copyWith(
        error: errorMessage,
        isLoading: false,
      );
    }
  }

  Future<void> _loadLanguage() async {
    final language = await _storage.getLanguage();
    if (language != null) {
      state = state.copyWith(selectedLanguage: language);
    }
  }

  Future<void> refreshProfile() async {
    // Force refresh by clearing current profile first
    state = state.copyWith(profile: null, isLoading: true, error: null);
    
    try {
      // First get userId from /user/me
      debugPrint('🔄 Refreshing profile...');
      final user = await _userRepository.getCurrentUser();
      
      // Then get full profile with identity and address
      final profile = await _userRepository.getFullProfile(user.id);
      debugPrint('✅ Profile refreshed: ${profile.email}');
      
      state = state.copyWith(profile: profile, isLoading: false);
    } catch (e) {
      final errorMessage = ErrorHelper.getErrorMessage(e);
      debugPrint('❌ Refresh profile error: $errorMessage');
      state = state.copyWith(error: errorMessage, isLoading: false);
    }
  }

  Future<void> setLanguage(String language) async {
    await _storage.saveLanguage(language);
    state = state.copyWith(selectedLanguage: language);
  }

  Future<bool> logout() async {
    state = state.copyWith(isLoggingOut: true);

    debugPrint('🚪 Logging out...');
    
    // Try to logout from backend (ignore errors - local cleanup is what matters)
    try {
      await _authRepository.logout();
      debugPrint('✅ Backend logout successful');
    } catch (e) {
      debugPrint('⚠️ Backend logout failed (continuing anyway): $e');
    }
    
    // Invalidate auth session first - this will trigger all dependent providers to reset
    ref.read(authSessionProvider.notifier).clearSession();
    debugPrint('✅ Auth session cleared');

    // Clear profile data
    state = ProfileState();
    debugPrint('✅ Profile data cleared - logout complete');
    
    return true;
  }
}
