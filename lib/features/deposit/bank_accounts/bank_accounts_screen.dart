import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opei/core/money/money.dart';
import 'package:opei/core/providers/providers.dart';
import 'package:opei/core/utils/error_helper.dart';
import 'package:opei/data/models/bank_account_deposit.dart';
import 'package:opei/features/money_movement/availability_controller.dart';
import 'package:opei/l10n/app_localizations.dart';
import 'package:opei/theme.dart';

class BankAccountsScreen extends ConsumerWidget {
  const BankAccountsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final availability = availabilityFromAsync(
      ref.watch(moneyMovementAvailabilityProvider),
    );
    final bankAccounts = availability.deposit.bankAccounts;
    final malawiEnabled = bankAccounts.isCountryEnabled('MW');
    final usaEnabled = bankAccounts.isCountryEnabled('US');
    return Scaffold(
      backgroundColor: OpeiBrand.surface,
      appBar: AppBar(
        backgroundColor: OpeiBrand.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(l10n.bankAccountsTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          _CountryOptionTile(
            icon: Icons.account_balance_rounded,
            title: l10n.bankAccountsMalawiOptionTitle,
            subtitle: l10n.bankAccountsMalawiOptionSubtitle,
            enabled: malawiEnabled,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const MalawiBankAccountScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          _CountryOptionTile(
            icon: Icons.account_balance_rounded,
            title: l10n.bankAccountsUsaOptionTitle,
            subtitle: l10n.bankAccountsUsaOptionSubtitle,
            enabled: usaEnabled,
            onTap: () {
              showError(context, l10n.bankAccountsUsaComingSoon);
            },
          ),
        ],
      ),
    );
  }
}

class MalawiBankAccountScreen extends ConsumerStatefulWidget {
  const MalawiBankAccountScreen({super.key});

  @override
  ConsumerState<MalawiBankAccountScreen> createState() =>
      _MalawiBankAccountScreenState();
}

class _MalawiBankAccountScreenState
    extends ConsumerState<MalawiBankAccountScreen> {
  bool _loading = true;
  bool _creating = false;
  String? _error;
  BankAccountPreview? _preview;
  BankAccountDetails? _account;

  @override
  void initState() {
    super.initState();
    _loadPreview();
  }

  Future<void> _loadPreview() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final preview = await ref
          .read(bankAccountRepositoryProvider)
          .previewBankAccountCreation();
      if (!mounted) return;
      setState(() {
        _preview = preview;
        _account = preview.account;
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

  Future<void> _createAccount() async {
    final l10n = AppLocalizations.of(context)!;
    final preview = _preview;
    if (preview == null) return;
    if (!preview.canAfford) {
      showError(context, l10n.bankAccountsInsufficientBalance);
      return;
    }
    setState(() => _creating = true);
    try {
      final result = await ref
          .read(bankAccountRepositoryProvider)
          .getOrCreateBankAccount();
      if (!mounted) return;
      setState(() {
        _account = result.account;
        _creating = false;
      });
      showSuccess(
        context,
        result.created
            ? l10n.bankAccountsCreatedSuccess
            : l10n.bankAccountsExistingLoadedSuccess,
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _creating = false);
      showError(context, ErrorHelper.getErrorMessage(error));
    }
  }

  Future<void> _copyAccountNumber(String value) async {
    final l10n = AppLocalizations.of(context)!;
    await Clipboard.setData(ClipboardData(text: value));
    if (!mounted) return;
    showSuccess(context, l10n.bankAccountsCopiedAccountNumber);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final preview = _preview;
    final account = _account;

    return Scaffold(
      backgroundColor: OpeiBrand.surface,
      appBar: AppBar(
        backgroundColor: OpeiBrand.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(l10n.bankAccountsMalawiTitle),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
          : _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: OpeiBrand.inkSecondary),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: _loadPreview,
                      child: Text(l10n.retryCta),
                    ),
                  ],
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                if (account != null) ...[
                  Text(
                    l10n.bankAccountsYourAccountTitle,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: OpeiBrand.ink,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _AccountCard(
                    account: account,
                    onCopyAccountNumber: _copyAccountNumber,
                  ),
                ] else ...[
                  Text(
                    l10n.bankAccountsGetMalawiTitle,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: OpeiBrand.ink,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l10n.bankAccountsGetMalawiSubtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: OpeiBrand.inkSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
                if (preview != null) ...[
                  const SizedBox(height: 14),
                  _PreviewInfoCard(preview: preview),
                ],
              ],
            ),
      bottomNavigationBar: (account == null && preview != null)
          ? SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                child: SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _creating ? null : _createAccount,
                    child: _creating
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(l10n.bankAccountsGetMalawiCta),
                  ),
                ),
              ),
            )
          : null,
    );
  }
}

class _CountryOptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool enabled;
  final VoidCallback onTap;

  const _CountryOptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.enabled = true,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: Material(
        color: OpeiBrand.surfaceMuted,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: const BoxDecoration(
                    color: OpeiBrand.primaryTint,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: OpeiBrand.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: OpeiBrand.ink,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        enabled ? subtitle : l10n.notAvailableLabel,
                        style: const TextStyle(
                          fontSize: 13,
                          color: OpeiBrand.inkSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: OpeiBrand.inkTertiary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PreviewInfoCard extends StatelessWidget {
  final BankAccountPreview preview;

  const _PreviewInfoCard({required this.preview});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final feeText = Money.fromCents(
      preview.feeUsdCents,
      currency: 'USD',
    ).format();
    final walletText = Money.fromCents(
      preview.walletAvailableBalance,
      currency: 'USD',
    ).format();
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: OpeiBrand.surfaceMuted,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: OpeiBrand.hairline),
      ),
      child: Column(
        children: [
          _InfoRow(label: l10n.bankAccountsActivationFeeLabel, value: feeText),
          const SizedBox(height: 8),
          _InfoRow(
            label: l10n.bankAccountsWalletAvailableLabel,
            value: walletText,
          ),
          const SizedBox(height: 8),
          _InfoRow(
            label: l10n.bankAccountsEligibilityLabel,
            value: preview.canAfford
                ? l10n.bankAccountsEligibleYes
                : l10n.bankAccountsEligibleNo,
          ),
        ],
      ),
    );
  }
}

class _AccountCard extends StatelessWidget {
  final BankAccountDetails account;
  final ValueChanged<String> onCopyAccountNumber;

  const _AccountCard({
    required this.account,
    required this.onCopyAccountNumber,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: OpeiBrand.surfaceMuted,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: OpeiBrand.hairline),
      ),
      child: Column(
        children: [
          _InfoRow(label: l10n.usBankBankNameLabel, value: account.bankName),
          const SizedBox(height: 8),
          _InfoRow(label: l10n.accountNameLabel, value: account.accountName),
          const SizedBox(height: 8),
          _InfoRow(
            label: l10n.accountNumberLabel,
            value: account.accountNumber,
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: () => onCopyAccountNumber(account.accountNumber),
              icon: const Icon(Icons.copy_rounded, size: 16),
              label: Text(l10n.bankAccountsCopyAccountNumberCta),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

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
