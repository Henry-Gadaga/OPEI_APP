import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:opei/core/money/money.dart';
import 'package:opei/core/navigation/opei_page_transitions.dart';
import 'package:opei/core/providers/providers.dart';
import 'package:opei/core/utils/error_helper.dart';
import 'package:opei/data/models/money_movement_availability.dart';
import 'package:opei/data/models/mobile_money_deposit.dart';
import 'package:opei/data/models/mobile_money_withdrawal.dart';
import 'package:opei/features/dashboard/dashboard_controller.dart';
import 'package:opei/features/money_movement/availability_controller.dart';
import 'package:opei/l10n/app_localizations.dart';
import 'package:opei/theme.dart';

class MalawiMobileMoneyWithdrawalScreen extends ConsumerStatefulWidget {
  const MalawiMobileMoneyWithdrawalScreen({super.key});

  @override
  ConsumerState<MalawiMobileMoneyWithdrawalScreen> createState() =>
      _MalawiMobileMoneyWithdrawalScreenState();
}

class _MalawiMobileMoneyWithdrawalScreenState
    extends ConsumerState<MalawiMobileMoneyWithdrawalScreen> {
  String? _selectedNumberId;

  bool _loadingNumbers = true;
  String? _numbersError;
  List<SavedMobileNumber> _numbers = const [];
  String _settingPrimaryId = '';
  String _deletingNumberId = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadNumbers());
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadNumbers() async {
    setState(() {
      _loadingNumbers = true;
      _numbersError = null;
    });
    try {
      final items = await ref
          .read(mobileMoneyDepositRepositoryProvider)
          .listSavedNumbers(active: true);
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
        _loadingNumbers = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _numbersError = ErrorHelper.getErrorMessage(error);
        _loadingNumbers = false;
      });
    }
  }

  Future<void> _openAddSheet() async {
    final availability = availabilityFromAsync(
      ref.read(moneyMovementAvailabilityProvider),
    );
    final enabledNetworks = _enabledNetworks(availability)
        .map(
          (item) => _WithdrawalNetworkOption(
            code: item.code.toUpperCase(),
            name: (item.name ?? item.code).trim(),
            color: _channelColorForCode(item.code),
            initial: item.code.isEmpty ? '?' : item.code[0].toUpperCase(),
          ),
        )
        .toList(growable: false);
    if (enabledNetworks.isEmpty) {
      showError(context, AppLocalizations.of(context)!.errServiceUnavailable);
      return;
    }
    final added = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          _AddWithdrawalMobileNumberSheet(availableNetworks: enabledNetworks),
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
      builder: (dialogContext) => AlertDialog(
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
      ),
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

  List<RailToggle> _enabledNetworks(MoneyMovementAvailability availability) {
    final country = availability.withdrawal.mobileMoney.country('MW');
    if (country == null || !country.enabled) return const [];
    if (country.networks.isEmpty) {
      return const [
        RailToggle(code: 'AIRTEL', name: 'Airtel Money', enabled: true),
        RailToggle(code: 'TNM', name: 'TNM Mpamba', enabled: true),
      ];
    }
    return country.networks
        .where((item) => item.enabled)
        .toList(growable: false);
  }

  void _continueToAmount() {
    final l10n = AppLocalizations.of(context)!;
    final availability = availabilityFromAsync(
      ref.read(moneyMovementAvailabilityProvider),
    );
    final enabledCodes = _enabledNetworks(
      availability,
    ).map((item) => item.code.toUpperCase()).toSet();
    final selectableNumbers = _numbers
        .where((n) => enabledCodes.contains(n.channel.toUpperCase()))
        .toList(growable: false);

    if (selectableNumbers.isEmpty) {
      showError(context, l10n.mobileMoneyWithdrawalNoSavedNumbers);
      return;
    }
    if (_selectedNumberId == null) {
      showError(context, l10n.mobileMoneyWithdrawalSelectSavedNumberError);
      return;
    }
    final selected = selectableNumbers.firstWhere(
      (n) => n.id == _selectedNumberId,
      orElse: () => selectableNumbers.first,
    );
    final selectedDisplayMobile = selected.mobileRaw.isNotEmpty
        ? selected.mobileRaw
        : selected.mobileNormalized;

    final payload = MobileMoneyWithdrawalSelectionPayload(
      channel: selected.channel,
      savedMobileNumberId: _selectedNumberId!,
      displayMobile: selectedDisplayMobile,
    );
    Navigator.of(context).push(
      OpeiPageRoute(
        builder: (_) =>
            MalawiMobileMoneyWithdrawalAmountScreen(payload: payload),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final availability = availabilityFromAsync(
      ref.watch(moneyMovementAvailabilityProvider),
    );
    final networks = _enabledNetworks(availability);
    final enabledCodes = networks
        .map((item) => item.code.toUpperCase())
        .toSet();
    final visibleNumbers = _numbers
        .where((item) => enabledCodes.contains(item.channel.toUpperCase()))
        .toList(growable: false);

    return Scaffold(
      backgroundColor: OpeiBrand.surface,
      appBar: AppBar(
        backgroundColor: OpeiBrand.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(l10n.mobileMoneyLabel),
        actions: [
          if (networks.isNotEmpty)
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
        child: networks.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    l10n.errServiceUnavailable,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: OpeiBrand.inkSecondary),
                  ),
                ),
              )
            : ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                children: [
                  if (!_loadingNumbers &&
                      _numbersError == null &&
                      visibleNumbers.isEmpty)
                    _WithdrawalEmptyView(onAdd: _openAddSheet)
                  else
                    _SavedNumbersSection(
                      loading: _loadingNumbers,
                      error: _numbersError,
                      numbers: visibleNumbers,
                      selectedId: _selectedNumberId,
                      settingPrimaryId: _settingPrimaryId,
                      deletingId: _deletingNumberId,
                      onRetry: _loadNumbers,
                      onSelect: (id) => setState(() => _selectedNumberId = id),
                      onSetPrimary: _setPrimary,
                      onDelete: _deleteNumber,
                      emptyText: l10n.mobileMoneyWithdrawalNoSavedNumbers,
                    ),
                ],
              ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          child: SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: networks.isEmpty ? null : _continueToAmount,
              child: Text(l10n.continueCta),
            ),
          ),
        ),
      ),
    );
  }
}

class MobileMoneyWithdrawalSelectionPayload {
  final String channel;
  final String savedMobileNumberId;
  final String displayMobile;

  const MobileMoneyWithdrawalSelectionPayload({
    required this.channel,
    required this.savedMobileNumberId,
    required this.displayMobile,
  });
}

class MalawiMobileMoneyWithdrawalAmountScreen extends ConsumerStatefulWidget {
  final MobileMoneyWithdrawalSelectionPayload payload;
  const MalawiMobileMoneyWithdrawalAmountScreen({
    super.key,
    required this.payload,
  });

  @override
  ConsumerState<MalawiMobileMoneyWithdrawalAmountScreen> createState() =>
      _MalawiMobileMoneyWithdrawalAmountScreenState();
}

class _MalawiMobileMoneyWithdrawalAmountScreenState
    extends ConsumerState<MalawiMobileMoneyWithdrawalAmountScreen> {
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

  Future<void> _openPreview() async {
    final l10n = AppLocalizations.of(context)!;
    final amountCents = _amountCents();
    if (amountCents == null || amountCents <= 0) {
      showError(context, l10n.sendMoneyValidAmountError);
      return;
    }
    setState(() => _loadingPreview = true);
    try {
      final preview = await ref
          .read(mobileMoneyDepositRepositoryProvider)
          .previewWithdrawal(
            amountUsdCents: amountCents,
            channel: widget.payload.channel,
          );
      if (!mounted) return;
      setState(() => _loadingPreview = false);
      if (!preview.canWithdraw) {
        showError(context, l10n.mobileMoneyWithdrawalCannotProceed);
        return;
      }
      Navigator.of(context).push(
        OpeiPageRoute(
          builder: (_) => MalawiMobileMoneyWithdrawalPreviewScreen(
            payload: widget.payload,
            amountUsdCents: amountCents,
            preview: preview,
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
                    widget.payload.displayMobile,
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
              onPressed: _loadingPreview ? null : _openPreview,
              child: _loadingPreview
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(l10n.mobileMoneyWithdrawalPreviewCta),
            ),
          ),
        ),
      ),
    );
  }
}

class MalawiMobileMoneyWithdrawalPreviewScreen extends ConsumerStatefulWidget {
  final MobileMoneyWithdrawalSelectionPayload payload;
  final int amountUsdCents;
  final MobileMoneyWithdrawalPreview preview;

  const MalawiMobileMoneyWithdrawalPreviewScreen({
    super.key,
    required this.payload,
    required this.amountUsdCents,
    required this.preview,
  });

  @override
  ConsumerState<MalawiMobileMoneyWithdrawalPreviewScreen> createState() =>
      _MalawiMobileMoneyWithdrawalPreviewScreenState();
}

class _MalawiMobileMoneyWithdrawalPreviewScreenState
    extends ConsumerState<MalawiMobileMoneyWithdrawalPreviewScreen> {
  bool _initiating = false;

  String _moneyUsd(int cents) =>
      Money.fromCents(cents, currency: 'USD').format();

  String _formatIntString(String value) {
    final intValue = int.tryParse(value) ?? 0;
    return NumberFormat.decimalPattern().format(intValue);
  }

  Future<void> _confirm() async {
    final preview = widget.preview;
    if (!preview.canWithdraw) return;
    setState(() => _initiating = true);
    try {
      final initiation = await ref
          .read(mobileMoneyDepositRepositoryProvider)
          .initiateWithdrawal(
            amountUsdCents: widget.amountUsdCents,
            channel: widget.payload.channel,
            savedMobileNumberId: widget.payload.savedMobileNumberId,
          );
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        OpeiPageRoute(
          builder: (_) => MobileMoneyWithdrawalProcessingScreen(
            payoutId: initiation.payoutId,
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
    final preview = widget.preview;
    return Scaffold(
      backgroundColor: OpeiBrand.surface,
      appBar: AppBar(
        backgroundColor: OpeiBrand.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(l10n.mobileMoneyWithdrawalSummaryTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          _PreviewCard(
            title: l10n.mobileMoneyWithdrawalSummaryTitle,
            rows: [
              _PreviewRowData(
                l10n.amountLabel,
                _moneyUsd(preview.amountUsdCents),
              ),
              _PreviewRowData(
                l10n.mobileMoneyWithdrawalFeeLabel,
                _moneyUsd(preview.feeUsdCents),
              ),
              _PreviewRowData(
                l10n.mobileMoneyWithdrawalTotalDebitLabel,
                _moneyUsd(preview.totalDebitUsdCents),
              ),
              _PreviewRowData(
                l10n.mobileMoneyWithdrawalPayoutLabel,
                'MWK ${_formatIntString(preview.amountMwk)}',
              ),
              if (preview.walletAvailableBalance != null)
                _PreviewRowData(
                  l10n.mobileMoneyWithdrawalAvailableBalanceLabel,
                  _moneyUsd(int.tryParse(preview.walletAvailableBalance!) ?? 0),
                ),
            ],
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
              onPressed: _initiating || !preview.canWithdraw ? null : _confirm,
              child: _initiating
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(l10n.mobileMoneyWithdrawalInitiateCta),
            ),
          ),
        ),
      ),
    );
  }
}

class MobileMoneyWithdrawalProcessingScreen extends ConsumerStatefulWidget {
  final String payoutId;
  const MobileMoneyWithdrawalProcessingScreen({
    super.key,
    required this.payoutId,
  });

  @override
  ConsumerState<MobileMoneyWithdrawalProcessingScreen> createState() =>
      _MobileMoneyWithdrawalProcessingScreenState();
}

class _MobileMoneyWithdrawalProcessingScreenState
    extends ConsumerState<MobileMoneyWithdrawalProcessingScreen> {
  static const _pollInterval = Duration(seconds: 5);
  static const _hardTimeout = Duration(minutes: 2);

  Timer? _pollTimer;
  Timer? _timeoutTimer;
  MobileMoneyWithdrawalStatus? _status;
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
          .fetchWithdrawalStatus(payoutId: widget.payoutId);
      if (!mounted) return;
      setState(() {
        _status = next;
        _statusError = null;
      });
      if (next.isTerminal) {
        _pollTimer?.cancel();
        _timeoutTimer?.cancel();
        setState(() => _polling = false);
        if (next.status == 'SUCCESS') {
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
        ? l10n.mobileMoneyWithdrawalStillProcessingTitle
        : status == null || status.status == 'PAYOUT_INITIATED'
        ? l10n.mobileMoneyWithdrawalProcessingTitle
        : status.status == 'SUCCESS'
        ? l10n.mobileMoneyWithdrawalStatusSuccess
        : status.status == 'FAILED'
        ? l10n.mobileMoneyWithdrawalStatusFailed
        : l10n.mobileMoneyWithdrawalStatusReviewRequired;
    final message = _timedOut
        ? l10n.mobileMoneyWithdrawalStillProcessingMessage
        : status == null || status.status == 'PAYOUT_INITIATED'
        ? l10n.mobileMoneyWithdrawalProcessingMessage
        : status.failureReason ??
              status.reviewReason ??
              l10n.mobileMoneyWithdrawalInitiated;
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

class _SavedNumbersSection extends StatelessWidget {
  final bool loading;
  final String? error;
  final List<SavedMobileNumber> numbers;
  final String? selectedId;
  final String settingPrimaryId;
  final String deletingId;
  final Future<void> Function() onRetry;
  final ValueChanged<String> onSelect;
  final ValueChanged<SavedMobileNumber> onSetPrimary;
  final ValueChanged<SavedMobileNumber> onDelete;
  final String emptyText;

  const _SavedNumbersSection({
    required this.loading,
    required this.error,
    required this.numbers,
    required this.selectedId,
    required this.settingPrimaryId,
    required this.deletingId,
    required this.onRetry,
    required this.onSelect,
    required this.onSetPrimary,
    required this.onDelete,
    required this.emptyText,
  });

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 18),
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }
    if (error != null) {
      return Column(
        children: [
          Text(
            error!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: OpeiBrand.inkSecondary),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: onRetry,
            child: Text(AppLocalizations.of(context)!.retryCta),
          ),
        ],
      );
    }
    if (numbers.isEmpty) {
      return Text(
        emptyText,
        style: const TextStyle(fontSize: 13, color: OpeiBrand.inkSecondary),
      );
    }
    return Column(
      children: [
        for (final number in numbers) ...[
          _SavedNumberCard(
            number: number,
            isSelected: selectedId == number.id,
            isSettingPrimary: settingPrimaryId == number.id,
            isDeleting: deletingId == number.id,
            onTap: () => onSelect(number.id),
            onSetPrimary: () => onSetPrimary(number),
            onDelete: () => onDelete(number),
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class _WithdrawalEmptyView extends StatelessWidget {
  final VoidCallback onAdd;

  const _WithdrawalEmptyView({required this.onAdd});

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

class _SavedNumberCard extends StatelessWidget {
  final SavedMobileNumber number;
  final bool isSelected;
  final bool isSettingPrimary;
  final bool isDeleting;
  final VoidCallback onTap;
  final VoidCallback onSetPrimary;
  final VoidCallback onDelete;

  const _SavedNumberCard({
    required this.number,
    required this.isSelected,
    required this.isSettingPrimary,
    required this.isDeleting,
    required this.onTap,
    required this.onSetPrimary,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final color = _channelColorForCode(number.channel);
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
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  number.channel.isNotEmpty
                      ? number.channel[0].toUpperCase()
                      : '?',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
              ),
              const SizedBox(width: 12),
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

Color _channelColorForCode(String code) {
  switch (code.toUpperCase()) {
    case 'AIRTEL':
      return const Color(0xFFE8382B);
    case 'TNM':
      return const Color(0xFF1B9E4B);
    default:
      return OpeiBrand.primary;
  }
}

class _WithdrawalNetworkOption {
  final String code;
  final String name;
  final Color color;
  final String initial;

  const _WithdrawalNetworkOption({
    required this.code,
    required this.name,
    required this.color,
    required this.initial,
  });
}

class _AddWithdrawalMobileNumberSheet extends ConsumerStatefulWidget {
  final List<_WithdrawalNetworkOption> availableNetworks;

  const _AddWithdrawalMobileNumberSheet({required this.availableNetworks});

  @override
  ConsumerState<_AddWithdrawalMobileNumberSheet> createState() =>
      _AddWithdrawalMobileNumberSheetState();
}

class _AddWithdrawalMobileNumberSheetState
    extends ConsumerState<_AddWithdrawalMobileNumberSheet> {
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _channel = 'AIRTEL';
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.availableNetworks.isNotEmpty) {
      _channel = widget.availableNetworks.first.code;
    }
  }

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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.mobileMoneyNewReceiverTitle,
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
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
                              _WithdrawalNetworkPicker(
                                label: widget.availableNetworks[i].name,
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

class _WithdrawalNetworkPicker extends StatelessWidget {
  final String label;
  final Color networkColor;
  final String initial;
  final bool isSelected;
  final VoidCallback? onTap;

  const _WithdrawalNetworkPicker({
    required this.label,
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

class _PreviewCard extends StatelessWidget {
  final String title;
  final List<_PreviewRowData> rows;

  const _PreviewCard({required this.title, required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: OpeiBrand.surfaceMuted,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: OpeiBrand.hairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: OpeiBrand.inkTertiary,
              letterSpacing: .8,
            ),
          ),
          const SizedBox(height: 10),
          for (var i = 0; i < rows.length; i++) ...[
            _PreviewRow(label: rows[i].label, value: rows[i].value),
            if (i != rows.length - 1) const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

class _PreviewRowData {
  final String label;
  final String value;

  const _PreviewRowData(this.label, this.value);
}

class _PreviewRow extends StatelessWidget {
  final String label;
  final String value;

  const _PreviewRow({required this.label, required this.value});

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
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: OpeiBrand.ink,
            ),
          ),
        ),
      ],
    );
  }
}
