import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tt1/core/money/money.dart';
import 'package:tt1/core/network/api_error.dart';
import 'package:tt1/core/providers/providers.dart';
import 'package:tt1/core/utils/error_helper.dart';
import 'package:tt1/data/repositories/card_repository.dart';
import 'package:tt1/features/cards/card_topup_state.dart';
import 'package:tt1/features/cards/cards_controller.dart';
import 'package:tt1/features/dashboard/dashboard_controller.dart';

final cardTopUpControllerProvider = NotifierProvider<CardTopUpController, CardTopUpState>(
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
    final normalizedCurrency = currency.isNotEmpty ? currency.toUpperCase() : 'USD';

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
    state = state.resetForCard(newCardId: trimmedId, newCurrency: normalizedCurrency);
  }

  Future<void> previewTopUp(Money amount) async {
    final cardId = state.cardId.trim();
    if (cardId.isEmpty) {
      state = state.copyWith(errorMessage: "We couldn't find this card.");
      return;
    }

    if (amount.cents <= 0) {
      state = state.copyWith(errorMessage: 'The amount you entered isn’t valid. Please enter a positive amount.');
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
      debugPrint('🔍 Loading top-up preview for $cardId with ${amount.cents} cents');
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
    final cardId = state.cardId.trim();
    final amount = state.amount;
    final preview = state.preview;

    if (cardId.isEmpty || amount == null || preview == null) {
      state = state.copyWith(errorMessage: 'Please review the top-up details before continuing.');
      return;
    }

    if (!preview.canTopUp) {
      state = state.copyWith(errorMessage: _friendlyReason(preview.reasonCode));
      return;
    }

    state = state.copyWith(
      isSubmitting: true,
      clearError: true,
    );

    try {
      debugPrint('💸 Confirming top-up of ${amount.cents} cents for card $cardId');
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

      final dashboardController = ref.read(dashboardControllerProvider.notifier);

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
    if (reasonCode == null) {
      return null;
    }

    switch (reasonCode.toUpperCase()) {
      case 'INSUFFICIENT_FUNDS':
        return 'You don’t have enough balance to complete this top-up.';
      default:
        return null;
    }
  }

  String _mapPreviewError(Object error) {
    if (error is ApiError) {
      final code = _extractErrorCode(error);

      switch (error.statusCode) {
        case 401:
          return 'Please sign in again to continue.';
        case 400:
          if (code == 'INVALID_AMOUNT') {
            return 'The amount you entered isn’t valid. Please enter a positive amount.';
          }
          if (code == 'CARD_NOT_ACTIVE') {
            return 'This card is not active; unfreeze it before topping up.';
          }
          if (code == 'USER_NOT_REGISTERED_FOR_CARD') {
            return 'You need to activate your card profile before you can continue.';
          }
          if (code == 'INSUFFICIENT_FUNDS') {
            return 'Your wallet balance is too low for this top-up.';
          }
          if (code == 'MISSING_USER_CONTEXT' || code == 'MISSING_USER_ID' || code == 'NO_USER_CONTEXT') {
            return 'Something went wrong while loading your account. Please try again.';
          }
          if (code == 'WALLET_BAD_REQUEST' || code == 'BAD_REQUEST' || code == 'INVALID_TOKEN') {
            return 'Something isn’t right with your account session. Please sign in again.';
          }
          return 'Something went wrong while loading your account. Please try again.';
        case 404:
          if (code == 'CARD_NOT_FOUND') {
            return 'We couldn’t find this card. Please refresh and try again.';
          }
          if (code == 'CARD_NOT_READY') {
            return 'Your card is being set up. Please try again in a moment.';
          }
          if (code == 'CARD_TERMINATED') {
            return 'This card is no longer active.';
          }
          if (code == 'WALLET_NOT_FOUND') {
            return 'We couldn’t find your wallet. Please contact support.';
          }
          return "We couldn’t find this card. Please refresh and try again.";
        case 503:
          return 'The wallet service is temporarily unavailable. Please try again shortly.';
      }
    }

    return ErrorHelper.getErrorMessage(error);
  }

  String _mapConfirmError(Object error) {
    if (error is ApiError) {
      final code = _extractErrorCode(error);

      switch (error.statusCode) {
        case 400:
          if (code == 'INVALID_AMOUNT') {
            return 'Please enter a valid amount.';
          }
          if (code == 'CARD_NOT_ACTIVE') {
            return 'This card is not active; unfreeze it before topping up.';
          }
          if (code == 'USER_NOT_REGISTERED_FOR_CARD') {
            return 'You need to finish your card setup before topping up.';
          }
          if (code == 'CARD_NOT_READY') {
            return 'Your card isn’t ready yet. Try again in a moment.';
          }
          if (code == 'CARD_TERMINATED') {
            return 'This card has been closed and can’t be topped up.';
          }
          if (code == 'INSUFFICIENT_FUNDS') {
            return 'Your wallet balance is too low for this top-up.';
          }
          if (code == 'INSUFFICIENT_FUNDS_RESERVE' || code == 'INSUFFICIENT_FUNDS_RESERVATION') {
            return 'You don’t have enough available balance to reserve this amount.';
          }
          if (code == 'WALLET_BAD_REQUEST' || code == 'BAD_REQUEST' || code == 'INVALID_TOKEN') {
            return 'Something isn’t right with your account session. Please sign in again.';
          }
          return 'Please enter a valid amount.';
        case 401:
          return 'Please sign in again to continue.';
        case 404:
          if (code == 'CARD_NOT_FOUND') {
            return 'We couldn’t find this card on your account.';
          }
          if (code == 'WALLET_NOT_FOUND') {
            return 'We couldn’t find your wallet. Please contact support.';
          }
          return 'We couldn’t find this card on your account.';
        case 503:
          if (code == 'PROVIDER_FAILURE') {
            return 'We couldn’t complete your card top-up right now. Please try again shortly.';
          }
          return 'Wallet service is temporarily unavailable. Please try again soon.';
      }
    }

    return ErrorHelper.getErrorMessage(error);
  }

  String? _extractErrorCode(ApiError error) {
    final errors = error.errors;
    if (errors != null) {
      final dynamic codeCandidate = errors['code'] ?? errors['errorCode'] ?? errors['error_code'];
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