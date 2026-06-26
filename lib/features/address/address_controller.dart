import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opei/core/constants/countries.dart';
import 'package:opei/core/network/api_error.dart';
import 'package:opei/core/providers/providers.dart';
import 'package:opei/core/utils/error_helper.dart';
import 'package:opei/data/models/address_request.dart';
import 'package:opei/features/address/address_state.dart';

class AddressNotifier extends Notifier<AddressState> {
  @override
  AddressState build() => AddressState();

  void setCountry(Country country) {
    debugPrint('📍 Country selected: ${country.iso}');
    var fieldErrors = _clearFieldError('country');
    if (country.iso != 'NG') {
      fieldErrors = _clearFieldError('bvn', fieldErrors);
    }

    state = state.copyWith(
      selectedCountry: country,
      bvn: country.iso == 'NG' ? state.bvn : '',
      fieldErrors: fieldErrors,
    );
  }

  void updateState(String value) {
    final validated = _validateInput(value);
    if (validated != null) {
      final fieldErrors = _clearFieldError('state');
      state = state.copyWith(
        state: validated,
        fieldErrors: fieldErrors,
      );
    }
  }

  void updateCity(String value) {
    final validated = _validateInput(value);
    if (validated != null) {
      final fieldErrors = _clearFieldError('city');
      state = state.copyWith(
        city: validated,
        fieldErrors: fieldErrors,
      );
    }
  }

  void updateZipCode(String value) {
    final validated = _validateInput(value);
    if (validated != null) {
      final fieldErrors = _clearFieldError('zipCode');
      state = state.copyWith(
        zipCode: validated,
        fieldErrors: fieldErrors,
      );
    }
  }

  void updateAddressLine(String value) {
    final validated = _validateInput(value);
    if (validated != null) {
      final fieldErrors = _clearFieldError('addressLine');
      state = state.copyWith(
        addressLine: validated,
        fieldErrors: fieldErrors,
      );
    }
  }

  void updateHouseNumber(String value) {
    final validated = _validateInput(value);
    if (validated != null) {
      final fieldErrors = _clearFieldError('houseNumber');
      state = state.copyWith(
        houseNumber: validated,
        fieldErrors: fieldErrors,
      );
    }
  }

  void updateBvn(String value) {
    final validated = _validateInput(value);
    if (validated != null) {
      final fieldErrors = _clearFieldError('bvn');
      state = state.copyWith(
        bvn: validated,
        fieldErrors: fieldErrors,
      );
    }
  }

  String? _validateInput(String value) {
    if (value.isEmpty) return value;
    if (value.length > 60) return null;
    
    for (int i = 0; i < value.length; i++) {
      final char = value[i];
      final code = char.codeUnitAt(0);
      
      if ('<>{}()"\'=%#@*?!+|'.contains(char)) return null;
      
      if (code >= 0x1F600 && code <= 0x1F64F) return null;
      if (code >= 0x1F300 && code <= 0x1F5FF) return null;
      if (code >= 0x1F680 && code <= 0x1F6FF) return null;
      if (code >= 0x2600 && code <= 0x26FF) return null;
      if (code >= 0x2700 && code <= 0x27BF) return null;
    }
    
    return value;
  }

  String? validateField(String value, String fieldName) {
    final l10n = ErrorHelper.l10n;
    if (value.isEmpty) {
      return l10n.addressFieldRequired(fieldName);
    }
    
    if (value.length > 60) {
      return l10n.addressMax60CharsError;
    }
    
    final allowedPattern = RegExp(r'^[A-Za-z0-9 ,.\-/]+$');
    if (!allowedPattern.hasMatch(value)) {
      return l10n.addressAllowedCharsError;
    }
    
    return null;
  }

  Future<bool> submitAddress({bool fromProfile = false}) async {
    final validationErrors = _validateForm();
    if (validationErrors.isNotEmpty) {
      debugPrint('❌ Form validation failed');
      state = state.copyWith(
        errorMessage: ErrorHelper.l10n.addressFixErrorsBelow,
        fieldErrors: validationErrors,
      );
      return false;
    }

    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      fieldErrors: const <String, String>{},
    );

    try {
      final addressRepository = ref.read(addressRepositoryProvider);
      
      final request = AddressRequest(
        country: state.selectedCountry!.iso,
        state: state.state.trim(),
        city: state.city.trim(),
        zipCode: state.zipCode.trim(),
        addressLine: state.addressLine.trim(),
        houseNumber: state.houseNumber.trim(),
        bvn: state.isNigeria ? state.bvn.trim() : null,
      );

      final response = await addressRepository.submitAddress(request);

      if (response.success) {
        debugPrint('✅ Address submission successful');
        if (!fromProfile) {
          ref.read(authSessionProvider.notifier).updateUserStage('PENDING_KYC');
        }
        state = state.copyWith(isLoading: false);
        return true;
      } else {
        debugPrint('❌ Address submission failed: ${response.message}');
        state = state.copyWith(
          isLoading: false,
          errorMessage: response.message,
        );
        return false;
      }
    } on ApiError catch (e) {
      debugPrint('❌ API Error: ${e.message} (${e.statusCode})');
      
      if (e.statusCode == 400 && e.errors != null) {
        final fieldErrors = <String, String>{};
        e.errors!.forEach((key, value) {
          if (value is String) {
            fieldErrors[key] = value;
          } else if (value is List && value.isNotEmpty) {
            fieldErrors[key] = value.first.toString();
          }
        });
        
        state = state.copyWith(
          isLoading: false,
          errorMessage: ErrorHelper.l10n.addressFixErrorsBelow,
          fieldErrors: fieldErrors,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: e.message,
        );
      }
      return false;
    } catch (e) {
      debugPrint('❌ Unexpected error: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: ErrorHelper.l10n.addressUnableSubmitError,
      );
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(
      errorMessage: null,
      fieldErrors: const <String, String>{},
    );
  }

  Map<String, String> _clearFieldError(String key, [Map<String, String>? current]) {
    final source = current ?? state.fieldErrors;
    if (!source.containsKey(key)) {
      return source;
    }

    final updated = Map<String, String>.from(source);
    updated.remove(key);
    return updated;
  }

  Map<String, String> _validateForm() {
    final l10n = ErrorHelper.l10n;
    final errors = <String, String>{};

    if (state.selectedCountry == null) {
      errors['country'] = l10n.addressCountryRequiredError;
    }

    final regionError = validateField(state.state.trim(), l10n.addressStateLabel);
    if (regionError != null) {
      errors['state'] = regionError;
    }

    final cityError = validateField(state.city.trim(), l10n.addressCityLabel);
    if (cityError != null) {
      errors['city'] = cityError;
    }

    final zipError = validateField(state.zipCode.trim(), l10n.addressZipCodeLabel);
    if (zipError != null) {
      errors['zipCode'] = zipError;
    }

    final addressLineError = validateField(
      state.addressLine.trim(),
      l10n.addressLineLabel,
    );
    if (addressLineError != null) {
      errors['addressLine'] = addressLineError;
    }

    final houseNumberError = validateField(
      state.houseNumber.trim(),
      l10n.addressAptSuiteLabel,
    );
    if (houseNumberError != null) {
      errors['houseNumber'] = houseNumberError;
    }

    if (state.isNigeria) {
      final bvnError = validateField(state.bvn.trim(), l10n.addressBvnLabel);
      if (bvnError != null) {
        errors['bvn'] = bvnError;
      }
    }

    return errors;
  }
}

final addressControllerProvider = NotifierProvider<AddressNotifier, AddressState>(
  AddressNotifier.new,
);
