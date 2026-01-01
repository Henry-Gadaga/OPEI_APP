import 'package:tt1/core/constants/countries.dart';

class AddressState {
  final Country? selectedCountry;
  final String state;
  final String city;
  final String zipCode;
  final String addressLine;
  final String houseNumber;
  final String bvn;
  final bool isLoading;
  final String? errorMessage;
  final Map<String, String> fieldErrors;

  AddressState({
    this.selectedCountry,
    this.state = '',
    this.city = '',
    this.zipCode = '',
    this.addressLine = '',
    this.houseNumber = '',
    this.bvn = '',
    this.isLoading = false,
    this.errorMessage,
    this.fieldErrors = const <String, String>{},
  });

  bool get isNigeria => selectedCountry?.iso == 'NG';
  
  bool get isValid {
    if (selectedCountry == null) return false;
    if (state.trim().isEmpty) return false;
    if (city.trim().isEmpty) return false;
    if (zipCode.trim().isEmpty) return false;
    if (addressLine.trim().isEmpty) return false;
    if (houseNumber.trim().isEmpty) return false;
    if (isNigeria && bvn.trim().isEmpty) return false;
    return true;
  }

  AddressState copyWith({
    Country? selectedCountry,
    String? state,
    String? city,
    String? zipCode,
    String? addressLine,
    String? houseNumber,
    String? bvn,
    bool? isLoading,
    String? errorMessage,
    Map<String, String>? fieldErrors,
  }) {
    return AddressState(
      selectedCountry: selectedCountry ?? this.selectedCountry,
      state: state ?? this.state,
      city: city ?? this.city,
      zipCode: zipCode ?? this.zipCode,
      addressLine: addressLine ?? this.addressLine,
      houseNumber: houseNumber ?? this.houseNumber,
      bvn: bvn ?? this.bvn,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      fieldErrors: fieldErrors ?? this.fieldErrors,
    );
  }
}
