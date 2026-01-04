import 'package:opei/data/models/crypto_transfer_response.dart';

class WithdrawState {
  final bool isLoading;
  final String? error;
  final CryptoTransferResponse? transferResponse;
  final String? selectedCurrency;
  final String? selectedNetwork;

  const WithdrawState({
    this.isLoading = false,
    this.error,
    this.transferResponse,
    this.selectedCurrency,
    this.selectedNetwork,
  });

  WithdrawState copyWith({
    bool? isLoading,
    String? error,
    bool clearError = false,
    CryptoTransferResponse? transferResponse,
    bool clearTransferResponse = false,
    String? selectedCurrency,
    bool clearSelectedCurrency = false,
    String? selectedNetwork,
    bool clearSelectedNetwork = false,
  }) {
    return WithdrawState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      transferResponse: clearTransferResponse ? null : (transferResponse ?? this.transferResponse),
      selectedCurrency: clearSelectedCurrency ? null : (selectedCurrency ?? this.selectedCurrency),
      selectedNetwork: clearSelectedNetwork ? null : (selectedNetwork ?? this.selectedNetwork),
    );
  }
}