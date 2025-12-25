import 'package:tt1/data/models/crypto_address_response.dart';

class DepositState {
  final bool isLoading;
  final String? error;
  final CryptoAddressResponse? addressResponse;
  final String? selectedCurrency;
  final String? selectedNetwork;
  final String? loadingNetwork;

  const DepositState({
    this.isLoading = false,
    this.error,
    this.addressResponse,
    this.selectedCurrency,
    this.selectedNetwork,
    this.loadingNetwork,
  });

  DepositState copyWith({
    bool? isLoading,
    String? error,
    bool clearError = false,
    CryptoAddressResponse? addressResponse,
    bool clearAddress = false,
    String? selectedCurrency,
    bool clearSelectedCurrency = false,
    String? selectedNetwork,
    bool clearSelectedNetwork = false,
    String? loadingNetwork,
    bool clearLoadingNetwork = false,
  }) {
    return DepositState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      addressResponse: clearAddress ? null : (addressResponse ?? this.addressResponse),
      selectedCurrency: clearSelectedCurrency ? null : (selectedCurrency ?? this.selectedCurrency),
      selectedNetwork: clearSelectedNetwork ? null : (selectedNetwork ?? this.selectedNetwork),
      loadingNetwork: clearLoadingNetwork ? null : (loadingNetwork ?? this.loadingNetwork),
    );
  }
}
