import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tt1/core/money/money.dart';
import 'package:tt1/core/network/api_error.dart';
import 'package:tt1/core/providers/providers.dart';
import 'package:tt1/core/utils/error_helper.dart';
import 'package:tt1/data/repositories/card_repository.dart';
import 'package:tt1/features/cards/card_withdraw_state.dart';
import 'package:tt1/features/cards/cards_controller.dart';

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
    final cardId = state.cardId.trim();
    if (cardId.isEmpty) {
      state = state.copyWith(errorMessage: "We couldn't find this card.");
      return;
    }

    if (amount.cents <= 0) {
      state = state.copyWith(errorMessage: 'Please enter an amount above zero.');
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
      final message = preview.canWithdraw ? friendly : (friendly ?? "This amount can't be withdrawn right now. Please adjust it and try again.");

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
    final cardId = state.cardId.trim();
    final amount = state.amount;
    final preview = state.preview;

    if (cardId.isEmpty || amount == null || preview == null) {
      state = state.copyWith(errorMessage: 'Please review the withdrawal details before confirming.');
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
    if (reasonCode == null) {
      return null;
    }

    switch (reasonCode.toUpperCase()) {
      case 'INSUFFICIENT_CARD_BALANCE':
        return 'Your card balance is not enough for this withdrawal.';
      case 'AMOUNT_TOO_LOW_AFTER_FEES':
        return 'The amount is too small once fees are applied. Try a slightly higher amount.';
      case 'CARD_NOT_READY':
        return 'This card is still being set up. Please try again shortly.';
      case 'CARD_TERMINATED':
        return "This card has been closed and can't be used for withdrawals.";
      case 'MINIMUM_CARD_BALANCE_REQUIRED':
        return 'You must keep at least \$1 on the card.';
      default:
        return null;
    }
  }

  String _mapPreviewError(Object error) {
    if (error is ApiError) {
      final code = _extractErrorCode(error);

      switch (error.statusCode) {
        case 400:
        case 401:
          if (code == 'INVALID_AMOUNT') {
            return 'Please enter an amount above zero.';
          }
          if (code == 'CARD_NOT_ACTIVE') {
            return 'This card is not active; unfreeze it before withdrawing.';
          }
          if (code == 'CARD_NOT_READY') {
            return 'This card is still being set up. Please try again shortly.';
          }
          if (code == 'CARD_TERMINATED') {
            return "This card has been closed and can't be used for withdrawals.";
          }
          if (code == 'MINIMUM_CARD_BALANCE_REQUIRED') {
            return 'You must keep at least \$1 on the card.';
          }
          if (code == 'MISSING_USER_CONTEXT' ||
              code == 'MISSING_USER_ID' ||
              code == 'NO_USER_CONTEXT' ||
              code == 'INVALID_TOKEN') {
            return "We couldn't verify your account session. Please sign in again.";
          }
          return "We couldn't start the withdrawal. Please try again.";
        case 404:
          if (code == 'CARD_NOT_FOUND') {
            return "We couldn't find this card. Please refresh and try again.";
          }
          return "We couldn't find this card. Please refresh and try again.";
        case 503:
          return "We're having trouble reaching the card provider. Please try again in a moment.";
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
            return 'Please enter a valid amount above zero.';
          }
          if (code == 'CARD_NOT_ACTIVE') {
            return 'This card is not active; unfreeze it before withdrawing.';
          }
          if (code == 'USER_NOT_REGISTERED_FOR_CARD') {
            return 'Please finish your card setup before withdrawing.';
          }
          if (code == 'CARD_NOT_READY') {
            return 'This card is still being set up. Please try again shortly.';
          }
          if (code == 'CARD_TERMINATED') {
            return "This card has been closed and can't be used for withdrawals.";
          }
          if (code == 'INSUFFICIENT_CARD_BALANCE') {
            return 'Your card balance is not enough for this withdrawal.';
          }
          if (code == 'AMOUNT_TOO_LOW_AFTER_FEES') {
            return 'The amount is too small once fees are applied. Try a higher amount.';
          }
          if (code == 'MINIMUM_CARD_BALANCE_REQUIRED') {
            return 'You must keep at least \$1 on the card.';
          }
            return "We couldn't complete the withdrawal. Please try again.";
        case 401:
          return "We couldn't verify your account session. Please sign in again.";
        case 404:
          if (code == 'CARD_NOT_FOUND') {
            return "We couldn't find this card on your account.";
          }
          return "We couldn't find this card on your account.";
        case 429:
          if (error.errors != null) {
            final retryAfter = error.errors!['retryAfterSeconds'];
            if (retryAfter is num) {
              final seconds = retryAfter.round();
              return 'Too many attempts. Please try again in about ${seconds ~/ 60 > 0 ? '${seconds ~/ 60} minute(s)' : '${seconds}s'}.';
            }
          }
          if (code == 'TRY_AGAIN_AFTER_4_MINUTES') {
            return "We're processing another request. Give it a moment before retrying.";
          }
          return "We're processing another request. Please wait a moment and try again.";
        case 503:
          return "We're having trouble with the card provider right now. Please try again shortly.";
        case 500:
          return "Something went wrong on our side. Please try again.";
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