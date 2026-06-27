import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opei/core/money/money.dart';
import 'package:opei/core/navigation/opei_page_transitions.dart';
import 'package:opei/core/providers/providers.dart';
import 'package:opei/core/utils/error_helper.dart';
import 'package:opei/data/models/money_movement_availability.dart';
import 'package:opei/data/models/mobile_money_deposit.dart';
import 'package:opei/features/dashboard/dashboard_controller.dart';
import 'package:opei/features/money_movement/availability_controller.dart';
import 'package:opei/l10n/app_localizations.dart';
import 'package:opei/theme.dart';

// ─── Country selection (full-screen list) ────────────────────────────────────

class MobileMoneyDepositCountryScreen extends ConsumerWidget {
  const MobileMoneyDepositCountryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final availability = availabilityFromAsync(
      ref.watch(moneyMovementAvailabilityProvider),
    );
    final express = availability.deposit.expressP2P;
    final malawiEnabled =
        express.isCurrencyEnabled('MWK') && express.hasAnyEnabledNetwork('MWK');
    final networksLabel = _enabledDepositNetworks(
      availability,
    ).map((item) => item.name).join(' · ');

    // List of available deposit countries (only Malawi for now)
    final countries =
        <
          ({
            String flag,
            String name,
            bool enabled,
            String networks,
            VoidCallback onTap,
          })
        >[
          (
            flag: '🇲🇼',
            name: l10n.mobileMoneyCountryMalawi,
            enabled: malawiEnabled,
            networks: malawiEnabled
                ? (networksLabel.isEmpty
                      ? l10n.mobileMoneyLabel
                      : networksLabel)
                : l10n.notAvailableLabel,
            onTap: () => Navigator.of(context).push(
              OpeiPageRoute(
                builder: (_) => const MalawiMobileMoneyDepositScreen(),
              ),
            ),
          ),
        ];

    return Scaffold(
      backgroundColor: OpeiBrand.surface,
      appBar: AppBar(
        backgroundColor: OpeiBrand.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(l10n.mobileMoneyLabel),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(height: 0.5, color: OpeiBrand.hairline),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
              child: Text(
                l10n.addressSelectCountryTitle,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: OpeiBrand.inkTertiary,
                  letterSpacing: .9,
                ),
              ),
            ),
            const Divider(
              height: 0.5,
              thickness: 0.5,
              color: OpeiBrand.hairline,
            ),
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.zero,
                itemCount: countries.length,
                separatorBuilder: (context, index) => const Divider(
                  height: 0.5,
                  thickness: 0.5,
                  indent: 72,
                  color: OpeiBrand.hairline,
                ),
                itemBuilder: (context, i) {
                  final c = countries[i];
                  return Opacity(
                    opacity: c.enabled ? 1.0 : 0.45,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: c.enabled ? c.onTap : null,
                        splashColor: OpeiBrand.primary.withValues(alpha: 0.04),
                        highlightColor: OpeiBrand.surfaceMuted,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 14,
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: OpeiBrand.surfaceMuted,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  c.flag,
                                  style: const TextStyle(fontSize: 22),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      c.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: OpeiBrand.ink,
                                        letterSpacing: -0.2,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      c.networks,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: OpeiBrand.inkSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.chevron_right_rounded,
                                size: 18,
                                color: OpeiBrand.inkTertiary,
                              ),
                            ],
                          ),
                        ),
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

// ─── Saved numbers list ───────────────────────────────────────────────────────

class MalawiMobileMoneyDepositScreen extends ConsumerStatefulWidget {
  const MalawiMobileMoneyDepositScreen({super.key});

  @override
  ConsumerState<MalawiMobileMoneyDepositScreen> createState() =>
      _MalawiMobileMoneyDepositScreenState();
}

class _MalawiMobileMoneyDepositScreenState
    extends ConsumerState<MalawiMobileMoneyDepositScreen> {
  bool _loading = true;
  String? _error;
  List<SavedMobileNumber> _numbers = const [];
  String? _selectedNumberId;

  // Track which number is being set as primary
  String _settingPrimaryId = '';
  String _deletingNumberId = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadNumbers());
  }

  Future<void> _loadNumbers() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final repo = ref.read(mobileMoneyDepositRepositoryProvider);
      final items = await repo.listSavedNumbers(active: true);
      items.sort((a, b) {
        if (a.isPrimary != b.isPrimary) return a.isPrimary ? -1 : 1;
        return (b.updatedAt ?? DateTime(0)).compareTo(
          a.updatedAt ?? DateTime(0),
        );
      });
      if (!mounted) return;
      setState(() {
        _numbers = items;
        if (_selectedNumberId != null &&
            !_numbers.any((n) => n.id == _selectedNumberId)) {
          _selectedNumberId = null;
        }
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = ErrorHelper.getErrorMessage(error);
        _loading = false;
      });
    }
  }

  Future<void> _openAddSheet() async {
    final availability = availabilityFromAsync(
      ref.read(moneyMovementAvailabilityProvider),
    );
    final enabledNetworks = _enabledDepositNetworks(availability);
    if (enabledNetworks.isEmpty) {
      showError(context, AppLocalizations.of(context)!.errServiceUnavailable);
      return;
    }
    final added = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddMobileNumberSheet(availableNetworks: enabledNetworks),
    );
    if (added == true) await _loadNumbers();
  }

  Future<void> _setPrimary(SavedMobileNumber number) async {
    setState(() => _settingPrimaryId = number.id);
    try {
      await ref
          .read(mobileMoneyDepositRepositoryProvider)
          .updateNumber(numberId: number.id, isPrimary: true);
      if (!mounted) return;
      showSuccess(
        context,
        AppLocalizations.of(context)!.mobileMoneyPrimaryUpdated,
      );
      await _loadNumbers();
    } catch (error) {
      if (!mounted) return;
      showError(context, ErrorHelper.getErrorMessage(error));
    } finally {
      if (mounted) setState(() => _settingPrimaryId = '');
    }
  }

  Future<void> _deleteNumber(SavedMobileNumber number) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.mobileMoneyDeleteNumberTitle),
          content: Text(l10n.mobileMoneyDeleteNumberMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(l10n.cancelCta),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: TextButton.styleFrom(foregroundColor: OpeiBrand.danger),
              child: Text(l10n.deleteCta),
            ),
          ],
        );
      },
    );
    if (confirmed != true) return;

    setState(() => _deletingNumberId = number.id);
    try {
      await ref
          .read(mobileMoneyDepositRepositoryProvider)
          .deleteNumber(numberId: number.id);
      if (!mounted) return;
      showSuccess(context, l10n.mobileMoneyNumberDeletedSuccess);
      await _loadNumbers();
    } catch (error) {
      if (!mounted) return;
      showError(context, ErrorHelper.getErrorMessage(error));
    } finally {
      if (mounted) setState(() => _deletingNumberId = '');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final availability = availabilityFromAsync(
      ref.watch(moneyMovementAvailabilityProvider),
    );
    final enabledNetworks = _enabledDepositNetworks(availability);
    final enabledCodes = enabledNetworks
        .map((item) => item.code.toUpperCase())
        .toSet();
    final visibleNumbers = _numbers
        .where((n) => enabledCodes.contains(n.channel.toUpperCase()))
        .toList(growable: false);
    SavedMobileNumber? selected;
    for (final number in visibleNumbers) {
      if (number.id == _selectedNumberId) {
        selected = number;
        break;
      }
    }

    return Scaffold(
      backgroundColor: OpeiBrand.surface,
      appBar: AppBar(
        backgroundColor: OpeiBrand.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(l10n.mobileMoneyLabel),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(height: 0.5, color: OpeiBrand.hairline),
        ),
        actions: [
          if (enabledNetworks.isNotEmpty)
            TextButton.icon(
              onPressed: _openAddSheet,
              icon: const Icon(Icons.add_rounded, size: 16),
              label: Text(l10n.mobileMoneyAddNewNumber),
              style: TextButton.styleFrom(
                foregroundColor: OpeiBrand.primary,
                textStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // Content
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : _error != null
                  ? _ErrorView(message: _error!, onRetry: _loadNumbers)
                  : enabledNetworks.isEmpty
                  ? _ErrorView(
                      message: l10n.errServiceUnavailable,
                      onRetry: _loadNumbers,
                    )
                  : visibleNumbers.isEmpty
                  ? _EmptyView(onAdd: _openAddSheet)
                  : RefreshIndicator(
                      onRefresh: _loadNumbers,
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        itemCount: visibleNumbers.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final number = visibleNumbers[index];
                          final isSelected = number.id == _selectedNumberId;
                          return _NumberCard(
                            number: number,
                            isSelected: isSelected,
                            isSettingPrimary: _settingPrimaryId == number.id,
                            isDeleting: _deletingNumberId == number.id,
                            onTap: () =>
                                setState(() => _selectedNumberId = number.id),
                            onSetPrimary: () => _setPrimary(number),
                            onDelete: () => _deleteNumber(number),
                          );
                        },
                      ),
                    ),
            ),

            // Bottom CTA
            Container(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
              child: SafeArea(
                top: false,
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: selected == null
                        ? null
                        : () {
                            Navigator.of(context).push(
                              OpeiPageRoute(
                                builder: (_) => MobileMoneyDepositAmountScreen(
                                  number: selected!,
                                ),
                              ),
                            );
                          },
                    child: Text(l10n.continueCta),
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

// ─── Number card ─────────────────────────────────────────────────────────────

class _NumberCard extends StatelessWidget {
  final SavedMobileNumber number;
  final bool isSelected;
  final bool isSettingPrimary;
  final bool isDeleting;
  final VoidCallback onTap;
  final VoidCallback onSetPrimary;
  final VoidCallback onDelete;

  const _NumberCard({
    required this.number,
    required this.isSelected,
    required this.isSettingPrimary,
    required this.isDeleting,
    required this.onTap,
    required this.onSetPrimary,
    required this.onDelete,
  });

  Color _networkColor() {
    final ch = number.channel.toUpperCase();
    if (ch == 'AIRTEL') return const Color(0xFFE8382B);
    if (ch == 'TNM') return const Color(0xFF1B9E4B);
    return OpeiBrand.primary;
  }

  String _networkInitial() =>
      number.channel.isNotEmpty ? number.channel[0].toUpperCase() : '?';

  @override
  Widget build(BuildContext context) {
    final color = _networkColor();
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(OpeiBrand.radiusCard),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isSelected ? OpeiBrand.primaryTint : OpeiBrand.surfaceMuted,
            borderRadius: BorderRadius.circular(OpeiBrand.radiusCard),
            border: Border.all(
              color: isSelected ? OpeiBrand.primary : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              // Network avatar
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  _networkInitial(),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            number.name,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: OpeiBrand.ink,
                              letterSpacing: -0.2,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        if (number.isPrimary) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: OpeiBrand.success.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(99),
                            ),
                            child: Text(
                              AppLocalizations.of(context)!.mobileMoneyPrimary,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: OpeiBrand.success,
                                letterSpacing: .3,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${number.channel} · ${number.mobileRaw.isNotEmpty ? number.mobileRaw : number.mobileNormalized}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: OpeiBrand.inkSecondary,
                        letterSpacing: -0.1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Right side: set-primary or selection indicator
              if (!number.isPrimary && !isDeleting)
                isSettingPrimary
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: OpeiBrand.primary,
                        ),
                      )
                    : GestureDetector(
                        onTap: onSetPrimary,
                        child: Text(
                          AppLocalizations.of(context)!.mobileMoneySetPrimary,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? OpeiBrand.primary
                                : OpeiBrand.inkSecondary,
                          ),
                        ),
                      ),
              if (isDeleting)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: OpeiBrand.primary,
                  ),
                ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: isDeleting ? null : onDelete,
                child: Icon(
                  Icons.delete_outline_rounded,
                  size: 18,
                  color: isDeleting ? OpeiBrand.inkTertiary : OpeiBrand.danger,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                isSelected
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                size: 22,
                color: isSelected ? OpeiBrand.primary : OpeiBrand.inkTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Empty / error states ─────────────────────────────────────────────────────

class _EmptyView extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptyView({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: OpeiBrand.primaryTint,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.phone_android_rounded,
                color: OpeiBrand.primary,
                size: 30,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.mobileMoneyNoReceiversTitle,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: OpeiBrand.ink,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              l10n.mobileMoneyNoReceiversSubtitle,
              style: const TextStyle(
                fontSize: 14,
                color: OpeiBrand.inkSecondary,
                height: 1.45,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_rounded, size: 16),
              label: Text(l10n.mobileMoneyAddNewNumber),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.wifi_off_rounded,
              color: OpeiBrand.inkTertiary,
              size: 40,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: OpeiBrand.inkSecondary,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: onRetry,
              child: Text(AppLocalizations.of(context)!.retryCta),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Add number sheet ─────────────────────────────────────────────────────────

class _AddMobileNumberSheet extends ConsumerStatefulWidget {
  final List<_DepositNetworkOption> availableNetworks;

  const _AddMobileNumberSheet({required this.availableNetworks});

  @override
  ConsumerState<_AddMobileNumberSheet> createState() =>
      _AddMobileNumberSheetState();
}

class _AddMobileNumberSheetState extends ConsumerState<_AddMobileNumberSheet> {
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _channel = 'AIRTEL';
  bool _submitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    super.dispose();
  }

  String? _normalizeMalawiMobile(String raw) {
    final digitsOnly = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.length == 9) return digitsOnly;
    if (digitsOnly.length == 10 && digitsOnly.startsWith('0')) {
      return digitsOnly.substring(1);
    }
    if (digitsOnly.length == 12 && digitsOnly.startsWith('265')) {
      return digitsOnly.substring(3);
    }
    return null;
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final normalizedMobile = _normalizeMalawiMobile(_mobileController.text);
    if (normalizedMobile == null) {
      showError(context, l10n.mobileMoneyPhoneRequired);
      return;
    }
    setState(() => _submitting = true);
    try {
      await ref
          .read(mobileMoneyDepositRepositoryProvider)
          .addNumber(
            name: _nameController.text.trim(),
            channel: _channel,
            mobile: normalizedMobile,
            isPrimary: false,
          );
      if (!mounted) return;
      showSuccess(context, l10n.mobileMoneyReceiverAdded);
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      setState(() => _submitting = false);
      showError(context, ErrorHelper.getErrorMessage(error));
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.availableNetworks.isNotEmpty) {
      _channel = widget.availableNetworks.first.code;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;
    final bottomPad = MediaQuery.of(context).viewPadding.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: viewInsets),
      child: Container(
        decoration: const BoxDecoration(
          color: OpeiBrand.surface,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(OpeiBrand.radiusSheet),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            const SizedBox(height: 14),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: OpeiBrand.hairlineStrong,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            const SizedBox(height: 16),

            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.mobileMoneyAddNewNumber,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: OpeiBrand.ink,
                        letterSpacing: -0.4,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded, size: 20),
                    color: OpeiBrand.inkTertiary,
                    style: IconButton.styleFrom(
                      backgroundColor: OpeiBrand.surfaceMuted,
                      minimumSize: const Size(32, 32),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Form
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Name
                    TextFormField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        labelText: l10n.mobileMoneyReceiverNameLabel,
                        hintText: l10n.mobileMoneyReceiverFullNameHint,
                        prefixIcon: const Icon(
                          Icons.person_outline_rounded,
                          size: 20,
                        ),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? l10n.mobileMoneyReceiverFullNameRequired
                          : null,
                    ),
                    const SizedBox(height: 12),

                    // Network selector (segmented style)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.networkLabel,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: OpeiBrand.inkSecondary,
                            letterSpacing: .2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            for (
                              var i = 0;
                              i < widget.availableNetworks.length;
                              i++
                            ) ...[
                              _NetworkOption(
                                label: widget.availableNetworks[i].name,
                                value: widget.availableNetworks[i].code,
                                networkColor: widget.availableNetworks[i].color,
                                initial: widget.availableNetworks[i].initial,
                                isSelected:
                                    _channel ==
                                    widget.availableNetworks[i].code,
                                onTap: _submitting
                                    ? null
                                    : () => setState(
                                        () => _channel =
                                            widget.availableNetworks[i].code,
                                      ),
                              ),
                              if (i != widget.availableNetworks.length - 1)
                                const SizedBox(width: 10),
                            ],
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Phone
                    TextFormField(
                      controller: _mobileController,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9+]')),
                      ],
                      decoration: InputDecoration(
                        labelText: l10n.phoneNumberLabel,
                        hintText: l10n.mobileMoneyPhoneHintMw,
                        prefixIcon: const Icon(Icons.phone_outlined, size: 20),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? l10n.mobileMoneyPhoneRequired
                          : (_normalizeMalawiMobile(v) == null
                                ? l10n.mobileMoneyPhoneRequired
                                : null),
                    ),
                    const SizedBox(height: 18),

                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _submitting ? null : _submit,
                        child: _submitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(l10n.mobileMoneySaveReceiverCta),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 14 + bottomPad),
          ],
        ),
      ),
    );
  }
}

class _NetworkOption extends StatelessWidget {
  final String label;
  final String value;
  final Color networkColor;
  final String initial;
  final bool isSelected;
  final VoidCallback? onTap;

  const _NetworkOption({
    required this.label,
    required this.value,
    required this.networkColor,
    required this.initial,
    required this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? networkColor.withValues(alpha: 0.08)
                : OpeiBrand.surfaceMuted,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? networkColor : OpeiBrand.hairline,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: networkColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  initial,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: networkColor,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? networkColor : OpeiBrand.ink,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Amount entry + preview + confirm ────────────────────────────────────────

class MobileMoneyDepositAmountScreen extends ConsumerStatefulWidget {
  final SavedMobileNumber number;

  const MobileMoneyDepositAmountScreen({super.key, required this.number});

  @override
  ConsumerState<MobileMoneyDepositAmountScreen> createState() =>
      _MobileMoneyDepositAmountScreenState();
}

class _MobileMoneyDepositAmountScreenState
    extends ConsumerState<MobileMoneyDepositAmountScreen> {
  final _amountController = TextEditingController();
  bool _loadingPreview = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  int? _amountCents() {
    final raw = _amountController.text.trim();
    if (raw.isEmpty) return null;
    try {
      return Money.parse(raw, currency: 'USD').cents;
    } catch (_) {
      return null;
    }
  }

  Future<void> _previewDeposit() async {
    final l10n = AppLocalizations.of(context)!;
    final cents = _amountCents();
    if (cents == null || cents <= 0) {
      showError(context, l10n.sendMoneyValidAmountError);
      return;
    }
    setState(() {
      _loadingPreview = true;
    });
    try {
      final result = await ref
          .read(mobileMoneyDepositRepositoryProvider)
          .previewDeposit(
            amountUsdCents: cents,
            channel: widget.number.channel,
          );
      if (!mounted) return;
      setState(() => _loadingPreview = false);
      Navigator.of(context).push(
        OpeiPageRoute(
          builder: (_) => MobileMoneyDepositPreviewScreen(
            number: widget.number,
            preview: result,
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _loadingPreview = false);
      showError(context, ErrorHelper.getErrorMessage(error));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: OpeiBrand.surface,
      appBar: AppBar(
        backgroundColor: OpeiBrand.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(l10n.mobileMoneyLabel),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: OpeiBrand.surfaceMuted,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: OpeiBrand.hairline),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.phone_iphone_rounded,
                  size: 18,
                  color: OpeiBrand.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.number.mobileRaw.isNotEmpty
                        ? widget.number.mobileRaw
                        : widget.number.mobileNormalized,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: OpeiBrand.ink,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.amountLabel.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: OpeiBrand.inkTertiary,
              letterSpacing: .9,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
            ],
            decoration: InputDecoration(
              labelText: l10n.amountLabel,
              hintText: l10n.sendMoneyAmountHint,
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          child: SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: _loadingPreview ? null : _previewDeposit,
              child: _loadingPreview
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(l10n.mobileMoneyDepositPreviewCta),
            ),
          ),
        ),
      ),
    );
  }
}

class MobileMoneyDepositPreviewScreen extends ConsumerStatefulWidget {
  final SavedMobileNumber number;
  final MobileMoneyDepositPreview preview;

  const MobileMoneyDepositPreviewScreen({
    super.key,
    required this.number,
    required this.preview,
  });

  @override
  ConsumerState<MobileMoneyDepositPreviewScreen> createState() =>
      _MobileMoneyDepositPreviewScreenState();
}

class _MobileMoneyDepositPreviewScreenState
    extends ConsumerState<MobileMoneyDepositPreviewScreen> {
  bool _initiating = false;

  Future<void> _initiateDeposit() async {
    setState(() => _initiating = true);
    try {
      final initiation = await ref
          .read(mobileMoneyDepositRepositoryProvider)
          .initiateDeposit(
            savedMobileNumberId: widget.number.id,
            amountUsdCents: widget.preview.amountUsdCents,
            channel: widget.number.channel,
          );
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        OpeiPageRoute(
          builder: (_) => MobileMoneyDepositProcessingScreen(
            transactionId: initiation.transactionId,
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _initiating = false);
      showError(context, ErrorHelper.getErrorMessage(error));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final networkColor = widget.number.channel == 'AIRTEL'
        ? const Color(0xFFE8382B)
        : const Color(0xFF1B9E4B);
    return Scaffold(
      backgroundColor: OpeiBrand.surface,
      appBar: AppBar(
        backgroundColor: OpeiBrand.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(l10n.mobileMoneyDepositSummaryTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          _PreviewCard(
            preview: widget.preview,
            channel: widget.number.channel,
            networkColor: networkColor,
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          child: SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: _initiating ? null : _initiateDeposit,
              child: _initiating
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(l10n.confirmTopupCta),
            ),
          ),
        ),
      ),
    );
  }
}

class MobileMoneyDepositProcessingScreen extends ConsumerStatefulWidget {
  final String transactionId;

  const MobileMoneyDepositProcessingScreen({
    super.key,
    required this.transactionId,
  });

  @override
  ConsumerState<MobileMoneyDepositProcessingScreen> createState() =>
      _MobileMoneyDepositProcessingScreenState();
}

class _MobileMoneyDepositProcessingScreenState
    extends ConsumerState<MobileMoneyDepositProcessingScreen> {
  static const _pollInterval = Duration(seconds: 5);
  static const _hardTimeout = Duration(minutes: 2);

  Timer? _pollTimer;
  Timer? _timeoutTimer;
  MobileMoneyDepositStatus? _status;
  String? _statusError;
  bool _polling = true;
  bool _timedOut = false;

  @override
  void initState() {
    super.initState();
    _startPolling();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _timeoutTimer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    _pollOnce();
    _pollTimer = Timer.periodic(_pollInterval, (_) => _pollOnce());
    _timeoutTimer = Timer(_hardTimeout, _onTimeout);
  }

  Future<void> _pollOnce() async {
    try {
      final next = await ref
          .read(mobileMoneyDepositRepositoryProvider)
          .fetchDepositStatus(transactionId: widget.transactionId);
      if (!mounted) return;
      setState(() {
        _status = next;
        _statusError = null;
      });
      if (next.isTerminal) {
        _pollTimer?.cancel();
        _timeoutTimer?.cancel();
        setState(() => _polling = false);
        if (next.status == 'SUCCESS_CREDITED') {
          unawaited(
            ref
                .read(dashboardControllerProvider.notifier)
                .refreshBalance(showSpinner: false),
          );
        }
      }
    } catch (error) {
      if (!mounted) return;
      setState(() => _statusError = ErrorHelper.getErrorMessage(error));
    }
  }

  void _onTimeout() {
    _pollTimer?.cancel();
    if (!mounted) return;
    setState(() {
      _polling = false;
      _timedOut = true;
    });
    Future<void>.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      Navigator.of(context).popUntil((route) => route.isFirst);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final status = _status;
    final title = _timedOut
        ? l10n.mobileMoneyDepositStillProcessingTitle
        : status == null || status.status == 'PENDING'
        ? l10n.mobileMoneyDepositProcessingTitle
        : status.status == 'SUCCESS_CREDITED'
        ? l10n.mobileMoneyDepositSuccessTitle
        : status.status == 'FAILED'
        ? l10n.mobileMoneyDepositFailedTitle
        : l10n.mobileMoneyDepositReviewTitle;
    final message = _timedOut
        ? l10n.mobileMoneyDepositStillProcessingMessage
        : status == null || status.status == 'PENDING'
        ? l10n.mobileMoneyDepositProcessingMessage
        : status.status == 'SUCCESS_CREDITED'
        ? l10n.mobileMoneyDepositSuccessMessage
        : status.status == 'FAILED'
        ? l10n.mobileMoneyDepositFailedMessage
        : l10n.mobileMoneyDepositReviewMessage;

    final showDone = !_polling && !_timedOut;

    return Scaffold(
      backgroundColor: OpeiBrand.surface,
      appBar: AppBar(
        backgroundColor: OpeiBrand.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(l10n.mobileMoneyLabel),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        children: [
          if (_polling)
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          if (_polling) const SizedBox(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: OpeiBrand.ink,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: OpeiBrand.inkSecondary,
              height: 1.4,
            ),
          ),
          if (_statusError != null) ...[
            const SizedBox(height: 10),
            Text(
              _statusError!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: OpeiBrand.inkTertiary,
              ),
            ),
          ],
        ],
      ),
      bottomNavigationBar: showDone
          ? SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                child: SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(
                      context,
                    ).popUntil((route) => route.isFirst),
                    child: Text(l10n.doneCta),
                  ),
                ),
              ),
            )
          : null,
    );
  }
}

class _QuickChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _QuickChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: OpeiBrand.primaryTint,
          borderRadius: BorderRadius.circular(99),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: kPrimaryFontFamily,
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: OpeiBrand.primary,
          ),
        ),
      ),
    );
  }
}

class _PreviewCard extends StatelessWidget {
  final MobileMoneyDepositPreview preview;
  final String channel;
  final Color networkColor;

  const _PreviewCard({
    required this.preview,
    required this.channel,
    required this.networkColor,
  });

  @override
  Widget build(BuildContext context) {
    final usd = (preview.amountUsdCents / 100).toStringAsFixed(2);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: OpeiBrand.surfaceMuted,
        borderRadius: BorderRadius.circular(OpeiBrand.radiusCard),
        border: Border.all(color: OpeiBrand.hairline, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.mobileMoneyDepositSummaryTitle,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: OpeiBrand.inkTertiary,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 12),
          _PreviewRow(
            label: AppLocalizations.of(context)!.amountLabel,
            value: '\$$usd',
            valueStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: OpeiBrand.ink,
            ),
          ),
          if (preview.amountMwk != null) ...[
            const SizedBox(height: 8),
            _PreviewRow(
              label: AppLocalizations.of(
                context,
              )!.mobileMoneyMwkEquivalentLabel,
              value: 'MWK ${preview.amountMwk}',
              valueStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: OpeiBrand.inkSecondary,
              ),
            ),
          ],
          const SizedBox(height: 8),
          _PreviewRow(
            label: AppLocalizations.of(context)!.networkLabel,
            value: channel,
            valueStyle: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: networkColor,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: OpeiBrand.warning.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 14,
                  color: OpeiBrand.warning,
                ),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    AppLocalizations.of(context)!.mobileMoneyDepositPromptHint,
                    style: TextStyle(
                      fontSize: 12,
                      color: OpeiBrand.warning,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewRow extends StatelessWidget {
  final String label;
  final String value;
  final TextStyle? valueStyle;

  const _PreviewRow({
    required this.label,
    required this.value,
    this.valueStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 13, color: OpeiBrand.inkSecondary),
          ),
        ),
        Flexible(
          child: Text(
            value,
            style:
                valueStyle ??
                const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: OpeiBrand.ink,
                ),
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _DepositNetworkOption {
  final String code;
  final String name;
  final Color color;
  final String initial;

  const _DepositNetworkOption({
    required this.code,
    required this.name,
    required this.color,
    required this.initial,
  });
}

List<_DepositNetworkOption> _enabledDepositNetworks(
  MoneyMovementAvailability availability,
) {
  final currency = availability.deposit.expressP2P.currency('MWK');
  if (currency == null || !currency.enabled) return const [];
  if (currency.networks.isEmpty) {
    return const [
      _DepositNetworkOption(
        code: 'AIRTEL',
        name: 'Airtel Money',
        color: Color(0xFFE8382B),
        initial: 'A',
      ),
      _DepositNetworkOption(
        code: 'TNM',
        name: 'TNM Mpamba',
        color: Color(0xFF1A6FD4),
        initial: 'T',
      ),
    ];
  }
  return currency.networks
      .where((network) => network.enabled)
      .map(
        (network) => _DepositNetworkOption(
          code: network.code.toUpperCase(),
          name: (network.name ?? network.code).trim(),
          color: _networkColorForCode(network.code),
          initial: network.code.isEmpty ? '?' : network.code[0].toUpperCase(),
        ),
      )
      .toList(growable: false);
}

Color _networkColorForCode(String code) {
  switch (code.toUpperCase()) {
    case 'AIRTEL':
      return const Color(0xFFE8382B);
    case 'TNM':
      return const Color(0xFF1B9E4B);
    default:
      return OpeiBrand.primary;
  }
}
