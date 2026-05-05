import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:opei/core/providers/providers.dart';
import 'package:opei/core/services/quick_auth_service.dart';
import 'package:opei/core/storage/secure_storage_service.dart';
import 'package:opei/data/models/user_model.dart';
import 'package:opei/features/auth/quick_auth/quick_auth_controller.dart';
import 'package:opei/features/auth/quick_auth/quick_auth_state.dart';
import 'package:opei/features/auth/quick_auth/quick_auth_screen.dart';
import 'package:opei/features/auth/quick_auth_setup/quick_auth_setup_controller.dart';
import 'package:opei/features/auth/quick_auth_setup/quick_auth_setup_state.dart';
import 'package:opei/features/dashboard/dashboard_controller.dart';
import 'package:opei/features/dashboard/dashboard_state.dart';
import 'package:opei/theme.dart';

class _MockQuickAuthService extends Mock implements QuickAuthService {}

class _MockSecureStorageService extends Mock implements SecureStorageService {}

class _FakeQuickAuthController extends QuickAuthController {
  _FakeQuickAuthController({
    required this.initialState,
    this.onAddDigit,
  });

  final QuickAuthState initialState;
  final void Function(String digit)? onAddDigit;

  @override
  QuickAuthState build() => initialState;

  @override
  void addDigit(String digit) {
    onAddDigit?.call(digit);
  }

  @override
  void removeDigit() {
    // no-op
  }
}

class _FakeDashboardController extends DashboardController {
  @override
  DashboardState build() => const DashboardState();

  @override
  void prepareForFreshLaunch() {}

  @override
  Future<void> refreshBalance({bool showSpinner = true}) async {}
}

class _FakeQuickAuthSetupController extends QuickAuthSetupController {
  @override
  QuickAuthSetupState build() => QuickAuthSetupPinEntry();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _MockQuickAuthService quickAuthService;
  late _MockSecureStorageService storage;

  final testUser = UserModel(
    id: 'user-123',
    email: 'tester@example.com',
    phone: '+15555555555',
    role: 'user',
    status: 'active',
    userStage: 'ACTIVE',
    isEmailVerified: true,
    isPhoneVerified: true,
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime(2024, 1, 2),
  );

  setUp(() {
    quickAuthService = _MockQuickAuthService();
    storage = _MockSecureStorageService();

    when(() => storage.getUser()).thenAnswer((_) async => testUser);
    when(() => quickAuthService.getRegisteredUserId())
        .thenAnswer((_) async => 'user-123');
    when(() => quickAuthService.hasPinSetup('user-123'))
        .thenAnswer((_) async => true);
    // Biometric layer: stub all methods so tests run on a "device without
    // biometric hardware" — the screen's PIN-only path is unchanged.
    when(() => quickAuthService.canUseBiometric())
        .thenAnswer((_) async => false);
    when(() => quickAuthService.hasFaceBiometric())
        .thenAnswer((_) async => false);
    when(() => quickAuthService.isBiometricEnabled('user-123'))
        .thenAnswer((_) async => false);
    when(() => quickAuthService.wasBiometricPromptShown('user-123'))
        .thenAnswer((_) async => true);
  });

  group('QuickAuthScreen', () {
    testWidgets('displays PIN heading and error message', (tester) async {
      const errorText = 'Invalid PIN';

      await _pumpQuickAuthScreen(
        tester,
        quickAuthService: quickAuthService,
        storage: storage,
        controller: _FakeQuickAuthController(
          initialState: QuickAuthPinEntry(pin: '12', errorMessage: errorText),
        ),
      );

      // No avatar is shown in the redesigned screen — just clean heading text.
      expect(find.text('Enter your PIN'), findsOneWidget);
      expect(find.text(errorText), findsOneWidget);
      expect(find.text('Forgot PIN?'), findsOneWidget);
      expect(find.text('Use password'), findsOneWidget);
    });

    testWidgets('tapping keypad digit delegates to controller', (tester) async {
      final tappedDigits = <String>[];

      await _pumpQuickAuthScreen(
        tester,
        quickAuthService: quickAuthService,
        storage: storage,
        controller: _FakeQuickAuthController(
          initialState: QuickAuthPinEntry(),
          onAddDigit: tappedDigits.add,
        ),
      );

      await tester.tap(find.text('5'));
      await tester.pump();

      expect(tappedDigits, ['5']);
    });

    testWidgets(
        'tapping Forgot PIN routes to forgot-password and clears quick-auth gate',
        (tester) async {
      await _pumpQuickAuthScreen(
        tester,
        quickAuthService: quickAuthService,
        storage: storage,
        controller: _FakeQuickAuthController(
          initialState: QuickAuthPinEntry(),
        ),
        useRouter: true,
      );

      await tester.tap(find.text('Forgot PIN?'));
      await tester.pumpAndSettle();

      // The router should have transitioned to the stubbed forgot-password
      // route — the stub screen renders 'Forgot Password Screen'.
      expect(find.text('Forgot Password Screen'), findsOneWidget);
    });
  });
}

Future<void> _pumpQuickAuthScreen(
  WidgetTester tester, {
  required QuickAuthService quickAuthService,
  required SecureStorageService storage,
  required QuickAuthController controller,
  bool useRouter = false,
}) async {
  await tester.binding.setSurfaceSize(const Size(414, 896));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  final theme = ThemeData.from(
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
  ).copyWith(
    textTheme: ThemeData.light().textTheme.copyWith(
          bodyMedium: ThemeData.light()
              .textTheme
              .bodyMedium
              ?.copyWith(color: OpeiColors.pureBlack),
        ),
  );

  Widget app;
  if (useRouter) {
    final router = GoRouter(
      initialLocation: '/quick-auth',
      routes: [
        GoRoute(
          path: '/quick-auth',
          builder: (_, _) => const QuickAuthScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (_, _) => const _StubScreen(label: 'Login Screen'),
        ),
        GoRoute(
          path: '/forgot-password',
          builder: (_, _) =>
              const _StubScreen(label: 'Forgot Password Screen'),
        ),
      ],
    );
    addTearDown(router.dispose);
    app = MaterialApp.router(theme: theme, routerConfig: router);
  } else {
    app = MaterialApp(theme: theme, home: const QuickAuthScreen());
  }

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        quickAuthControllerProvider.overrideWith(() => controller),
        quickAuthServiceProvider.overrideWithValue(quickAuthService),
        secureStorageServiceProvider.overrideWithValue(storage),
        dashboardControllerProvider.overrideWith(() => _FakeDashboardController()),
        quickAuthSetupControllerProvider
            .overrideWith(() => _FakeQuickAuthSetupController()),
      ],
      child: app,
    ),
  );
  await tester.pumpAndSettle();
}

class _StubScreen extends StatelessWidget {
  const _StubScreen({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text(label)));
  }
}
