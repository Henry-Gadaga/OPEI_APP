import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opei/core/money/money.dart';
import 'package:opei/core/network/api_error.dart';
import 'package:opei/core/providers/providers.dart';
import 'package:opei/core/utils/error_helper.dart';
import 'package:opei/data/repositories/card_repository.dart';
import 'package:opei/features/cards/card_withdraw_state.dart';
import 'package:opei/features/cards/cards_controller.dart';

final cardWithdrawControllerProvider = NotifierProvider<CardWithdrawController, CardWithdrawState>(
  CardWithdrawController.new,
);

class CardWithdrawController extends Notifier<CardWithdrawState> {
  late CardRepository _cardRepository;

  @override
  CardWithdrawState build() {
    _cardRepository = ref.read(cardRepositoryProvider);
    return const CardWithdrawState();
  }

  void attachCard({required String cardId, required String currency}) {
    final trimmedId = cardId.trim();
    final normalizedCurrency = currency.isNotEmpty ? currency.toUpperCase() : 'USD';

    final shouldKeepState =
        state.cardId == trimmedId &&
        state.currency == normalizedCurrency &&
        state.step == CardWithdrawStep.amountEntry &&
        state.preview == null &&
        state.result == null;

    if (shouldKeepState) {
      return;
    }

    debugPrint('💳 Preparing withdraw flow for card $trimmedId');
    state = state.resetForCard(newCardId: trimmedId, newCurrency: normalizedCurrency);
  }

  Future<void> previewWithdraw(Money amount) async {
    final l10n = ErrorHelper.l10n;
    final cardId = state.cardId.trim();
    if (cardId.isEmpty) {
      state = state.copyWith(errorMessage: l10n.cardsNotFoundError);
      return;
    }

    if (amount.cents <= 0) {
      state = state.copyWith(errorMessage: l10n.cardsWithdrawAmountAboveZeroError);
      return;
    }

    state = state.copyWith(
      isPreviewLoading: true,
      clearError: true,
      amount: amount,
      clearPreview: true,
      clearResult: true,
      isSuccess: false,
    );

    try {
      debugPrint('🔍 Loading withdraw preview for $cardId with ${amount.cents} cents');
      final preview = await _cardRepository.previewWithdraw(
        cardId: cardId,
        amountCents: amount.cents,
        currency: state.currency,
      );

      final friendly = _friendlyReason(preview.reasonCode);
      final message = preview.canWithdraw
          ? friendly
          : (friendly ?? l10n.cardsWithdrawAmountNotAllowedError);

      state = state.copyWith(
        isPreviewLoading: false,
        preview: preview,
        step: CardWithdrawStep.preview,
        errorMessage: message,
      );
    } catch (error, stackTrace) {
      debugPrint('❌ Failed to load withdraw preview: $error');
      debugPrint('$stackTrace');
      state = state.copyWith(
        isPreviewLoading: false,
        errorMessage: _mapPreviewError(error),
      );
    }
  }

  Future<void> confirmWithdraw() async {
    final l10n = ErrorHelper.l10n;
    final cardId = state.cardId.trim();
    final amount = state.amount;
    final preview = state.preview;

    if (cardId.isEmpty || amount == null || preview == null) {
      state = state.copyWith(errorMessage: l10n.cardsWithdrawReviewDetailsError);
      return;
    }

    if (!preview.canWithdraw) {
      state = state.copyWith(errorMessage: _friendlyReason(preview.reasonCode));
      return;
    }

    state = state.copyWith(
      isSubmitting: true,
      clearError: true,
    );

    try {
      debugPrint('💸 Confirming withdraw of ${amount.cents} cents for card $cardId');
      final response = await _cardRepository.confirmWithdraw(
        cardId: cardId,
        amountCents: amount.cents,
        currency: state.currency,
        feeCents: preview.feeAmount.cents,
        netCents: preview.netAmountToUser.cents,
      );

      state = state.copyWith(
        isSubmitting: false,
        step: CardWithdrawStep.result,
        result: response,
        isSuccess: true,
        clearError: true,
      );

      // Refresh cards so balance updates propagate.
      unawaited(ref.read(cardsControllerProvider.notifier).refresh());
    } catch (error, stackTrace) {
      debugPrint('❌ Card withdraw failed: $error');
      debugPrint('$stackTrace');
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: _mapConfirmError(error),
        isSuccess: false,
      );
    }
  }

  void goBack() {
    if (state.step == CardWithdrawStep.preview) {
      state = state.copyWith(
        step: CardWithdrawStep.amountEntry,
        clearError: true,
        clearPreview: true,
      );
    } else if (state.step == CardWithdrawStep.result) {
      state = state.copyWith(
        step: CardWithdrawStep.amountEntry,
        clearError: true,
        clearPreview: true,
        clearResult: true,
        amount: null,
        isSuccess: false,
      );
    }
  }

  void reset() {
    state = const CardWithdrawState();
  }

  void clearErrorMessage() {
    if (state.errorMessage?.isEmpty ?? true) {
      return;
    }
    state = state.copyWith(clearError: true);
  }

  String? friendlyReason(String? reasonCode) => _friendlyReason(reasonCode);

  String? _friendlyReason(String? reasonCode) {
    final l10n = ErrorHelper.l10n;
    if (reasonCode == null) {
      return null;
    }

    switch (reasonCode.toUpperCase()) {
      case 'INSUFFICIENT_CARD_BALANCE':
        return l10n.cardsWithdrawCardBalanceLowError;
      case 'AMOUNT_TOO_LOW_AFTER_FEES':
        return l10n.cardsWithdrawAmountTooLowAfterFeesError;
      case 'CARD_NOT_READY':
        return l10n.cardsWithdrawCardNotReadyError;
      case 'CARD_TERMINATED':
        return l10n.cardsWithdrawCardClosedError;
      case 'MINIMUM_CARD_BALANCE_REQUIRED':
        return l10n.cardsWithdrawMinimumBalanceRequiredError;
      default:
        return null;
    }
  }

  String _mapPreviewError(Object error) {
    final l10n = ErrorHelper.l10n;
    if (error is ApiError) {
      final code = _extractErrorCode(error);

      switch (error.statusCode) {
        case 400:
        case 401:
          if (code == 'INVALID_AMOUNT') {
            return l10n.cardsWithdrawAmountAboveZeroError;
          }
          if (code == 'CARD_NOT_ACTIVE') {
            return l10n.cardsWithdrawCardInactiveError;
          }
          if (code == 'CARD_NOT_READY') {
            return l10n.cardsWithdrawCardNotReadyError;
          }
          if (code == 'CARD_TERMINATED') {
            return l10n.cardsWithdrawCardClosedError;
          }
          if (code == 'MINIMUM_CARD_BALANCE_REQUIRED') {
            return l10n.cardsWithdrawMinimumBalanceRequiredError;
          }
          if (code == 'MISSING_USER_CONTEXT' ||
              code == 'MISSING_USER_ID' ||
              code == 'NO_USER_CONTEXT' ||
              code == 'INVALID_TOKEN') {
            return l10n.cardsWithdrawSessionVerifyError;
          }
          return l10n.cardsWithdrawStartFailedError;
        case 404:
          if (code == 'CARD_NOT_FOUND') {
            return l10n.cardsTopupCardNotFoundRefreshError;
          }
          return l10n.cardsTopupCardNotFoundRefreshError;
        case 503:
          return l10n.cardsWithdrawProviderUnavailableMomentError;
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
            return l10n.cardsWithdrawValidAmountAboveZeroError;
          }
          if (code == 'CARD_NOT_ACTIVE') {
            return l10n.cardsWithdrawCardInactiveError;
          }
          if (code == 'USER_NOT_REGISTERED_FOR_CARD') {
            return l10n.cardsWithdrawFinishSetupError;
          }
          if (code == 'CARD_NOT_READY') {
            return l10n.cardsWithdrawCardNotReadyError;
          }
          if (code == 'CARD_TERMINATED') {
            return l10n.cardsWithdrawCardClosedError;
          }
          if (code == 'INSUFFICIENT_CARD_BALANCE') {
            return l10n.cardsWithdrawCardBalanceLowError;
          }
          if (code == 'AMOUNT_TOO_LOW_AFTER_FEES') {
            return l10n.cardsWithdrawAmountTooLowAfterFeesHigherError;
          }
          if (code == 'MINIMUM_CARD_BALANCE_REQUIRED') {
            return l10n.cardsWithdrawMinimumBalanceRequiredError;
          }
            return l10n.cardsWithdrawCompleteFailedError;
        case 401:
          return l10n.cardsWithdrawSessionVerifyError;
        case 404:
          if (code == 'CARD_NOT_FOUND') {
            return l10n.cardsTopupCardNotFoundOnAccountError;
          }
          return l10n.cardsTopupCardNotFoundOnAccountError;
        case 429:
          if (error.errors != null) {
            final retryAfter = error.errors!['retryAfterSeconds'];
            if (retryAfter is num) {
              final seconds = retryAfter.round();
              return l10n.cardsWithdrawTooManyAttemptsError(
                seconds ~/ 60 > 0 ? '${seconds ~/ 60} min' : '${seconds}s',
              );
            }
          }
          if (code == 'TRY_AGAIN_AFTER_4_MINUTES') {
            return l10n.cardsWithdrawRequestInProgressRetryError;
          }
          return l10n.cardsWithdrawRequestInProgressWaitError;
        case 503:
          return l10n.cardsWithdrawProviderUnavailableShortlyError;
        case 500:
          return l10n.errGenericRetry;
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