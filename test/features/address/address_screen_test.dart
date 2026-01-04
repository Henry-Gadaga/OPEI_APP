import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:opei/core/constants/countries.dart';
import 'package:opei/core/providers/providers.dart';
import 'package:opei/features/address/address_screen.dart';
import 'package:opei/features/address/address_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final nigeria = countries.firstWhere((c) => c.iso == 'NG');

  group('AddressScreen', () {
    testWidgets('disables Continue button when form invalid', (tester) async {
      final controller = _TestAddressController(AddressState());
      final harness = await _pumpAddressScreen(
        tester,
        controller: controller,
        initialState: AddressState(),
      );

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
      harness.dispose();
    });

    testWidgets('enables Continue button and calls submit when form valid', (tester) async {
      final validState = AddressState(
        selectedCountry: nigeria,
        state: 'Lagos',
        city: 'Lagos',
        zipCode: '100001',
        addressLine: '123 Main St',
        houseNumber: '12B',
        bvn: '12345678901',
      );

      final controller = _TestAddressController(validState);
      final harness = await _pumpAddressScreen(
        tester,
        controller: controller,
        initialState: validState,
      );

      final continueFinder = find.text('Continue');
      await tester.ensureVisible(continueFinder);
      await tester.tap(continueFinder);
      await tester.pump();

      expect(controller.submitCalled, isTrue);
      harness.dispose();
    });

    testWidgets('navigates to KYC after successful submission', (tester) async {
      final submittingState = AddressState(
        selectedCountry: nigeria,
        state: 'Lagos',
        city: 'Lagos',
        zipCode: '100001',
        addressLine: '123 Main St',
        houseNumber: '12B',
        bvn: '12345678901',
        isLoading: true,
      );
      final controller = _TestAddressController(submittingState);
      final harness = await _pumpAddressScreen(
        tester,
        controller: controller,
        initialState: submittingState,
      );

      controller.state = controller.state.copyWith(isLoading: false, errorMessage: null);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('KYC Screen'), findsOneWidget);
      harness.dispose();
    });
  });
}

class _AddressScreenHarness {
  _AddressScreenHarness({required this.router, required this.controller});

  final GoRouter router;
  final _TestAddressController controller;

  void dispose() {
    router.dispose();
  }
}

Future<_AddressScreenHarness> _pumpAddressScreen(
  WidgetTester tester, {
  required _TestAddressController controller,
  required AddressState initialState,
}) async {
  final router = GoRouter(
    initialLocation: '/address',
    routes: [
      GoRoute(
        path: '/address',
        builder: (context, state) => const AddressScreen(),
      ),
      GoRoute(
        path: '/kyc',
        builder: (context, state) => const _StubScreen(label: 'KYC Screen'),
      ),
      GoRoute(
        path: '/verify-email',
        builder: (context, state) => const _StubScreen(label: 'Verify Email Screen'),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const _StubScreen(label: 'Dashboard Screen'),
      ),
    ],
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        addressControllerProvider.overrideWith(() => controller),
        profileControllerProvider.overrideWith(
          () => _TestProfileController(const ProfileState()),
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

  await tester.pump();
  return _AddressScreenHarness(router: router, controller: controller);
}

class _TestAddressController extends AddressNotifier {
  _TestAddressController(this._initialState);

  final AddressState _initialState;
  bool submitCalled = false;

  @override
  AddressState build() => _initialState;

  @override
  Future<bool> submitAddress({bool fromProfile = false}) async {
    submitCalled = true;
    return true;
  }
}

class _TestProfileController extends ProfileController {
  _TestProfileController(this._initialState);

  final ProfileState _initialState;

  @override
  ProfileState build() => _initialState;

  @override
  Future<void> refreshProfile() async {}
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
