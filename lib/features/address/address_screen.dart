import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:opei/core/constants/countries.dart';
import 'package:opei/core/providers/providers.dart';
import 'package:opei/core/utils/error_helper.dart';
import 'package:opei/features/address/address_state.dart';
import 'package:opei/theme.dart';
import 'package:opei/widgets/opei_premium/opei_premium.dart';
import 'package:opei/widgets/success_hero.dart';

class AddressScreen extends ConsumerStatefulWidget {
  final bool isFromProfile;

  const AddressScreen({super.key, this.isFromProfile = false});

  @override
  ConsumerState<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends ConsumerState<AddressScreen> {
  final _stateCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _zipCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _houseCtrl = TextEditingController();
  final _bvnCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final s = ref.read(addressControllerProvider);
    _stateCtrl.text = s.state;
    _cityCtrl.text = s.city;
    _zipCtrl.text = s.zipCode;
    _addressCtrl.text = s.addressLine;
    _houseCtrl.text = s.houseNumber;
    _bvnCtrl.text = s.bvn;
  }

  @override
  void dispose() {
    _stateCtrl.dispose();
    _cityCtrl.dispose();
    _zipCtrl.dispose();
    _addressCtrl.dispose();
    _houseCtrl.dispose();
    _bvnCtrl.dispose();
    super.dispose();
  }

  Future<void> _showProfileSuccessSheet() async {
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

  void _showError(String message) {
    showError(context, message);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(addressControllerProvider);
    final controller = ref.read(addressControllerProvider.notifier);

    ref.listen<AddressState>(addressControllerProvider, (previous, next) {
      if (previous != null && previous.isLoading && !next.isLoading) {
        if (next.errorMessage == null) {
          if (!context.mounted) return;
          if (widget.isFromProfile) {
            _showProfileSuccessSheet();
          } else {
            context.push('/kyc');
          }
        } else if (next.fieldErrors.isEmpty) {
          if (!context.mounted) return;
          _showError(next.errorMessage!);
        }
      }
    });

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: OpeiBrand.surface,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: OpeiBrand.surfaceMuted,
        appBar: OpeiAppBar(
          backgroundColor: OpeiBrand.surfaceMuted,
          currentStep: widget.isFromProfile ? null : 3,
          totalSteps: widget.isFromProfile ? null : 4,
          onBack: state.isLoading
              ? null
              : () {
                  final router = GoRouter.of(context);
                  if (router.canPop()) {
                    router.pop();
                  } else {
                    context.go('/welcome');
                  }
                },
        ),
        body: SafeArea(
          top: false,
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            behavior: HitTestBehavior.opaque,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 4, 24, 16),
                    physics: const ClampingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        const Text(
                          'Where do you live?',
                          style: TextStyle(
                            fontFamily: kPrimaryFontFamily,
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                            color: OpeiBrand.ink,
                            height: 1.15,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "We need your residential address to verify your account. This stays private.",
                          style: TextStyle(
                            fontFamily: kPrimaryFontFamily,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: OpeiBrand.inkSecondary,
                            letterSpacing: -0.2,
                            height: 1.45,
                          ),
                        ),
                        const SizedBox(height: 22),
                        IgnorePointer(
                          ignoring: state.isLoading,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _CountryPickerField(
                                selectedCountry: state.selectedCountry,
                                errorText: state.fieldErrors['country'],
                                onTap: () => _openCountryPicker(
                                  context: context,
                                  selected: state.selectedCountry,
                                  onSelected: controller.setCountry,
                                ),
                              ),
                              const SizedBox(height: 14),
                              Row(
                                children: [
                                  Expanded(
                                    child: OpeiTextField(
                                      controller: _addressCtrl,
                                      label: 'Address line',
                                      hint: '123 Main Street',
                                      textInputAction: TextInputAction.next,
                                      errorText: state.fieldErrors['addressLine'],
                                      onChanged: controller.updateAddressLine,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: OpeiTextField(
                                      controller: _houseCtrl,
                                      label: 'Apt / Suite',
                                      hint: 'Apt 4B',
                                      textInputAction: TextInputAction.next,
                                      errorText:
                                          state.fieldErrors['houseNumber'],
                                      onChanged: controller.updateHouseNumber,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    flex: 3,
                                    child: OpeiTextField(
                                      controller: _zipCtrl,
                                      label: 'ZIP code',
                                      hint: '10001',
                                      keyboardType: TextInputType.number,
                                      textInputAction: TextInputAction.next,
                                      errorText: state.fieldErrors['zipCode'],
                                      inputFormatters: [
                                        FilteringTextInputFormatter.allow(
                                          RegExp(r'[A-Za-z0-9\- ]'),
                                        ),
                                        LengthLimitingTextInputFormatter(12),
                                      ],
                                      onChanged: controller.updateZipCode,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              OpeiTextField(
                                controller: _cityCtrl,
                                label: 'City',
                                hint: 'New York',
                                textInputAction: TextInputAction.next,
                                errorText: state.fieldErrors['city'],
                                onChanged: controller.updateCity,
                              ),
                              const SizedBox(height: 14),
                              OpeiTextField(
                                controller: _stateCtrl,
                                label: 'State',
                                hint: 'NY',
                                textInputAction: TextInputAction.done,
                                errorText: state.fieldErrors['state'],
                                onChanged: controller.updateState,
                              ),
                              if (state.isNigeria) ...[
                                const SizedBox(height: 14),
                                OpeiTextField(
                                  controller: _bvnCtrl,
                                  label: 'BVN',
                                  hint: '11-digit Bank Verification Number',
                                  keyboardType: TextInputType.number,
                                  textInputAction: TextInputAction.done,
                                  errorText: state.fieldErrors['bvn'],
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(11),
                                  ],
                                  helperText: state.fieldErrors['bvn'] == null
                                      ? 'Required for Nigerian residents.'
                                      : null,
                                  onChanged: controller.updateBvn,
                                ),
                              ],
                              const SizedBox(height: 16),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                _BottomBar(
                  isLoading: state.isLoading,
                  enabled: state.isValid && !state.isLoading,
                  onContinue: () => controller.submitAddress(
                    fromProfile: widget.isFromProfile,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final bool isLoading;
  final bool enabled;
  final VoidCallback onContinue;

  const _BottomBar({
    required this.isLoading,
    required this.enabled,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: OpeiBrand.surface,
        border: Border(top: BorderSide(color: OpeiBrand.hairline, width: 1)),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        12,
        24,
        10 + MediaQuery.of(context).viewPadding.bottom,
      ),
      child: OpeiPrimaryButton(
        label: 'Continue',
        loading: isLoading,
        onPressed: enabled ? onContinue : null,
        trailingIcon: Icons.arrow_forward_rounded,
      ),
    );
  }
}

class _CountryPickerField extends StatelessWidget {
  final Country? selectedCountry;
  final String? errorText;
  final VoidCallback onTap;

  const _CountryPickerField({
    required this.selectedCountry,
    required this.errorText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null;
    final hasValue = selectedCountry != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 6),
          child: Text(
            'Country',
            style: TextStyle(
              fontFamily: kPrimaryFontFamily,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: OpeiBrand.inkSecondary,
              letterSpacing: -0.1,
            ),
          ),
        ),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(OpeiBrand.radiusField),
          child: AnimatedContainer(
            duration: OpeiBrand.motionFast,
            curve: OpeiBrand.motionCurve,
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: OpeiBrand.surface,
              borderRadius: BorderRadius.circular(OpeiBrand.radiusField),
              border: Border.all(
                color: hasError ? OpeiBrand.danger : OpeiBrand.hairline,
                width: hasError ? 1.5 : 1.0,
              ),
            ),
            child: Row(
              children: [
                if (hasValue) ...[
                  Container(
                    width: 28,
                    height: 28,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: OpeiBrand.primaryTint,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      selectedCountry!.iso,
                      style: const TextStyle(
                        fontFamily: kPrimaryFontFamily,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: OpeiBrand.primary,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: Text(
                    hasValue ? selectedCountry!.name : 'Select country',
                    style: TextStyle(
                      fontFamily: kPrimaryFontFamily,
                      fontSize: 15,
                      fontWeight: hasValue ? FontWeight.w500 : FontWeight.w400,
                      color: hasValue ? OpeiBrand.ink : OpeiBrand.inkTertiary,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
                const Icon(
                  Icons.expand_more_rounded,
                  color: OpeiBrand.inkTertiary,
                  size: 22,
                ),
              ],
            ),
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Text(
              errorText!,
              style: const TextStyle(
                fontFamily: kPrimaryFontFamily,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: OpeiBrand.danger,
              ),
            ),
          ),
      ],
    );
  }
}

void _openCountryPicker({
  required BuildContext context,
  required Country? selected,
  required ValueChanged<Country> onSelected,
}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    barrierColor: Colors.black.withValues(alpha: 0.4),
    builder: (sheetContext) {
      return _CountryPickerSheet(
        selected: selected,
        onSelected: (c) {
          onSelected(c);
          Navigator.pop(sheetContext);
        },
      );
    },
  );
}

class _CountryPickerSheet extends StatefulWidget {
  final Country? selected;
  final ValueChanged<Country> onSelected;

  const _CountryPickerSheet({
    required this.selected,
    required this.onSelected,
  });

  @override
  State<_CountryPickerSheet> createState() => _CountryPickerSheetState();
}

class _CountryPickerSheetState extends State<_CountryPickerSheet> {
  final _searchCtrl = TextEditingController();
  late List<Country> _filtered = allowedCountries;

  void _filter(String q) {
    setState(() {
      if (q.isEmpty) {
        _filtered = allowedCountries;
      } else {
        final ql = q.toLowerCase();
        _filtered = allowedCountries
            .where((c) =>
                c.name.toLowerCase().contains(ql) ||
                c.iso.toLowerCase().contains(ql))
            .toList();
      }
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
      child: Container(
        height: media.size.height * 0.78,
        decoration: const BoxDecoration(
          color: OpeiBrand.surface,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(OpeiBrand.radiusSheet),
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: OpeiBrand.hairlineStrong,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Select country',
              style: TextStyle(
                fontFamily: kPrimaryFontFamily,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: OpeiBrand.ink,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: OpeiTextField(
                controller: _searchCtrl,
                hint: 'Search country',
                onChanged: _filter,
                prefix: const Icon(
                  Icons.search_rounded,
                  size: 20,
                  color: OpeiBrand.inkTertiary,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 4),
                itemCount: _filtered.length,
                separatorBuilder: (_, _) => const Divider(
                  height: 1,
                  thickness: 1,
                  color: OpeiBrand.hairline,
                  indent: 60,
                ),
                itemBuilder: (context, index) {
                  final country = _filtered[index];
                  final isSelected = widget.selected?.iso == country.iso;
                  return InkWell(
                    onTap: () => widget.onSelected(country),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 14),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: OpeiBrand.primaryTint,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              country.iso,
                              style: const TextStyle(
                                fontFamily: kPrimaryFontFamily,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: OpeiBrand.primary,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              country.name,
                              style: TextStyle(
                                fontFamily: kPrimaryFontFamily,
                                fontSize: 15,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                                color: OpeiBrand.ink,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ),
                          if (isSelected)
                            const Icon(
                              Icons.check_rounded,
                              color: OpeiBrand.primary,
                              size: 20,
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddressSuccessSheet extends StatelessWidget {
  final VoidCallback onDone;

  const _AddressSuccessSheet({required this.onDone});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.08),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 420),
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
              decoration: BoxDecoration(
                color: OpeiBrand.surface,
                borderRadius: BorderRadius.circular(OpeiBrand.radiusCard),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SuccessHero(iconHeight: 72, gap: 8),
                  const SizedBox(height: 14),
                  const Text(
                    'Address updated',
                    style: TextStyle(
                      fontFamily: kPrimaryFontFamily,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: OpeiBrand.ink,
                      letterSpacing: -0.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Your residential details have been saved.',
                    style: TextStyle(
                      fontFamily: kPrimaryFontFamily,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: OpeiBrand.inkSecondary,
                      letterSpacing: -0.2,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  OpeiPrimaryButton(label: 'Done', onPressed: onDone),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
