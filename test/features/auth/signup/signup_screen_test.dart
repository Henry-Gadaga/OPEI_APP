import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:opei/features/auth/signup/signup_controller.dart';
import 'package:opei/features/auth/signup/signup_screen.dart';
import 'package:opei/features/auth/signup/signup_state.dart';
import 'package:opei/theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SignupScreen', () {
    testWidgets('shows validation errors when submitting empty form', (tester) async {
      var signupCalled = false;
      final controller = _FakeSignupController(
        initialState: SignupInitial(),
        onSignup: (controller, email, phone, password) async => signupCalled = true,
      );

      await _pumpSignupScreen(tester, controller: controller);

      await tester.tap(find.widgetWithText(ElevatedButton, 'Create account'));
      await tester.pump();

      expect(signupCalled, isFalse);
      expect(find.text('Email is required'), findsOneWidget);
      expect(find.text('Phone number is required'), findsOneWidget);
      expect(find.text('Password is required'), findsOneWidget);
    });

    testWidgets('tapping Terms and Privacy links navigates correctly', (tester) async {
      final router = await _pumpSignupScreen(tester);

      await tester.tap(find.text('Terms'));
      await tester.pumpAndSettle();
      expect(find.text('terms-screen'), findsOneWidget);

      router.pop();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Privacy Policy'));
      await tester.pumpAndSettle();
      expect(find.text('privacy-screen'), findsOneWidget);
    });

    testWidgets('submits form and calls signup controller', (tester) async {
      String? capturedEmail;
      String? capturedPhone;
      String? capturedPassword;

      final fakeController = _FakeSignupController(
        initialState: SignupInitial(),
        onSignup: (_, email, phone, password) async {
          capturedEmail = email;
          capturedPhone = phone;
          capturedPassword = password;
        },
      );

      await _pumpSignupScreen(tester, controller: fakeController);

      await tester.enterText(find.byType(TextFormField).at(0), 'user@example.com');
      await tester.enterText(find.byType(TextFormField).at(1), '+1234567890');
      await tester.enterText(find.byType(TextFormField).at(2), 'Password1!');

      await tester.tap(find.widgetWithText(ElevatedButton, 'Create account'));
      await tester.pump();

      expect(capturedEmail, 'user@example.com');
      expect(capturedPhone, '+1234567890');
      expect(capturedPassword, 'Password1!');
    });
  });
}

class _FakeSignupController extends SignupController {
  _FakeSignupController({
    required this.initialState,
    this.onSignup,
  });

  final SignupState initialState;
  final Future<void> Function(
    _FakeSignupController controller,
    String email,
    String phone,
    String password,
  )? onSignup;

  @override
  SignupState build() => initialState;

  @override
  Future<void> signup({
    required String email,
    required String phone,
    required String password,
  }) async {
    if (onSignup != null) {
      await onSignup!(this, email, phone, password);
    }
  }

  @override
  void reset() {
    state = SignupInitial();
  }
}

Future<GoRouter> _pumpSignupScreen(
  WidgetTester tester, {
  _FakeSignupController? controller,
}) async {
  await tester.binding.setSurfaceSize(const Size(430, 900));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  final router = GoRouter(
    initialLocation: '/signup',
    routes: [
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/terms',
        builder: (context, state) => const _StubScreen(label: 'terms-screen'),
      ),
      GoRoute(
        path: '/privacy',
        builder: (context, state) => const _StubScreen(label: 'privacy-screen'),
      ),
    ],
  );
  addTearDown(router.dispose);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        if (controller != null)
          signupControllerProvider.overrideWith(() => controller),
      ],
      child: MaterialApp.router(
        routerConfig: router,
        theme: ThemeData.from(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        ).copyWith(
          textTheme: ThemeData.light().textTheme.copyWith(
                bodyMedium: ThemeData.light()
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: OpeiColors.pureBlack),
              ),
        ),
      ),
    ),
  );

  await tester.pumpAndSettle();
  return router;
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
