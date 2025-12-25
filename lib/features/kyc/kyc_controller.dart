import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tt1/core/network/api_error.dart';
import 'package:tt1/core/providers/providers.dart';
import 'package:tt1/features/kyc/kyc_state.dart';

class KycController extends Notifier<KycState> {
  @override
  KycState build() => KycInitial();

  Future<void> initializeKycSession() async {
    if (state is KycLoading) return;

    state = KycLoading();
    debugPrint('🔄 Initializing KYC session...');

    try {
      final repository = ref.read(kycRepositoryProvider);
      final response = await repository.createKycSession();

      final sessionData = response.data;
      if (response.success && sessionData != null) {
        debugPrint('✅ KYC session ready: ${sessionData.sessionUrl}');
        state = KycWebViewReady(
          sessionUrl: sessionData.sessionUrl,
          status: sessionData.status,
        );
      } else {
        debugPrint('❌ KYC session failed: ${response.message}');
        state = KycError(
          message: response.message,
          errorType: KycErrorType.general,
        );
      }
    } on ApiError catch (e) {
      debugPrint('❌ KYC API error: ${e.statusCode} - ${e.message}');
      state = _mapApiErrorToState(e);
    } catch (e) {
      debugPrint('❌ KYC unexpected error: $e');
      state = KycError(
        message: 'Something went wrong. Please try again.',
        errorType: KycErrorType.general,
      );
    }
  }

  KycState _mapApiErrorToState(ApiError error) {
    switch (error.statusCode) {
      case 401:
        return KycError(
          message: 'Session expired. Please login again.',
          errorType: KycErrorType.unauthorized,
        );

      case 403:
        final message = error.message.toLowerCase();
        
        if (message.contains('already approved')) {
          return KycError(
            message: 'Verification already complete!',
            errorType: KycErrorType.alreadyApproved,
          );
        }
        if (message.contains('under review')) {
          return KycError(
            message: 'Your verification is under review. Please check back later.',
            errorType: KycErrorType.underReview,
          );
        }
        if (message.contains('address') || message.contains('pending_address')) {
          return KycError(
            message: 'Please complete your address information first.',
            errorType: KycErrorType.wrongStage,
          );
        }
        if (message.contains('inactive') || message.contains('suspended')) {
          return KycError(
            message: 'Account suspended. Please contact support.',
            errorType: KycErrorType.inactiveUser,
          );
        }
        return KycError(
          message: error.message,
          errorType: KycErrorType.general,
        );

      case 404:
        return KycError(
          message: 'Account not found. Please login again.',
          errorType: KycErrorType.notFound,
        );

      case 500:
      case 502:
      case 503:
        return KycError(
          message: 'Service temporarily unavailable. Please try again later.',
          errorType: KycErrorType.serviceUnavailable,
        );

      default:
        return KycError(
          message: error.message,
          errorType: KycErrorType.general,
        );
    }
  }

  void reset() {
    state = KycInitial();
  }

  void markCompleted() {
    state = KycCompleted();
  }
}

final kycControllerProvider = NotifierProvider<KycController, KycState>(
  KycController.new,
);
