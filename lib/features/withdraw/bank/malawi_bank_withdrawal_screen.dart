import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:opei/core/money/money.dart';
import 'package:opei/core/navigation/opei_page_transitions.dart';
import 'package:opei/core/providers/providers.dart';
import 'package:opei/core/utils/error_helper.dart';
import 'package:opei/data/models/bank_withdrawal.dart';
import 'package:opei/features/dashboard/dashboard_controller.dart';
import 'package:opei/l10n/app_localizations.dart';
import 'package:opei/theme.dart';

class MalawiBankWithdrawalScreen extends ConsumerStatefulWidget {
  const MalawiBankWithdrawalScreen({super.key});

  @override
  ConsumerState<MalawiBankWithdrawalScreen> createState() =>
      _MalawiBankWithdrawalScreenState();
}

class _MalawiBankWithdrawalScreenState
    extends ConsumerState<MalawiBankWithdrawalScreen> {
  final _accountNameController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _amountController = TextEditingController();

  bool _loadingBanks = true;
  String? _banksError;
  List<SupportedBank> _banks = const [];
  SupportedBank? _selectedBank;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadBanks());
  }

  @override
  void dispose() {
    _accountNameController.dispose();
    _accountNumberController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _loadBanks() async {
    setState(() {
      _loadingBanks = true;
      _banksError = null;
    });
    try {
      final banks = await ref
          .read(bankWithdrawalRepositoryProvider)
          .listSupportedBanks();
      if (!mounted) return;
      setState(() {
        _banks = banks;
        _selectedBank = banks.isEmpty ? null : banks.first;
        _loadingBanks = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _banksError = ErrorHelper.getErrorMessage(error);
        _loadingBanks = false;
      });
    }
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

  Future<void> _openPreviewScreen() async {
    final l10n = AppLocalizations.of(context)!;
    final amountCents = _amountCents();
    if (_selectedBank == null) {
      showError(context, l10n.bankWithdrawSelectBankError);
      return;
    }
    if (_accountNameController.text.trim().isEmpty) {
      showError(context, l10n.bankWithdrawAccountNameRequired);
      return;
    }
    if (_accountNumberController.text.trim().isEmpty) {
      showError(context, l10n.bankWithdrawAccountNumberRequired);
      return;
    }
    if (amountCents == null || amountCents <= 0) {
      showError(context, l10n.sendMoneyValidAmountError);
      return;
    }

    try {
      final preview = await ref
          .read(bankWithdrawalRepositoryProvider)
          .previewWithdrawal(amountUsdCents: amountCents);
      if (!mounted) return;
      if (!preview.canWithdraw) {
        showError(context, l10n.bankWithdrawCannotProceed);
        return;
      }
      final payload = BankWithdrawPayload(
        bank: _selectedBank!,
        bankAccountName: _accountNameController.text.trim(),
        bankAccountNumber: _accountNumberController.text.trim(),
        amountUsdCents: amountCents,
        preview: preview,
      );
      Navigator.of(context).push(
        OpeiPageRoute(
          builder: (_) => MalawiBankWithdrawalPreviewScreen(payload: payload),
        ),
      );
    } catch (error) {
      if (!mounted) return;
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
        title: Text(l10n.bankWithdrawMalawiTitle),
      ),
      body: _loadingBanks
          ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
          : _banksError != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _banksError!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: OpeiBrand.inkSecondary),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton(
                      onPressed: _loadBanks,
                      child: Text(l10n.retryCta),
                    ),
                  ],
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                DropdownButtonFormField<SupportedBank>(
                  initialValue: _selectedBank,
                  items: _banks
                      .map(
                        (item) => DropdownMenuItem(
                          value: item,
                          child: Text(item.name),
                        ),
                      )
                      .toList(growable: false),
                  onChanged: (value) {
                    setState(() {
                      _selectedBank = value;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: l10n.bankWithdrawBankLabel,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _accountNameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(labelText: l10n.accountNameLabel),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _accountNumberController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    labelText: l10n.accountNumberLabel,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                  ],
                  decoration: InputDecoration(
                    labelText: l10n.amountLabel,
                    hintText: l10n.sendMoneyAmountHint,
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _openPreviewScreen,
                    child: Text(l10n.bankWithdrawPreviewCta),
                  ),
                ),
              ],
            ),
    );
  }
}

class BankWithdrawPayload {
  final SupportedBank bank;
  final String bankAccountName;
  final String bankAccountNumber;
  final int amountUsdCents;
  final BankWithdrawalPreview preview;

  const BankWithdrawPayload({
    required this.bank,
    required this.bankAccountName,
    required this.bankAccountNumber,
    required this.amountUsdCents,
    required this.preview,
  });
}

class MalawiBankWithdrawalPreviewScreen extends ConsumerStatefulWidget {
  final BankWithdrawPayload payload;
  const MalawiBankWithdrawalPreviewScreen({super.key, required this.payload});

  @override
  ConsumerState<MalawiBankWithdrawalPreviewScreen> createState() =>
      _MalawiBankWithdrawalPreviewScreenState();
}

class _MalawiBankWithdrawalPreviewScreenState
    extends ConsumerState<MalawiBankWithdrawalPreviewScreen> {
  bool _initiating = false;

  String _usdText(int cents) =>
      Money.fromCents(cents, currency: 'USD').format();

  String _mwkText(String value) {
    final parsed = int.tryParse(value) ?? 0;
    return NumberFormat.decimalPattern().format(parsed);
  }

  Future<void> _confirm() async {
    final payload = widget.payload;
    setState(() => _initiating = true);
    try {
      final initiation = await ref
          .read(bankWithdrawalRepositoryProvider)
          .initiateWithdrawal(
            bankUuid: payload.bank.uuid,
            bankAccountName: payload.bankAccountName,
            bankAccountNumber: payload.bankAccountNumber,
            amountUsdCents: payload.amountUsdCents,
          );
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        OpeiPageRoute(
          builder: (_) =>
              BankWithdrawalProcessingScreen(payoutId: initiation.payoutId),
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
    final payload = widget.payload;
    final preview = payload.preview;
    return Scaffold(
      backgroundColor: OpeiBrand.surface,
      appBar: AppBar(
        backgroundColor: OpeiBrand.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(l10n.bankWithdrawSummaryTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          _SummaryCard(
            title: l10n.bankWithdrawSummaryTitle,
            rows: [
              _SummaryRowData(
                l10n.amountLabel,
                _usdText(preview.amountUsdCents),
              ),
              _SummaryRowData(
                l10n.bankWithdrawFeeLabel,
                _usdText(preview.feeUsdCents),
              ),
              _SummaryRowData(
                l10n.bankWithdrawTotalDebitLabel,
                _usdText(preview.totalDebitUsdCents),
              ),
              _SummaryRowData(
                l10n.bankWithdrawPayoutLabel,
                'MWK ${_mwkText(preview.amountMwk)}',
              ),
              _SummaryRowData(l10n.bankWithdrawBankLabel, payload.bank.name),
              _SummaryRowData(l10n.accountNameLabel, payload.bankAccountName),
              _SummaryRowData(
                l10n.accountNumberLabel,
                payload.bankAccountNumber,
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
                  : Text(l10n.bankWithdrawInitiateCta),
            ),
          ),
        ),
      ),
    );
  }
}

class BankWithdrawalProcessingScreen extends ConsumerStatefulWidget {
  final String payoutId;
  const BankWithdrawalProcessingScreen({super.key, required this.payoutId});

  @override
  ConsumerState<BankWithdrawalProcessingScreen> createState() =>
      _BankWithdrawalProcessingScreenState();
}

class _BankWithdrawalProcessingScreenState
    extends ConsumerState<BankWithdrawalProcessingScreen> {
  static const _pollInterval = Duration(seconds: 5);
  static const _hardTimeout = Duration(minutes: 2);

  Timer? _pollTimer;
  Timer? _timeoutTimer;
  BankWithdrawalStatus? _status;
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
          .read(bankWithdrawalRepositoryProvider)
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
        ? l10n.bankWithdrawStillProcessingTitle
        : status == null || status.status == 'PAYOUT_INITIATED'
        ? l10n.bankWithdrawProcessingTitle
        : status.status == 'SUCCESS'
        ? l10n.bankWithdrawSuccessTitle
        : status.status == 'FAILED'
        ? l10n.bankWithdrawFailedTitle
        : l10n.bankWithdrawReviewTitle;

    final message = _timedOut
        ? l10n.bankWithdrawStillProcessingMessage
        : status == null || status.status == 'PAYOUT_INITIATED'
        ? l10n.bankWithdrawProcessingMessage
        : status.status == 'SUCCESS'
        ? l10n.bankWithdrawSuccessMessage
        : status.status == 'FAILED'
        ? l10n.bankWithdrawFailedMessage
        : l10n.bankWithdrawReviewMessage;

    final showDone = !_polling && !_timedOut;

    return Scaffold(
      backgroundColor: OpeiBrand.surface,
      appBar: AppBar(
        backgroundColor: OpeiBrand.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(l10n.bankWithdrawMalawiTitle),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
        ),
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

class _SummaryCard extends StatelessWidget {
  final String title;
  final List<_SummaryRowData> rows;

  const _SummaryCard({required this.title, required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: OpeiBrand.surfaceMuted,
        borderRadius: BorderRadius.circular(14),
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
            _SummaryRow(label: rows[i].label, value: rows[i].value),
            if (i != rows.length - 1) const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

class _SummaryRowData {
  final String label;
  final String value;

  const _SummaryRowData(this.label, this.value);
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow({required this.label, required this.value});

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
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
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
