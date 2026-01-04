import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:opei/core/network/api_error.dart';
import 'package:opei/core/network/api_response.dart';
import 'package:opei/core/providers/providers.dart';
import 'package:opei/data/models/kyc_session_response.dart';
import 'package:opei/data/repositories/kyc_repository.dart';
import 'package:opei/features/kyc/kyc_controller.dart';
import 'package:opei/features/kyc/kyc_state.dart';

class _MockKycRepository extends Mock implements KycRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('KycController', () {
    test('transitions to web view when session creation succeeds', () async {
      final repository = _MockKycRepository();
      final session = KycSessionResponse(
        sessionUrl: 'https://kyc/session',
        status: 'pending',
        workflowId: 'flow-1',
      );
      when(() => repository.createKycSession()).thenAnswer(
        (_) async => ApiResponse(success: true, message: '', data: session),
      );

      final container = ProviderContainer(
        overrides: [
          kycRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(kycControllerProvider.notifier);
      await controller.initializeKycSession();

      final state = container.read(kycControllerProvider);
      expect(state, isA<KycWebViewReady>());
      final webViewState = state as KycWebViewReady;
      expect(webViewState.sessionUrl, session.sessionUrl);
    });

    test('emits error when session payload indicates failure', () async {
      final repository = _MockKycRepository();
      when(() => repository.createKycSession()).thenAnswer(
        (_) async => ApiResponse<KycSessionResponse>(
          success: false,
          message: 'Backend unavailable',
        ),
      );

      final container = ProviderContainer(
        overrides: [
          kycRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(kycControllerProvider.notifier);
      await controller.initializeKycSession();

      final state = container.read(kycControllerProvider);
      expect(state, isA<KycError>());
      expect((state as KycError).message, 'Backend unavailable');
    });

    test('maps 403 ApiError with review message to underReview state', () async {
      final repository = _MockKycRepository();
      when(() => repository.createKycSession()).thenThrow(
        ApiError(message: 'Verification under review', statusCode: 403),
      );

      final container = ProviderContainer(
        overrides: [
          kycRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(kycControllerProvider.notifier);
      await controller.initializeKycSession();

      final state = container.read(kycControllerProvider);
      expect(state, isA<KycError>());
      expect((state as KycError).errorType, KycErrorType.underReview);
    });
  });
}
