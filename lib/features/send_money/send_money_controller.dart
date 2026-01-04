import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opei/core/money/money.dart';
import 'package:opei/core/providers/providers.dart';
import 'package:opei/features/dashboard/dashboard_controller.dart';
import 'package:opei/features/send_money/send_money_state.dart';
import 'package:opei/core/utils/error_helper.dart';
import 'package:uuid/uuid.dart';

class SendMoneyNotifier extends Notifier<SendMoneyState> {
  @override
  SendMoneyState build() => SendMoneyState();

  Future<bool> lookupWallet(String email) async {
    final cleanEmail = email.trim().toLowerCase();
    
    if (cleanEmail.isEmpty) {
      state = state.copyWith(errorMessage: 'Please enter an email address');
      return false;
    }
    
    state = state.copyWith(isLoading: true, errorMessage: '');

    try {
      debugPrint('🔎 Looking up wallet for: $cleanEmail');
      final transferRepository = ref.read(transferRepositoryProvider);
      final result = await transferRepository.lookupWallet(cleanEmail);
      debugPrint('✅ User lookup successful: ${result.bestDisplayName} (${result.userId})');
      state = state.copyWith(
        isLoading: false,
        lookupResult: result,
        currentStep: SendMoneyStep.amountEntry,
      );
      return true;
    } catch (e) {
      final errorMsg = ErrorHelper.getErrorMessage(e, context: 'lookup');
      debugPrint('❌ Wallet lookup failed: $errorMsg');
      state = state.copyWith(
        isLoading: false,
        errorMessage: errorMsg,
      );
      return false;
    }
  }

  Future<bool> previewTransfer(Money amount) async {
    if (state.lookupResult == null) {
      state = state.copyWith(errorMessage: 'No recipient selected');
      return false;
    }

    if (amount.cents <= 0) {
      state = state.copyWith(errorMessage: 'Please enter a valid amount');
      return false;
    }

    state = state.copyWith(isLoading: true, errorMessage: '', amount: amount);

    try {
      debugPrint(
        '💰 Previewing transfer for amount: ${amount.format(includeCurrencySymbol: true)} (${amount.cents} cents)',
      );
      final transferRepository = ref.read(transferRepositoryProvider);
      final result = await transferRepository.previewTransfer(
        state.lookupResult!.userId,
        amount,
      );
      debugPrint(
        '✅ Preview loaded: Fee=${result.estimatedFeeMoney.format(includeCurrencySymbol: true)}, Total Debit=${result.totalDebitMoney.format(includeCurrencySymbol: true)}',
      );
      debugPrint(
        '📊 Parsed preview cents: transfer=${result.transferAmountMoney.cents}, fee=${result.estimatedFeeMoney.cents}, total=${result.totalDebitMoney.cents}',
      );
      state = state.copyWith(
        isLoading: false,
        previewResult: result,
        currentStep: SendMoneyStep.preview,
      );
      return true;
    } catch (e) {
      final errorMsg = ErrorHelper.getErrorMessage(e, context: 'preview');
      debugPrint('❌ Preview failed: $errorMsg');
      state = state.copyWith(
        isLoading: false,
        errorMessage: errorMsg,
      );
      return false;
    }
  }

  Future<bool> confirmTransfer() async {
    if (state.lookupResult == null || state.amount == null) {
      state = state.copyWith(errorMessage: 'Invalid transfer details');
      return false;
    }

    state = state.copyWith(isLoading: true, errorMessage: '');

    try {
      // Execute transfer
      final idempotencyKey = const Uuid().v4();

      debugPrint(
        '💸 Executing transfer to ${state.lookupResult!.userId} for ${state.amount!.format(includeCurrencySymbol: true)} (${state.amount!.cents} cents)...',
      );
      final transferRepository = ref.read(transferRepositoryProvider);
      final expectedBalanceAfter = state.previewResult?.senderBalanceAfterMoney;
      final result = await transferRepository.executeTransfer(
        state.lookupResult!.userId,
        state.amount!,
        idempotencyKey,
        description: 'Transfer to ${state.lookupResult!.bestDisplayName}',
        expectedSenderBalanceAfter: expectedBalanceAfter,
      );
      
      debugPrint('✅ Transfer successful! Reference: ${result.reference}');
      state = state.copyWith(
        isLoading: false,
        transferResult: result,
        transferSuccess: true,
        currentStep: SendMoneyStep.result,
      );

      // Refresh wallet balance after a successful transfer
      unawaited(
        ref.read(dashboardControllerProvider.notifier).refreshBalance(showSpinner: false),
      );
      return true;
    } catch (e, stackTrace) {
      debugPrint('❌ Transfer exception: $e');
      debugPrint('📄 Stack trace: $stackTrace');
      final errorMsg = ErrorHelper.getErrorMessage(e, context: 'transfer');
      debugPrint('❌ Transfer failed: $errorMsg');
      state = state.copyWith(
        isLoading: false,
        errorMessage: errorMsg,
        transferSuccess: false,
        currentStep: SendMoneyStep.result,
      );
      return false;
    }
  }

  void goBack() {
    if (state.currentStep == SendMoneyStep.amountEntry) {
      state = state.copyWith(
        currentStep: SendMoneyStep.emailLookup,
        errorMessage: '',
      );
    } else if (state.currentStep == SendMoneyStep.preview) {
      state = state.copyWith(
        currentStep: SendMoneyStep.amountEntry,
        errorMessage: '',
        previewResult: null,
      );
    }
  }

  void reset() {
    state = SendMoneyState();
  }
}

final sendMoneyControllerProvider = NotifierProvider<SendMoneyNotifier, SendMoneyState>(
  SendMoneyNotifier.new,
);
