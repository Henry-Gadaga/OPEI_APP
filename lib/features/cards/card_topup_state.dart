import 'package:opei/core/money/money.dart';
import 'package:opei/data/models/card_topup_preview.dart';
import 'package:opei/data/models/card_topup_response.dart';

enum CardTopUpStep { amountEntry, preview, result }

class CardTopUpState {
  final CardTopUpStep step;
  final bool isPreviewLoading;
  final bool isSubmitting;
  final String? errorMessage;
  final Money? amount;
  final CardTopUpPreview? preview;
  final CardTopUpResponse? result;
  final bool isSuccess;
  final String cardId;
  final String currency;

  const CardTopUpState({
    this.step = CardTopUpStep.amountEntry,
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

  CardTopUpState copyWith({
    CardTopUpStep? step,
    bool? isPreviewLoading,
    bool? isSubmitting,
    String? errorMessage,
    bool clearError = false,
    Money? amount,
    CardTopUpPreview? preview,
    bool clearPreview = false,
    CardTopUpResponse? result,
    bool clearResult = false,
    bool? isSuccess,
    String? cardId,
    String? currency,
  }) {
    return CardTopUpState(
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

  CardTopUpState resetForCard({required String newCardId, required String newCurrency}) {
    return CardTopUpState(
      cardId: newCardId,
      currency: newCurrency,
    );
  }

  CardTopUpState clearError() => copyWith(clearError: true);
}