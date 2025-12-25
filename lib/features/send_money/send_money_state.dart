import 'package:tt1/core/money/money.dart';
import 'package:tt1/data/models/wallet_lookup_response.dart';
import 'package:tt1/data/models/transfer_fee_response.dart';
import 'package:tt1/data/models/transfer_response.dart';

enum SendMoneyStep { emailLookup, amountEntry, preview, result }

class SendMoneyState {
  final bool isLoading;
  final String? errorMessage;
  final SendMoneyStep currentStep;
  final WalletLookupResponse? lookupResult;
  final Money? amount;
  final TransferPreviewResponse? previewResult;
  final TransferResponse? transferResult;
  final bool transferSuccess;

  SendMoneyState({
    this.isLoading = false,
    this.errorMessage,
    this.currentStep = SendMoneyStep.emailLookup,
    this.lookupResult,
    this.amount,
    this.previewResult,
    this.transferResult,
    this.transferSuccess = false,
  });

  SendMoneyState copyWith({
    bool? isLoading,
    String? errorMessage,
    SendMoneyStep? currentStep,
    WalletLookupResponse? lookupResult,
    Money? amount,
    TransferPreviewResponse? previewResult,
    TransferResponse? transferResult,
    bool? transferSuccess,
  }) =>
      SendMoneyState(
        isLoading: isLoading ?? this.isLoading,
        errorMessage: errorMessage,
        currentStep: currentStep ?? this.currentStep,
        lookupResult: lookupResult ?? this.lookupResult,
        amount: amount ?? this.amount,
        previewResult: previewResult ?? this.previewResult,
        transferResult: transferResult ?? this.transferResult,
        transferSuccess: transferSuccess ?? this.transferSuccess,
      );

  SendMoneyState clearError() => copyWith(errorMessage: '');
}
