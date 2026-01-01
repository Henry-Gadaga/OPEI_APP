import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tt1/core/constants/countries.dart';
import 'package:tt1/core/providers/providers.dart';
import 'package:tt1/core/utils/error_helper.dart';
import 'package:tt1/features/address/address_state.dart';
import 'package:tt1/theme.dart';
import 'package:tt1/widgets/success_hero.dart';

class AddressScreen extends ConsumerWidget {
  final bool isFromProfile;

  const AddressScreen({super.key, this.isFromProfile = false});

  Future<void> _showProfileSuccessSheet(BuildContext context, WidgetRef ref) async {
    final router = GoRouter.of(context);
    final result = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      builder: (sheetContext) {
        return _AddressSuccessSheet(
          onDone: () => Navigator.of(sheetContext).pop(true),
        );
      },
    );

    if (result == true) {
      final refreshFuture =
          ref.read(profileControllerProvider.notifier).refreshProfile();
      if (router.canPop()) {
        router.pop();
      } else {
        router.go('/dashboard');
      }
      unawaited(refreshFuture);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(addressControllerProvider);
    final controller = ref.read(addressControllerProvider.notifier);

    ref.listen(addressControllerProvider, (AddressState? previous, AddressState next) {
      if (previous != null && previous.isLoading && !next.isLoading) {
        if (next.errorMessage == null) {
          if (!context.mounted) return;
          if (isFromProfile) {
            _showProfileSuccessSheet(context, ref);
          } else {
            showSuccess(context, 'Address submitted successfully!');
            // Use push so the back button on KYC returns to Address
            context.push('/kyc');
          }
        } else if (next.fieldErrors.isEmpty) {
          if (!context.mounted) return;
          showError(context, next.errorMessage!);
        }
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: AppSpacing.horizontalLg,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 24),
                  
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios, size: 20),
                      onPressed: state.isLoading ? null : () {
                        final router = GoRouter.of(context);
                        if (router.canPop()) {
                          context.pop();
                        } else {
                          context.go('/verify-email');
                        }
                      },
                      padding: EdgeInsets.zero,
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  Text(
                    'Residential Address',
                    style: Theme.of(context).textTheme.displayLarge,
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 12),
                  
                  Text(
                    'Please provide your residential address details',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: OpeiColors.grey600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 40),
                  
                  IgnorePointer(
                    ignoring: state.isLoading,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Country *',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        CountryDropdown(
                          selectedCountry: state.selectedCountry,
                          onChanged: controller.setCountry,
                          errorText: state.fieldErrors['country'],
                        ),
                        
                        const SizedBox(height: 24),
                        
                        Text(
                          'State *',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        AddressTextField(
                          value: state.state,
                          onChanged: controller.updateState,
                          hintText: 'Enter state',
                          errorText: state.fieldErrors['state'],
                        ),
                        
                        const SizedBox(height: 24),
                        
                        Text(
                          'City *',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        AddressTextField(
                          value: state.city,
                          onChanged: controller.updateCity,
                          hintText: 'Enter city',
                          errorText: state.fieldErrors['city'],
                        ),
                        
                        const SizedBox(height: 24),
                        
                        Text(
                          'Zip Code *',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        AddressTextField(
                          value: state.zipCode,
                          onChanged: controller.updateZipCode,
                          hintText: 'Enter zip code',
                          errorText: state.fieldErrors['zipCode'],
                        ),
                        
                        const SizedBox(height: 24),
                        
                        Text(
                          'Address Line *',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        AddressTextField(
                          value: state.addressLine,
                          onChanged: controller.updateAddressLine,
                          hintText: 'Street address',
                          errorText: state.fieldErrors['addressLine'],
                        ),
                        
                        const SizedBox(height: 24),
                        
                        Text(
                          'House/Apt Number *',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        AddressTextField(
                          value: state.houseNumber,
                          onChanged: controller.updateHouseNumber,
                          hintText: 'House or apartment number',
                          errorText: state.fieldErrors['houseNumber'],
                        ),
                        
                        if (state.isNigeria) ...[
                          const SizedBox(height: 24),
                          
                          Text(
                            'BVN *',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          AddressTextField(
                            value: state.bvn,
                            onChanged: controller.updateBvn,
                            hintText: 'Enter BVN',
                            keyboardType: TextInputType.number,
                            errorText: state.fieldErrors['bvn'],
                          ),
                        ],
                        
                        const SizedBox(height: 40),
                        
                        SizedBox(
                          height: 56,
                          child: ElevatedButton(
                            onPressed: state.isValid
                                ? () => controller.submitAddress(
                                      fromProfile: isFromProfile,
                                    )
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: state.isValid ? OpeiColors.pureBlack : OpeiColors.grey300,
                              foregroundColor: OpeiColors.pureWhite,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppRadius.md),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              'Continue',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: state.isValid ? OpeiColors.pureWhite : OpeiColors.grey600,
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            if (state.isLoading)
              Container(
                color: OpeiColors.pureBlack.withValues(alpha: 0.3),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(
                          strokeWidth: 3,
                          color: OpeiColors.pureBlack,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Submitting address...',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class CountryDropdown extends StatelessWidget {
  final Country? selectedCountry;
  final ValueChanged<Country> onChanged;
  final String? errorText;

  const CountryDropdown({
    required this.selectedCountry,
    required this.onChanged,
    this.errorText,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GestureDetector(
          onTap: () => _showCountryPicker(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: OpeiColors.pureWhite,
              border: Border.all(
                color: errorText != null ? OpeiColors.errorRed : OpeiColors.grey300,
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    selectedCountry?.name ?? 'Select country',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: selectedCountry != null ? OpeiColors.pureBlack : OpeiColors.grey600,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down,
                  color: OpeiColors.grey600,
                ),
              ],
            ),
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 4),
            child: Text(
              errorText!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: OpeiColors.errorRed,
              ),
            ),
          ),
      ],
    );
  }

  void _showCountryPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: OpeiColors.pureWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      isScrollControlled: true,
      builder: (context) => CountryPickerSheet(
        selectedCountry: selectedCountry,
        onSelected: (country) {
          onChanged(country);
          Navigator.pop(context);
        },
      ),
    );
  }
}

class CountryPickerSheet extends StatefulWidget {
  final Country? selectedCountry;
  final ValueChanged<Country> onSelected;

  const CountryPickerSheet({
    required this.selectedCountry,
    required this.onSelected,
    super.key,
  });

  @override
  State<CountryPickerSheet> createState() => _CountryPickerSheetState();
}

class _CountryPickerSheetState extends State<CountryPickerSheet> {
  List<Country> _filteredCountries = countries;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterCountries(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredCountries = countries;
      } else {
        _filteredCountries = countries.where((country) =>
          country.name.toLowerCase().contains(query.toLowerCase()) ||
          country.iso.toLowerCase().contains(query.toLowerCase())
        ).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.75,
      child: Column(
        children: [
          const SizedBox(height: 16),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: OpeiColors.grey300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          
          Padding(
            padding: AppSpacing.horizontalLg,
            child: Text(
              'Select Country',
              style: Theme.of(context).textTheme.displayMedium,
            ),
          ),
          
          const SizedBox(height: 16),
          
          Padding(
            padding: AppSpacing.horizontalLg,
            child: TextField(
              controller: _searchController,
              onChanged: _filterCountries,
              decoration: InputDecoration(
                hintText: 'Search country...',
                prefixIcon: const Icon(Icons.search, color: OpeiColors.grey600),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  borderSide: const BorderSide(color: OpeiColors.grey300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  borderSide: const BorderSide(color: OpeiColors.grey300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  borderSide: const BorderSide(color: OpeiColors.pureBlack, width: 2),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          Expanded(
            child: ListView.builder(
              itemCount: _filteredCountries.length,
              itemBuilder: (context, index) {
                final country = _filteredCountries[index];
                final isSelected = widget.selectedCountry?.iso == country.iso;
                
                return ListTile(
                  title: Text(
                    country.name,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  trailing: isSelected
                    ? const Icon(Icons.check, color: OpeiColors.pureBlack)
                    : null,
                  onTap: () => widget.onSelected(country),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class AddressTextField extends StatefulWidget {
  final String value;
  final ValueChanged<String> onChanged;
  final String hintText;
  final String? errorText;
  final TextInputType keyboardType;

  const AddressTextField({
    required this.value,
    required this.onChanged,
    required this.hintText,
    this.errorText,
    this.keyboardType = TextInputType.text,
    super.key,
  });

  @override
  State<AddressTextField> createState() => _AddressTextFieldState();
}

class _AddressTextFieldState extends State<AddressTextField> {
  late TextEditingController _controller;
  String? _validationError;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(AddressTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value && widget.value != _controller.text) {
      _controller.text = widget.value;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleChange(String value) {
    final validated = _validateInput(value);
    if (validated == null) {
      setState(() {
        _validationError = 'Invalid characters detected';
      });
    } else {
      setState(() {
        _validationError = null;
      });
      widget.onChanged(validated);
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

  @override
  Widget build(BuildContext context) {
    final displayError = widget.errorText ?? _validationError;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _controller,
          onChanged: _handleChange,
          keyboardType: widget.keyboardType,
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: OpeiColors.grey600,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: BorderSide(
                color: displayError != null ? OpeiColors.errorRed : OpeiColors.grey300,
                width: 1.5,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: BorderSide(
                color: displayError != null ? OpeiColors.errorRed : OpeiColors.grey300,
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: BorderSide(
                color: displayError != null ? OpeiColors.errorRed : OpeiColors.pureBlack,
                width: 2,
              ),
            ),
          ),
        ),
        if (displayError != null)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 4),
            child: Text(
              displayError,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: OpeiColors.errorRed,
              ),
            ),
          ),
      ],
    );
  }
}

class _AddressSuccessSheet extends StatelessWidget {
  final VoidCallback onDone;

  const _AddressSuccessSheet({required this.onDone});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      color: OpeiColors.pureBlack.withValues(alpha: 0.08),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 420),
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
              decoration: BoxDecoration(
                color: OpeiColors.pureWhite,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                boxShadow: [
                  BoxShadow(
                    color: OpeiColors.grey900.withValues(alpha: 0.1),
                    blurRadius: 28,
                    offset: const Offset(0, 18),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SuccessHero(iconHeight: 72, gap: 8),
                  const SizedBox(height: 16),
                  Text(
                    'Address Updated',
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your residential details have been saved.',
                    style: textTheme.bodyMedium?.copyWith(
                      color: OpeiColors.grey600,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: onDone,
                      child: const Text('Done'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
