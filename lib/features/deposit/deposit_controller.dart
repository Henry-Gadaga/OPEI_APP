import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opei/core/providers/providers.dart';
import 'package:opei/core/utils/error_helper.dart';
import 'package:opei/data/models/crypto_address_response.dart';
import 'package:opei/data/repositories/crypto_repository.dart';
import 'package:opei/features/deposit/deposit_state.dart';
import 'package:opei/features/money_movement/availability_controller.dart';

final depositControllerProvider =
    NotifierProvider<DepositController, DepositState>(DepositController.new);

class DepositController extends Notifier<DepositState> {
  late CryptoRepository _cryptoRepository;

  @override
  DepositState build() {
    _cryptoRepository = ref.read(cryptoRepositoryProvider);
    return const DepositState();
  }

  Future<bool> fetchDepositAddress({
    required String currency,
    required String network,
  }) async {
    final availability = availabilityFromRef(ref);
    if (!availability.deposit.crypto.isNetworkEnabled(currency, network)) {
      state = state.copyWith(
        isLoading: false,
        error: ErrorHelper.l10n.errServiceUnavailable,
        clearAddress: true,
        clearLoadingNetwork: true,
      );
      return false;
    }

    state = state.copyWith(
      isLoading: true,
      clearError: true,
      loadingNetwork: network.toLowerCase(),
    );

    try {
      final CryptoAddressResponse response = await _cryptoRepository
          .getDepositAddress(currency: currency, network: network);

      state = state.copyWith(
        isLoading: false,
        addressResponse: response,
        selectedCurrency: currency,
        selectedNetwork: network,
        clearError: true,
        clearLoadingNetwork: true,
      );
      return true;
    } catch (error) {
      final errorMsg = ErrorHelper.getErrorMessage(error, context: 'deposit');
      debugPrint(
        '[DepositController] Failed to fetch deposit address: $errorMsg',
      );
      state = state.copyWith(
        isLoading: false,
        error: errorMsg,
        clearAddress: true,
        clearLoadingNetwork: true,
      );
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}
