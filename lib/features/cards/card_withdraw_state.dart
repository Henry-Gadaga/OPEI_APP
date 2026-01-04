import 'package:opei/core/money/money.dart';
import 'package:opei/data/models/card_withdraw_preview.dart';
import 'package:opei/data/models/card_withdraw_response.dart';

enum CardWithdrawStep { amountEntry, preview, result }

class CardWithdrawState {
  final CardWithdrawStep step;
  final bool isPreviewLoading;
  final bool isSubmitting;
  final String? errorMessage;
  final Money? amount;
  final CardWithdrawPreview? preview;
  final CardWithdrawResponse? result;
  final bool isSuccess;
  final String cardId;
  final String currency;

  const CardWithdrawState({
    this.step = CardWithdrawStep.amountEntry,
    this.isPreviewLoading = false,
    this.isSubmitting = false,
    this.errorMessage,
    this.amount,
    this.preview,
    this.result,
    this.isSuccess = false,
    this.cardId = '',
    this.currency = 'USD',
  });

  CardWithdrawState copyWith({
    CardWithdrawStep? step,
    bool? isPreviewLoading,
    bool? isSubmitting,
    String? errorMessage,
    bool clearError = false,
    Money? amount,
    CardWithdrawPreview? preview,
    bool clearPreview = false,
    CardWithdrawResponse? result,
    bool clearResult = false,
    bool? isSuccess,
    String? cardId,
    String? currency,
  }) {
    return CardWithdrawState(
      step: step ?? this.step,
      isPreviewLoading: isPreviewLoading ?? this.isPreviewLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      amount: amount ?? this.amount,
      preview: clearPreview ? null : (preview ?? this.preview),
      result: clearResult ? null : (result ?? this.result),
      isSuccess: isSuccess ?? this.isSuccess,
      cardId: cardId ?? this.cardId,
      currency: currency ?? this.currency,
    );
  }

  CardWithdrawState resetForCard({required String newCardId, required String newCurrency}) {
    return CardWithdrawState(
      cardId: newCardId,
      currency: newCurrency,
    );
  }

  CardWithdrawState clearError() => copyWith(clearError: true);
}