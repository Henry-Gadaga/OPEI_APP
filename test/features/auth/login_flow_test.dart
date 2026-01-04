import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:opei/core/providers/providers.dart';
import 'package:opei/features/auth/login/login_controller.dart';
import 'package:opei/features/auth/login/login_screen.dart';
import 'package:opei/features/auth/login/login_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Login flow integration', () {
    testWidgets('shows validation errors when attempting empty login', (tester) async {
      await _pumpLoginFlowApp(tester);

      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      expect(find.text('Email is required'), findsOneWidget);
      expect(find.text('Password is required'), findsOneWidget);
    });

    testWidgets('navigates to verify email when backend reports pending email stage', (tester) async {
      await _pumpLoginFlowApp(
        tester,
        onLogin: (_) async => {
          'success': true,
          'userStage': 'PENDING_EMAIL',
        },
      );

      await tester.enterText(find.byType(TextField).at(0), 'tester@example.com');
      await tester.enterText(find.byType(TextField).at(1), 'password123');
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      expect(find.text('verify-email:autoSend=true'), findsOneWidget);
    });
  });
}

Future<void> _pumpLoginFlowApp(
  WidgetTester tester, {
  Future<Map<String, dynamic>?> Function(LoginState state)? onLogin,
}) async {
  await tester.binding.setSurfaceSize(const Size(600, 1100));
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
        theme: ThemeData.from(colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo)),
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
    final validation = _validate(state);
    if (validation != null) {
      state = state.copyWith(
        emailError: validation.emailError,
        passwordError: validation.passwordError,
      );
      return null;
    }

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

  _ValidationResult? _validate(LoginState currentState) {
    String? emailError;
    String? passwordError;

    final email = currentState.email.trim();
    if (email.isEmpty) {
      emailError = 'Email is required';
    } else if (!_isValidEmail(email)) {
      emailError = 'Please enter a valid email';
    }

    final password = currentState.password;
    if (password.isEmpty) {
      passwordError = 'Password is required';
    } else if (password.length < 8) {
      passwordError = 'Password must be at least 8 characters';
    }

    if (emailError != null || passwordError != null) {
      return _ValidationResult(
        emailError: emailError,
        passwordError: passwordError,
      );
    }

    return null;
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    return emailRegex.hasMatch(email);
  }
}

class _ValidationResult {
  final String? emailError;
  final String? passwordError;

  _ValidationResult({this.emailError, this.passwordError});
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
