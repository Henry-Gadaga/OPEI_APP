import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:opei/core/network/api_client.dart';
import 'package:opei/core/services/quick_auth_service.dart';
import 'package:opei/core/services/session_lock_service.dart';
import 'package:opei/core/storage/secure_storage_service.dart';
import 'package:opei/data/repositories/address_repository.dart';
import 'package:opei/data/repositories/auth_repository.dart';
import 'package:opei/data/repositories/kyc_repository.dart';
import 'package:opei/data/repositories/password_reset_repository.dart';
import 'package:opei/data/repositories/user_repository.dart';
import 'package:opei/data/repositories/transfer_repository.dart';
import 'package:opei/data/repositories/card_repository.dart';
import 'package:opei/data/repositories/crypto_repository.dart';
import 'package:opei/data/repositories/p2p_repository.dart';
import 'package:opei/data/repositories/wallet_repository.dart';
import 'package:opei/data/repositories/transaction_repository.dart';
import 'package:opei/features/profile/profile_controller.dart';

export 'package:opei/data/repositories/auth_repository.dart';
export 'package:opei/features/address/address_controller.dart';
export 'package:opei/features/auth/verify_email/verify_email_controller.dart';
export 'package:opei/features/kyc/kyc_controller.dart';
export 'package:opei/features/profile/profile_controller.dart';

// Auth Session State to track login/logout changes
enum QuickAuthStatus {
  unknown,
  requiresSetup,
  requiresVerification,
  satisfied,
}

class AuthSession {
  final String? userId;
  final String? accessToken;
  final String? userStage;
  final int sessionNonce;

  bool get isAuthenticated => userId != null && accessToken != null;

  const AuthSession({
    this.userId,
    this.accessToken,
    this.userStage,
    this.sessionNonce = 0,
  });

  AuthSession copyWith({
    String? userId,
    String? accessToken,
    String? userStage,
    int? sessionNonce,
  }) {
    return AuthSession(
      userId: userId ?? this.userId,
      accessToken: accessToken ?? this.accessToken,
      userStage: userStage ?? this.userStage,
      sessionNonce: sessionNonce ?? this.sessionNonce,
    );
  }
}

class QuickAuthStatusNotifier extends Notifier<QuickAuthStatus> {
  @override
  QuickAuthStatus build() => QuickAuthStatus.unknown;

  void setStatus(QuickAuthStatus status) => state = status;

  void reset() => setStatus(QuickAuthStatus.unknown);
}

final quickAuthStatusProvider =
    NotifierProvider<QuickAuthStatusNotifier, QuickAuthStatus>(
  QuickAuthStatusNotifier.new,
);

class AuthSessionNotifier extends Notifier<AuthSession> {
  @override
  AuthSession build() => const AuthSession();

  void setSession({
    required String userId,
    required String accessToken,
    required String userStage,
  }) {
    state = AuthSession(
      userId: userId,
      accessToken: accessToken,
      userStage: userStage,
      sessionNonce: state.sessionNonce + 1,
    );
  }

  void updateUserStage(String userStage) {
    if (state.userStage == userStage) return;
    state = state.copyWith(
      userStage: userStage,
      sessionNonce: state.sessionNonce + 1,
    );
  }

  void clearSession() {
    state = AuthSession(
      userId: null,
      accessToken: null,
      userStage: null,
      sessionNonce: state.sessionNonce + 1,
    );
    ref.read(quickAuthStatusProvider.notifier).reset();
  }
}

final authSessionProvider = NotifierProvider<AuthSessionNotifier, AuthSession>(
  AuthSessionNotifier.new,
);

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage(
    aOptions: AndroidOptions(),
  );
});

final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  final storage = ref.watch(secureStorageProvider);
  return SecureStorageService(storage);
});

final localAuthProvider = Provider<LocalAuthentication>((ref) {
  return LocalAuthentication();
});

final quickAuthServiceProvider = Provider<QuickAuthService>((ref) {
  final storage = ref.watch(secureStorageProvider);
  final localAuth = ref.watch(localAuthProvider);
  return QuickAuthService(storage, localAuth);
});

final sessionLockServiceProvider = Provider<SessionLockService>((ref) {
  final storageService = ref.watch(secureStorageServiceProvider);
  final quickAuthService = ref.watch(quickAuthServiceProvider);
  return SessionLockService(storageService, quickAuthService);
});

final apiClientProvider = Provider<ApiClient>((ref) {
  final storage = ref.watch(secureStorageServiceProvider);
  return ApiClient(storage);
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final storage = ref.watch(secureStorageServiceProvider);
  final quickAuthService = ref.watch(quickAuthServiceProvider);
  return AuthRepository(apiClient, storage, quickAuthService);
});

final addressRepositoryProvider = Provider<AddressRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final storage = ref.watch(secureStorageServiceProvider);
  return AddressRepository(apiClient, storage);
});

final kycRepositoryProvider = Provider<KycRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return KycRepository(apiClient);
});

final passwordResetRepositoryProvider =
    Provider<PasswordResetRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return PasswordResetRepository(apiClient);
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return UserRepository(apiClient);
});

final transferRepositoryProvider = Provider<TransferRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return TransferRepository(apiClient);
});

final cryptoRepositoryProvider = Provider<CryptoRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return CryptoRepository(apiClient);
});

final walletRepositoryProvider = Provider<WalletRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return WalletRepository(apiClient);
});

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return TransactionRepository(apiClient);
});

final p2pRepositoryProvider = Provider<P2PRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final storage = ref.watch(secureStorageServiceProvider);
  return P2PRepository(apiClient, storage);
});

final cardRepositoryProvider = Provider<CardRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return CardRepository(apiClient);
});

final profileControllerProvider =
    NotifierProvider<ProfileController, ProfileState>(
  ProfileController.new,
);
