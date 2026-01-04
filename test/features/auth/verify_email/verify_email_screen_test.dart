import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:opei/core/providers/providers.dart';
import 'package:opei/features/auth/verify_email/verify_email_controller.dart';
import 'package:opei/features/auth/verify_email/verify_email_screen.dart';
import 'package:opei/features/auth/verify_email/verify_email_state.dart';
import 'package:opei/core/storage/secure_storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('VerifyEmailScreen', () {
    testWidgets('renders provided email and code inputs', (tester) async {
      final harness = await _pumpVerifyEmailScreen(
        tester,
        initialState: VerifyEmailState.initial('user@example.com'),
      );

      expect(find.text('user@example.com'), findsOneWidget);
      expect(find.byType(CodeInputBox), findsNWidgets(6));
      harness.dispose();
    });

    testWidgets('tapping Resend invokes controller resendCode', (tester) async {
      final notifier = _TestVerifyEmailNotifier(
        VerifyEmailState.initial('user@example.com'),
      );
      final harness = await _pumpVerifyEmailScreen(
        tester,
        notifier: notifier,
      );

      final resendFinder = find.text('Resend');
      await tester.ensureVisible(resendFinder);
      await tester.tap(resendFinder);
      await tester.pump();

      expect(notifier.resendCalled, isTrue);
      harness.dispose();
    });

    testWidgets('successful verification navigates to address screen', (tester) async {
      final notifier = _TestVerifyEmailNotifier(
        VerifyEmailState.initial('user@example.com'),
      );
      final harness = await _pumpVerifyEmailScreen(
        tester,
        notifier: notifier,
      );

      notifier.state = notifier.state.copyWith(isVerifying: true);
      await tester.pump();
      notifier.state = notifier.state.copyWith(isVerifying: false, clearError: true);
      await tester.pumpAndSettle();

      expect(find.text('Address Screen'), findsOneWidget);
      harness.dispose();
    });
  });
}

class _VerifyEmailScreenHarness {
  _VerifyEmailScreenHarness({required this.router, required this.notifier, required this.secureStorage});

  final GoRouter router;
  final _TestVerifyEmailNotifier notifier;
  final _TestSecureStorageService secureStorage;

  void dispose() {
    router.dispose();
  }
}

Future<_VerifyEmailScreenHarness> _pumpVerifyEmailScreen(
  WidgetTester tester, {
  VerifyEmailState? initialState,
  _TestVerifyEmailNotifier? notifier,
}) async {
  final testNotifier = notifier ?? _TestVerifyEmailNotifier(initialState ?? VerifyEmailState.initial('user@example.com'));
  final storage = _TestSecureStorageService();
  final router = GoRouter(
    initialLocation: '/verify-email',
    routes: [
      GoRoute(
        path: '/verify-email',
        builder: (_, __) => const VerifyEmailScreen(email: 'user@example.com'),
      ),
      GoRoute(
        path: '/address',
        builder: (_, __) => const _StubScreen(label: 'Address Screen'),
      ),
      GoRoute(
        path: '/login',
        builder: (_, __) => const _StubScreen(label: 'Login Screen'),
      ),
    ],
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        verifyEmailControllerProvider.overrideWith(() => testNotifier),
        secureStorageServiceProvider.overrideWith((_) => storage),
      ],
      child: MaterialApp.router(
        routerConfig: router,
        theme: ThemeData.from(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        ),
      ),
    ),
  );

  await tester.pumpAndSettle();

  return _VerifyEmailScreenHarness(router: router, notifier: testNotifier, secureStorage: storage);
}

class _TestVerifyEmailNotifier extends VerifyEmailNotifier {
  _TestVerifyEmailNotifier(this._initialState);

  final VerifyEmailState _initialState;
  bool resendCalled = false;

  @override
  VerifyEmailState build() => _initialState;

  @override
  Future<void> initialize(String email, {bool autoSendCode = false}) async {
    state = state.copyWith(email: email);
  }

  @override
  Future<bool> resendCode() async {
    resendCalled = true;
    state = state.copyWith(isResending: false);
    return true;
  }

  @override
  Future<bool> verifyCode() async {
    state = state.copyWith(isVerifying: false);
    return true;
  }
}

class _TestSecureStorageService extends SecureStorageService {
  _TestSecureStorageService() : super(const FlutterSecureStorage());

  String? _email;

  @override
  Future<void> saveEmail(String email) async {
    _email = email;
  }

  @override
  Future<String?> getEmail() async => _email;

  @override
  Future<void> clearEmail() async {
    _email = null;
  }
}

class _StubScreen extends StatelessWidget {
  const _StubScreen({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text(label)),
    );
  }
}
