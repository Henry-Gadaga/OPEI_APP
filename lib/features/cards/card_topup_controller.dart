import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opei/core/money/money.dart';
import 'package:opei/core/network/api_error.dart';
import 'package:opei/core/providers/providers.dart';
import 'package:opei/core/utils/error_helper.dart';
import 'package:opei/data/repositories/card_repository.dart';
import 'package:opei/features/cards/card_topup_state.dart';
import 'package:opei/features/cards/cards_controller.dart';
import 'package:opei/features/dashboard/dashboard_controller.dart';
import 'package:opei/features/money_movement/availability_controller.dart';

final cardTopUpControllerProvider =
    NotifierProvider<CardTopUpController, CardTopUpState>(
      CardTopUpController.new,
    );

class CardTopUpController extends Notifier<CardTopUpState> {
  late CardRepository _cardRepository;

  @override
  CardTopUpState build() {
    _cardRepository = ref.read(cardRepositoryProvider);
    return const CardTopUpState();
  }

  void attachCard({required String cardId, required String currency}) {
    final trimmedId = cardId.trim();
    final normalizedCurrency = currency.isNotEmpty
        ? currency.toUpperCase()
        : 'USD';

    final shouldKeepState =
        state.cardId == trimmedId &&
        state.currency == normalizedCurrency &&
        state.step == CardTopUpStep.amountEntry &&
        state.preview == null &&
        state.result == null;

    if (shouldKeepState) {
      return;
    }

    debugPrint('💳 Preparing top-up flow for card $trimmedId');
    state = state.resetForCard(
      newCardId: trimmedId,
      newCurrency: normalizedCurrency,
    );
  }

  Future<void> previewTopUp(Money amount) async {
    final l10n = ErrorHelper.l10n;
    final availability = availabilityFromRef(ref);
    if (!availability.cards.topUp.enabled) {
      state = state.copyWith(errorMessage: l10n.errServiceUnavailable);
      return;
    }

    final cardId = state.cardId.trim();
    if (cardId.isEmpty) {
      state = state.copyWith(errorMessage: l10n.cardsNotFoundError);
      return;
    }

    if (amount.cents <= 0) {
      state = state.copyWith(
        errorMessage: l10n.cardsTopupInvalidPositiveAmountError,
      );
      return;
    }

    state = state.copyWith(
      isPreviewLoading: true,
      clearError: true,
      amount: amount,
      clearPreview: true,
      isSuccess: false,
      clearResult: true,
    );

    try {
      debugPrint(
        '🔍 Loading top-up preview for $cardId with ${amount.cents} cents',
      );
      final preview = await _cardRepository.previewTopUp(
        cardId: cardId,
        amountCents: amount.cents,
        currency: state.currency,
      );

      state = state.copyWith(
        isPreviewLoading: false,
        preview: preview,
        step: CardTopUpStep.preview,
        errorMessage: _friendlyReason(preview.reasonCode),
      );
    } catch (error, stackTrace) {
      debugPrint('❌ Failed to load top-up preview: $error');
      debugPrint('$stackTrace');
      state = state.copyWith(
        isPreviewLoading: false,
        errorMessage: _mapPreviewError(error),
      );
    }
  }

  Future<void> confirmTopUp() async {
    final l10n = ErrorHelper.l10n;
    final availability = availabilityFromRef(ref);
    if (!availability.cards.topUp.enabled) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: l10n.errServiceUnavailable,
      );
      return;
    }

    final cardId = state.cardId.trim();
    final amount = state.amount;
    final preview = state.preview;

    if (cardId.isEmpty || amount == null || preview == null) {
      state = state.copyWith(errorMessage: l10n.cardsTopupReviewDetailsError);
      return;
    }

    if (!preview.canTopUp) {
      state = state.copyWith(errorMessage: _friendlyReason(preview.reasonCode));
      return;
    }

    state = state.copyWith(isSubmitting: true, clearError: true);

    try {
      debugPrint(
        '💸 Confirming top-up of ${amount.cents} cents for card $cardId',
      );
      final response = await _cardRepository.confirmTopUp(
        cardId: cardId,
        amountCents: amount.cents,
        currency: state.currency,
      );

      state = state.copyWith(
        isSubmitting: false,
        step: CardTopUpStep.result,
        result: response,
        isSuccess: true,
        clearError: true,
      );

      // Refresh cards so balance/status updates propagate.
      unawaited(ref.read(cardsControllerProvider.notifier).refresh());

      final dashboardController = ref.read(
        dashboardControllerProvider.notifier,
      );

      // Apply the debit locally so the dashboard balance updates immediately.
      dashboardController.applyOptimisticDelta(-response.totalDebit.cents);

      // Sync the main dashboard balance quietly after a successful top-up.
      unawaited(dashboardController.refreshBalance(showSpinner: false));
    } catch (error, stackTrace) {
      debugPrint('❌ Card top-up failed: $error');
      debugPrint('$stackTrace');
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: _mapConfirmError(error),
        isSuccess: false,
      );
    }
  }

  void goBack() {
    if (state.step == CardTopUpStep.preview) {
      state = state.copyWith(
        step: CardTopUpStep.amountEntry,
        clearError: true,
        clearPreview: true,
      );
    } else if (state.step == CardTopUpStep.result) {
      state = state.copyWith(
        step: CardTopUpStep.amountEntry,
        clearError: true,
        clearPreview: true,
        clearResult: true,
        amount: null,
        isSuccess: false,
      );
    }
  }

  void reset() {
    state = const CardTopUpState();
  }

  String? friendlyReason(String? reasonCode) => _friendlyReason(reasonCode);

  void clearErrorMessage() {
    if (state.errorMessage?.isEmpty ?? true) {
      return;
    }
    state = state.copyWith(clearError: true);
  }

  String? _friendlyReason(String? reasonCode) {
    final l10n = ErrorHelper.l10n;
    if (reasonCode == null) {
      return null;
    }

    switch (reasonCode.toUpperCase()) {
      case 'INSUFFICIENT_FUNDS':
        return l10n.cardsTopupInsufficientBalanceError;
      default:
        return null;
    }
  }

  String _mapPreviewError(Object error) {
    final l10n = ErrorHelper.l10n;
    if (error is ApiError) {
      final code = _extractErrorCode(error);

      switch (error.statusCode) {
        case 401:
          return l10n.p2pPleaseSignInAgainError;
        case 400:
          if (code == 'INVALID_AMOUNT') {
            return l10n.cardsTopupInvalidPositiveAmountError;
          }
          if (code == 'CARD_NOT_ACTIVE') {
            return l10n.cardsTopupCardInactiveError;
          }
          if (code == 'USER_NOT_REGISTERED_FOR_CARD') {
            return l10n.cardsTopupActivateProfileError;
          }
          if (code == 'INSUFFICIENT_FUNDS') {
            return l10n.cardsTopupWalletLowBalanceError;
          }
          if (code == 'MISSING_USER_CONTEXT' ||
              code == 'MISSING_USER_ID' ||
              code == 'NO_USER_CONTEXT') {
            return l10n.cardsTopupAccountLoadFailedError;
          }
          if (code == 'WALLET_BAD_REQUEST' ||
              code == 'BAD_REQUEST' ||
              code == 'INVALID_TOKEN') {
            return l10n.cardsTopupSessionInvalidError;
          }
          return l10n.cardsTopupAccountLoadFailedError;
        case 404:
          if (code == 'CARD_NOT_FOUND') {
            return l10n.cardsTopupCardNotFoundRefreshError;
          }
          if (code == 'CARD_NOT_READY') {
            return l10n.cardsTopupCardNotReadyError;
          }
          if (code == 'CARD_TERMINATED') {
            return l10n.cardsTopupCardNoLongerActiveError;
          }
          if (code == 'WALLET_NOT_FOUND') {
            return l10n.cardsTopupWalletNotFoundError;
          }
          return l10n.cardsTopupCardNotFoundRefreshError;
        case 503:
          return l10n.cardsTopupWalletUnavailableError;
      }
    }

    return ErrorHelper.getErrorMessage(error);
  }

  String _mapConfirmError(Object error) {
    final l10n = ErrorHelper.l10n;
    if (error is ApiError) {
      final code = _extractErrorCode(error);

      switch (error.statusCode) {
        case 400:
          if (code == 'INVALID_AMOUNT') {
            return l10n.errEnterValidAmount;
          }
          if (code == 'CARD_NOT_ACTIVE') {
            return l10n.cardsTopupCardInactiveError;
          }
          if (code == 'USER_NOT_REGISTERED_FOR_CARD') {
            return l10n.cardsTopupFinishSetupError;
          }
          if (code == 'CARD_NOT_READY') {
            return l10n.cardsTopupCardNotReadyYetError;
          }
          if (code == 'CARD_TERMINATED') {
            return l10n.cardsTopupCardClosedError;
          }
          if (code == 'INSUFFICIENT_FUNDS') {
            return l10n.cardsTopupWalletLowBalanceError;
          }
          if (code == 'INSUFFICIENT_FUNDS_RESERVE' ||
              code == 'INSUFFICIENT_FUNDS_RESERVATION') {
            return l10n.cardsTopupReserveBalanceLowError;
          }
          if (code == 'WALLET_BAD_REQUEST' ||
              code == 'BAD_REQUEST' ||
              code == 'INVALID_TOKEN') {
            return l10n.cardsTopupSessionInvalidError;
          }
          return l10n.errEnterValidAmount;
        case 401:
          return l10n.p2pPleaseSignInAgainError;
        case 404:
          if (code == 'CARD_NOT_FOUND') {
            return l10n.cardsTopupCardNotFoundOnAccountError;
          }
          if (code == 'WALLET_NOT_FOUND') {
            return l10n.cardsTopupWalletNotFoundError;
          }
          return l10n.cardsTopupCardNotFoundOnAccountError;
        case 503:
          if (code == 'PROVIDER_FAILURE') {
            return l10n.cardsTopupProviderFailureError;
          }
          return l10n.cardsTopupWalletUnavailableSoonError;
      }
    }

    return ErrorHelper.getErrorMessage(error);
  }

  String? _extractErrorCode(ApiError error) {
    final errors = error.errors;
    if (errors != null) {
      final dynamic codeCandidate =
          errors['code'] ?? errors['errorCode'] ?? errors['error_code'];
      if (codeCandidate != null) {
        final parsed = codeCandidate.toString().trim();
        if (parsed.isNotEmpty) {
          return parsed.toUpperCase();
        }
      }
    }

    final message = error.message.trim();
    if (message.isEmpty) {
      return null;
    }

    final normalized = message
        .replaceAll(RegExp(r'[^A-Za-z0-9]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .trim();

    if (normalized.isEmpty) {
      return null;
    }

    return normalized.toUpperCase();
  }
}
