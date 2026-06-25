import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:opei/features/auth/login/login_controller.dart';
import 'package:opei/features/auth/login/login_screen.dart';
import 'package:opei/features/auth/login/login_state.dart';
import 'package:opei/widgets/opei_premium/opei_premium.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Login flow integration', () {
    testWidgets(
        'Sign in button is disabled when the form is empty',
        (tester) async {
      var loginCalled = false;

      await _pumpLoginFlowApp(
        tester,
        onLogin: (_) async {
          loginCalled = true;
          return null;
        },
      );

      // Primary CTA is the OpeiPrimaryButton labeled "Sign in" — disabled
      // until both a valid email and a 6-digit PIN are entered.
      final button = tester.widget<OpeiPrimaryButton>(
        find.byType(OpeiPrimaryButton),
      );
      expect(button.onPressed, isNull);

      // Tapping it (or its label) is a no-op while disabled, so the
      // controller is never invoked. The redesigned screen also has a
      // page-title "Sign in" header, so we scope the tap to the CTA.
      await tester.tap(find.byType(OpeiPrimaryButton));
      await tester.pump();
      expect(loginCalled, isFalse);
    });

    testWidgets(
        'navigates to verify email when backend reports pending email stage',
        (tester) async {
      await _pumpLoginFlowApp(
        tester,
        onLogin: (_) async => {
          'success': true,
          'userStage': 'PENDING_EMAIL',
        },
      );

      // Login screen now uses email + 6-digit PIN (not arbitrary password).
      final fields = find.byType(TextFormField);
      expect(fields, findsNWidgets(2));
      await tester.enterText(fields.at(0), 'tester@example.com');
      await tester.enterText(fields.at(1), '123456');
      await tester.pump();

      await tester.tap(find.byType(OpeiPrimaryButton));
      await tester.pumpAndSettle();

      expect(find.text('verify-email:autoSend=true'), findsOneWidget);
    });
  });
}

Future<void> _pumpLoginFlowApp(
  WidgetTester tester, {
  Future<Map<String, dynamic>?> Function(LoginState state)? onLogin,
}) async {
  // Wider surface so the bottom "New to Opei? Create account" row doesn't
  // hit the layout-overflow assertion under the test-time Ahem font.
  await tester.binding.setSurfaceSize(const Size(720, 1200));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  final router = GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/verify-email',
        builder: (context, state) {
          final autoSend = state.uri.queryParameters['autoSend'];
          return _StubScreen(label: 'verify-email:autoSend=$autoSend');
        },
      ),
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const _StubScreen(label: 'welcome-screen'),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const _StubScreen(label: 'signup-screen'),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) =>
            const _StubScreen(label: 'forgot-password-screen'),
      ),
    ],
  );
  addTearDown(router.dispose);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        loginControllerProvider.overrideWith(
          () => _TestLoginController(
            onLogin: onLogin ??
                (_) async => {
                      'success': true,
                      'userStage': 'PENDING_EMAIL',
                    },
          ),
        ),
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
}

class _TestLoginController extends LoginController {
  _TestLoginController({required this.onLogin});

  final Future<Map<String, dynamic>?> Function(LoginState state) onLogin;

  @override
  Future<Map<String, dynamic>?> login() async {
    state = state.copyWith(isLoading: true, clearErrors: true);
    try {
      final result = await onLogin(state);
      state = state.copyWith(isLoading: false);
      return result;
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Something went wrong. Please try again.',
      );
      return null;
    }
  }
}

class _StubScreen extends StatelessWidget {
  const _StubScreen({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(child: Text(label)),
    );
  }
}
