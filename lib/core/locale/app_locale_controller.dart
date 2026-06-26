import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opei/core/providers/providers.dart';
import 'package:opei/core/storage/secure_storage_service.dart';
import 'package:opei/data/repositories/user_repository.dart';

const String kLanguageEnglish = 'en';
const String kLanguagePortuguese = 'pt';

const Set<String> kSupportedLanguageCodes = {
  kLanguageEnglish,
  kLanguagePortuguese,
};

@immutable
class AppLocaleState {
  final String languageCode;
  final bool ready;

  const AppLocaleState({
    this.languageCode = kLanguageEnglish,
    this.ready = false,
  });

  Locale get locale => Locale(languageCode);

  AppLocaleState copyWith({String? languageCode, bool? ready}) {
    return AppLocaleState(
      languageCode: languageCode ?? this.languageCode,
      ready: ready ?? this.ready,
    );
  }
}

class AppLocaleController extends Notifier<AppLocaleState> {
  late final SecureStorageService _storage;
  late final UserRepository _userRepository;

  bool _bootstrapped = false;
  bool _syncInFlight = false;
  String? _lastSyncedUserId;

  @override
  AppLocaleState build() {
    _storage = ref.read(secureStorageServiceProvider);
    _userRepository = ref.read(userRepositoryProvider);

    if (!_bootstrapped) {
      _bootstrapped = true;
      Future.microtask(_bootstrapFromLocalOrDevice);
    }
    return const AppLocaleState();
  }

  String get currentLanguageCode => state.languageCode;

  Future<void> setLocalLanguage(String languageCode) async {
    final normalized = normalizeLanguageCode(languageCode);
    if (normalized == state.languageCode && state.ready) return;

    state = state.copyWith(languageCode: normalized, ready: true);
    await _storage.saveLanguage(normalized);
  }

  Future<void> syncFromBackend({String? userId}) async {
    if (_syncInFlight) return;
    if (userId != null && _lastSyncedUserId == userId) return;

    _syncInFlight = true;
    try {
      final remoteLanguage = await _userRepository.getLanguage();
      final normalized = normalizeLanguageCode(remoteLanguage);
      if (normalized != state.languageCode || !state.ready) {
        state = state.copyWith(languageCode: normalized, ready: true);
      } else if (!state.ready) {
        state = state.copyWith(ready: true);
      }
      await _storage.saveLanguage(normalized);
      if (userId != null) {
        _lastSyncedUserId = userId;
      }
    } finally {
      _syncInFlight = false;
    }
  }

  Future<void> updateLanguageFromProfile(String languageCode) async {
    final normalized = normalizeLanguageCode(languageCode);
    final previous = state;

    if (normalized != state.languageCode || !state.ready) {
      state = state.copyWith(languageCode: normalized, ready: true);
      await _storage.saveLanguage(normalized);
    }

    try {
      final synced = await _userRepository.setLanguage(normalized);
      final syncedNormalized = normalizeLanguageCode(synced);
      state = state.copyWith(languageCode: syncedNormalized, ready: true);
      await _storage.saveLanguage(syncedNormalized);
    } catch (_) {
      state = previous;
      await _storage.saveLanguage(previous.languageCode);
      rethrow;
    }
  }

  Future<void> _bootstrapFromLocalOrDevice() async {
    final cached = await _storage.getLanguage();
    final normalizedCached = normalizeLanguageCode(cached);
    if (cached != null && cached.trim().isNotEmpty) {
      state = state.copyWith(languageCode: normalizedCached, ready: true);
      return;
    }

    final deviceLocale = WidgetsBinding.instance.platformDispatcher.locale;
    final normalizedDevice = normalizeLanguageCode(deviceLocale.languageCode);
    state = state.copyWith(languageCode: normalizedDevice, ready: true);
  }

  static String normalizeLanguageCode(String? value) {
    final raw = (value ?? '').trim().toLowerCase();
    if (raw.startsWith(kLanguagePortuguese)) {
      return kLanguagePortuguese;
    }
    if (raw.startsWith(kLanguageEnglish)) {
      return kLanguageEnglish;
    }
    return kLanguageEnglish;
  }
}

final appLocaleControllerProvider =
    NotifierProvider<AppLocaleController, AppLocaleState>(
      AppLocaleController.new,
    );
