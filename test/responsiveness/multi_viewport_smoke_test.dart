// Multi-viewport responsiveness smoke test.
//
// Pumps the most layout-sensitive screens at the smallest, mid-range, large,
// and tablet device viewports we ship to and asserts that no layout
// exceptions (RenderFlex overflow, unbounded constraints, etc.) are thrown.
//
// Reference viewports (logical px, the unit Flutter uses):
//   • 320 × 568  — iPhone 5 / SE (1st gen) — smallest mainstream phone.
//   • 360 × 640  — Galaxy A10 / smallest common Android.
//   • 393 × 852  — iPhone 14 / 15.
//   • 430 × 932  — iPhone 15 Pro Max — tallest mainstream phone.
//   • 768 × 1024 — iPad mini portrait.
//
// If any viewport raises a Flutter framework exception during layout, the
// test will fail with the exception attached so the regression is obvious.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:opei/features/auth/signup/signup_controller.dart';
import 'package:opei/features/auth/signup/signup_screen.dart';
import 'package:opei/features/auth/signup/signup_state.dart';
import 'package:opei/features/auth/welcome/welcome_screen.dart';

const _viewports = <({String label, Size size})>[
  (label: 'iPhone SE 320x568', size: Size(320, 568)),
  (label: 'Galaxy A10 360x640', size: Size(360, 640)),
  (label: 'iPhone 14 393x852', size: Size(393, 852)),
  (label: 'iPhone 15 Pro Max 430x932', size: Size(430, 932)),
  (label: 'iPad mini 768x1024', size: Size(768, 1024)),
];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Multi-viewport responsiveness', () {
    for (final vp in _viewports) {
      testWidgets(
        'WelcomeScreen renders without overflow on ${vp.label}',
        (tester) async {
          await tester.binding.setSurfaceSize(vp.size);
          addTearDown(() => tester.binding.setSurfaceSize(null));

          final router = GoRouter(
            initialLocation: '/',
            routes: [
              GoRoute(
                path: '/',
                builder: (_, _) => const WelcomeScreen(),
              ),
              GoRoute(
                path: '/signup',
                builder: (_, _) => const _Stub('signup'),
              ),
              GoRoute(
                path: '/login',
                builder: (_, _) => const _Stub('login'),
              ),
            ],
          );
          addTearDown(router.dispose);

          await tester.pumpWidget(
            MaterialApp.router(
              routerConfig: router,
              theme: ThemeData.from(
                colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
              ),
            ),
          );
          await tester.pumpAndSettle();

          expect(tester.takeException(), isNull);
          expect(find.byType(WelcomeScreen), findsOneWidget);
          expect(find.text('Create account'), findsOneWidget);
          expect(find.text('Sign in'), findsOneWidget);
        },
      );

      testWidgets(
        'SignupScreen step 1 renders without overflow on ${vp.label}',
        (tester) async {
          await tester.binding.setSurfaceSize(vp.size);
          addTearDown(() => tester.binding.setSurfaceSize(null));

          final controller = _FakeSignupController();
          final router = GoRouter(
            initialLocation: '/signup',
            routes: [
              GoRoute(
                path: '/signup',
                builder: (_, _) => const SignupScreen(),
              ),
              GoRoute(
                path: '/login',
                builder: (_, _) => const _Stub('login'),
              ),
              GoRoute(
                path: '/welcome',
                builder: (_, _) => const _Stub('welcome'),
              ),
            ],
          );
          addTearDown(router.dispose);

          await tester.pumpWidget(
            ProviderScope(
              overrides: [
                signupControllerProvider.overrideWith(() => controller),
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

          expect(tester.takeException(), isNull);
          expect(find.byType(SignupScreen), findsOneWidget);
          expect(find.text('Create account'), findsOneWidget);
          expect(find.text('Continue'), findsOneWidget);
        },
      );
    }

    testWidgets(
      'WelcomeScreen survives keyboard-style viewport collapse',
      (tester) async {
        // Simulates a phone with the soft keyboard up: very short visible
        // height. The screen must still lay out without overflow.
        await tester.binding.setSurfaceSize(const Size(360, 320));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        final router = GoRouter(
          initialLocation: '/',
          routes: [
            GoRoute(path: '/', builder: (_, _) => const WelcomeScreen()),
            GoRoute(path: '/signup', builder: (_, _) => const _Stub('signup')),
            GoRoute(path: '/login', builder: (_, _) => const _Stub('login')),
          ],
        );
        addTearDown(router.dispose);

        await tester.pumpWidget(
          MaterialApp.router(
            routerConfig: router,
            theme: ThemeData.from(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      },
    );
  });
}

class _FakeSignupController extends SignupController {
  @override
  SignupState build() => SignupInitial();

  @override
  Future<void> signup({
    required String email,
    required String phone,
    required String pin,
  }) async {}

  @override
  void reset() {
    state = SignupInitial();
  }
}

class _Stub extends StatelessWidget {
  const _Stub(this.label);
  final String label;

  @override
  Widget build(BuildContext context) =>
      Scaffold(body: Center(child: Text(label)));
}
