import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:opei/core/providers/providers.dart';
import 'package:opei/core/services/quick_auth_service.dart';
import 'package:opei/core/storage/secure_storage_service.dart';
import 'package:opei/data/models/auth_response.dart';
import 'package:opei/data/models/user_model.dart';
import 'package:opei/data/repositories/auth_repository.dart';
import 'package:opei/features/auth/quick_auth/quick_auth_controller.dart';
import 'package:opei/features/auth/quick_auth/quick_auth_state.dart';

class _MockQuickAuthService extends Mock implements QuickAuthService {}

class _MockAuthRepository extends Mock implements AuthRepository {}

class _MockSecureStorageService extends Mock implements SecureStorageService {}

void main() {
  late _MockQuickAuthService quickAuthService;
  late _MockAuthRepository authRepository;
  late _MockSecureStorageService storage;
  late UserModel user;
  late AuthResponse authResponse;

  ProviderContainer _createContainer() {
    return ProviderContainer(
      overrides: [
        quickAuthServiceProvider.overrideWithValue(quickAuthService),
        authRepositoryProvider.overrideWithValue(authRepository),
        secureStorageServiceProvider.overrideWithValue(storage),
      ],
    );
  }

  setUp(() {
    quickAuthService = _MockQuickAuthService();
    authRepository = _MockAuthRepository();
    storage = _MockSecureStorageService();
    user = UserModel(
      id: 'user-123',
      email: 'tester@example.com',
      phone: '+15555555555',
      role: 'user',
      status: 'active',
      userStage: 'VERIFIED',
      isEmailVerified: true,
      isPhoneVerified: true,
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 2),
    );
    authResponse = AuthResponse(
      accessToken: 'access-token',
      refreshToken: 'new-refresh-token',
      user: user,
    );

    registerFallbackValue(user);
  });

  group('QuickAuthController', () {
    test('verifies PIN successfully and updates auth session', () async {
      when(() => storage.getUser()).thenAnswer((_) async => user);
      when(() => quickAuthService.verifyPin(user.id, any()))
          .thenAnswer((_) async => true);
      when(() => storage.getRefreshToken()).thenAnswer((_) async => 'refresh');
      when(() => authRepository.refreshAccessToken('refresh'))
          .thenAnswer((_) async => authResponse);
      when(() => storage.saveUser(user)).thenAnswer((_) async {});

      final container = _createContainer();
      addTearDown(container.dispose);
      final listener = _attachListener(container);
      addTearDown(listener.close);
      final controller = container.read(quickAuthControllerProvider.notifier);

      for (final digit in '123456'.split('')) {
        controller.addDigit(digit);
      }

      await Future<void>.delayed(Duration.zero);

      expect(container.read(quickAuthControllerProvider), isA<QuickAuthSuccess>());
      verify(() => quickAuthService.verifyPin(user.id, '123456')).called(1);
      verify(() => authRepository.refreshAccessToken('refresh')).called(1);
    });

    test('shows error then resets input after invalid PIN attempt', () {
      fakeAsync((async) {
        when(() => storage.getUser()).thenAnswer((_) async => user);
        when(() => quickAuthService.verifyPin(user.id, any()))
            .thenAnswer((_) async => false);

        final container = _createContainer();
        addTearDown(container.dispose);
        final listener = _attachListener(container);
        addTearDown(listener.close);
        final controller = container.read(quickAuthControllerProvider.notifier);

        _enterPin(controller);
        async.flushMicrotasks();

        final currentState = container.read(quickAuthControllerProvider);
        expect(currentState, isA<QuickAuthPinEntry>());
        expect((currentState as QuickAuthPinEntry).errorMessage,
            contains('attempt'));

        async.elapse(const Duration(milliseconds: 1600));
        final resetState = container.read(quickAuthControllerProvider);
        expect(resetState, isA<QuickAuthPinEntry>());
        expect((resetState as QuickAuthPinEntry).errorMessage, isNull);
      });
    });

    test('forces logout after exceeding max PIN attempts', () {
      fakeAsync((async) {
        when(() => storage.getUser()).thenAnswer((_) async => user);
        when(() => quickAuthService.verifyPin(user.id, any()))
            .thenAnswer((_) async => false);
        when(() => authRepository.logout()).thenAnswer((_) async {});

        final container = _createContainer();
        addTearDown(container.dispose);
        final listener = _attachListener(container);
        addTearDown(listener.close);
        final controller = container.read(quickAuthControllerProvider.notifier);

        for (var i = 0; i < 5; i++) {
          _enterPin(controller);
          async.flushMicrotasks();
          async.elapse(const Duration(milliseconds: 1600));
        }

        final state = container.read(quickAuthControllerProvider);
        expect(state, isA<QuickAuthFailed>());
        verify(() => authRepository.logout()).called(1);
      });
    });
  });
}

void _enterPin(QuickAuthController controller) {
  for (final digit in '123456'.split('')) {
    controller.addDigit(digit);
  }
}

ProviderSubscription<QuickAuthState> _attachListener(ProviderContainer container) {
  return container.listen(
    quickAuthControllerProvider,
    (_, __) {},
    fireImmediately: true,
  );
}
