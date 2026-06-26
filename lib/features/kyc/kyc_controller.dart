import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opei/core/network/api_error.dart';
import 'package:opei/core/providers/providers.dart';
import 'package:opei/features/kyc/kyc_state.dart';

class KycController extends Notifier<KycState> {
  static const _genericErrorMessage = 'Something went wrong. Please try again.';
  static const _sessionExpiredMessage = 'Session expired. Please login again.';
  static const _alreadyCompleteMessage = 'Verification already complete!';
  static const _underReviewMessage =
      'Your verification is under review. Please check back later.';
  static const _addressRequiredMessage =
      'Please complete your address information first.';
  static const _inactiveAccountMessage =
      'Account suspended. Please contact support.';
  static const _accountNotFoundMessage =
      'Account not found. Please login again.';
  static const _serviceUnavailableMessage =
      'Service temporarily unavailable. Please try again later.';

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
        message: _genericErrorMessage,
        errorType: KycErrorType.general,
      );
    }
  }

  KycState _mapApiErrorToState(ApiError error) {
    switch (error.statusCode) {
      case 401:
        return KycError(
          message: _sessionExpiredMessage,
          errorType: KycErrorType.unauthorized,
        );

      case 403:
        final message = error.message.toLowerCase();

        if (message.contains('already approved')) {
          return KycError(
            message: _alreadyCompleteMessage,
            errorType: KycErrorType.alreadyApproved,
          );
        }
        if (message.contains('under review')) {
          return KycError(
            message: _underReviewMessage,
            errorType: KycErrorType.underReview,
          );
        }
        if (message.contains('address') ||
            message.contains('pending_address')) {
          return KycError(
            message: _addressRequiredMessage,
            errorType: KycErrorType.wrongStage,
          );
        }
        if (message.contains('inactive') || message.contains('suspended')) {
          return KycError(
            message: _inactiveAccountMessage,
            errorType: KycErrorType.inactiveUser,
          );
        }
        return KycError(
          message: error.message,
          errorType: KycErrorType.general,
        );

      case 404:
        return KycError(
          message: _accountNotFoundMessage,
          errorType: KycErrorType.notFound,
        );

      case 500:
      case 502:
      case 503:
        return KycError(
          message: _serviceUnavailableMessage,
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
