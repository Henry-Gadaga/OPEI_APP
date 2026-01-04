import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opei/core/money/money.dart';
import 'package:opei/core/providers/providers.dart';
import 'package:opei/core/utils/error_helper.dart';
import 'package:opei/data/repositories/crypto_repository.dart';
import 'package:opei/features/dashboard/dashboard_controller.dart';
import 'package:opei/features/withdraw/withdraw_state.dart';

final withdrawControllerProvider = NotifierProvider<WithdrawController, WithdrawState>(WithdrawController.new);

class WithdrawController extends Notifier<WithdrawState> {
  late CryptoRepository _cryptoRepository;

  @override
  WithdrawState build() {
    _cryptoRepository = ref.read(cryptoRepositoryProvider);
    return const WithdrawState();
  }

  void setCurrency(String currency) {
    state = state.copyWith(
      selectedCurrency: currency,
      clearError: true,
    );
  }

  void setNetwork(String network) {
    state = state.copyWith(
      selectedNetwork: network,
      clearError: true,
    );
  }

  Future<bool> submitCryptoWithdrawal({
    required String currency,
    required String network,
    required String amount,
    required String address,
    String? description,
  }) async {
    final sanitizedAmount = amount.replaceAll(',', '').trim();
    final amountMoney = Money.parse(sanitizedAmount, currency: currency);

    if (amountMoney.cents <= 0) {
      state = state.copyWith(
        error: 'Enter an amount above 0.00 to continue.',
        clearTransferResponse: true,
      );
      return false;
    }

    if (address.trim().isEmpty) {
      state = state.copyWith(
        error: 'Enter a valid wallet address to continue.',
        clearTransferResponse: true,
      );
      return false;
    }

    state = state.copyWith(
      isLoading: true,
      clearError: true,
      selectedCurrency: currency,
      selectedNetwork: network,
      clearTransferResponse: true,
    );

    try {
      final response = await _cryptoRepository.createCryptoTransfer(
        chain: network,
        assetType: currency,
        amount: amountMoney,
        address: address.trim(),
        description: (description != null && description.trim().isNotEmpty) ? description.trim() : null,
      );

      state = state.copyWith(
        isLoading: false,
        transferResponse: response,
        selectedCurrency: currency,
        selectedNetwork: network,
        clearError: true,
      );

      // Refresh wallet balance quietly after a successful withdrawal
      unawaited(
        ref.read(dashboardControllerProvider.notifier).refreshBalance(showSpinner: false),
      );

      return true;
    } catch (error) {
      final message = ErrorHelper.getErrorMessage(error, context: 'withdraw');
      debugPrint('[WithdrawController] Failed to submit crypto withdrawal: $message');
      state = state.copyWith(
        isLoading: false,
        error: message,
      );
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  void resetSubmission() {
    state = state.copyWith(
      clearTransferResponse: true,
      clearError: true,
    );
  }
}