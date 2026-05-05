import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:opei/features/auth/signup/signup_controller.dart';
import 'package:opei/features/auth/signup/signup_screen.dart';
import 'package:opei/features/auth/signup/signup_state.dart';
import 'package:opei/theme.dart';
import 'package:opei/widgets/opei_premium/opei_premium.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SignupScreen', () {
    testWidgets(
        'Continue button is disabled when the form is empty',
        (tester) async {
      var signupCalled = false;
      final controller = _FakeSignupController(
        initialState: SignupInitial(),
        onSignup: (_, _, _, _) async => signupCalled = true,
      );

      await _pumpSignupScreen(tester, controller: controller);

      // The primary CTA renders the label "Continue" (not "Create account"
      // — that label lives on the Welcome screen).
      expect(find.text('Continue'), findsOneWidget);

      // With all fields empty, the button is disabled (onPressed == null) so
      // the controller cannot be invoked.
      final button = tester.widget<OpeiPrimaryButton>(
        find.byType(OpeiPrimaryButton),
      );
      expect(button.onPressed, isNull);
      expect(signupCalled, isFalse);
    });

    testWidgets('tapping Sign in routes to login', (tester) async {
      await _pumpSignupScreen(tester);

      await tester.tap(find.text('Sign in'));
      await tester.pumpAndSettle();

      expect(find.text('login-screen'), findsOneWidget);
    });

    testWidgets(
        'submitting a valid form calls signup controller with PIN',
        (tester) async {
      String? capturedEmail;
      String? capturedPhone;
      String? capturedPin;

      final fakeController = _FakeSignupController(
        initialState: SignupInitial(),
        onSignup: (_, email, phone, pin) async {
          capturedEmail = email;
          capturedPhone = phone;
          capturedPin = pin;
        },
      );

      await _pumpSignupScreen(tester, controller: fakeController);

      // Field order on screen: email -> phone (custom widget with one
      // TextFormField inside) -> 6-digit PIN.
      final fields = find.byType(TextFormField);
      expect(fields, findsNWidgets(3));

      await tester.enterText(fields.at(0), 'user@example.com');
      await tester.enterText(fields.at(1), '8012345678');
      await tester.enterText(fields.at(2), '123456');
      await tester.pump();

      await tester.tap(find.byType(OpeiPrimaryButton));
      await tester.pump();

      expect(capturedEmail, 'user@example.com');
      // Default ISO is Nigeria (+234) so the controller should receive the
      // E.164-formatted number.
      expect(capturedPhone, isNotNull);
      expect(capturedPhone, contains('80'));
      expect(capturedPin, '123456');
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
    String pin,
  )? onSignup;

  @override
  SignupState build() => initialState;

  @override
  Future<void> signup({
    required String email,
    required String phone,
    required String pin,
  }) async {
    if (onSignup != null) {
      await onSignup!(this, email, phone, pin);
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
  // Larger surface so the bottom-row "Already have an account? Sign in"
  // doesn't trip Flutter's overflow assertion under Ahem (the test-time
  // font is wider per glyph than the production Outfit font).
  await tester.binding.setSurfaceSize(const Size(720, 1200));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  final router = GoRouter(
    initialLocation: '/signup',
    routes: [
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const _StubScreen(label: 'welcome-screen'),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const _StubScreen(label: 'login-screen'),
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
