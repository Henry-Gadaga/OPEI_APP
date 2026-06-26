import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:opei/core/config/feature_flags.dart';
import 'package:opei/core/utils/error_helper.dart';
import 'package:opei/core/navigation/opei_page_transitions.dart';
import 'package:opei/features/beneficiaries/bank_transfer_country_sheet.dart';
import 'package:opei/features/beneficiaries/mobile_money_receivers_screen.dart';
import 'package:opei/features/withdraw/withdraw_controller.dart';
import 'package:opei/features/withdraw/withdraw_state.dart';
import 'package:opei/l10n/app_localizations.dart';
import 'package:opei/responsive/responsive_tokens.dart';
import 'package:opei/responsive/responsive_widgets.dart';
import 'package:opei/theme.dart';
import 'package:opei/widgets/reference_copy_value.dart';
import 'package:opei/widgets/success_hero.dart';

class WithdrawOptionsSheet extends StatelessWidget {
  const WithdrawOptionsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: OpeiBrand.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Handle ─────────────────────────────────────
          const SizedBox(height: 14),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: OpeiBrand.hairlineStrong,
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          const SizedBox(height: 22),

          // ── Centered title ──────────────────────────────
          Text(
            l10n.dashboardActionWithdraw,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: OpeiBrand.ink,
              letterSpacing: -0.4,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            l10n.withdrawChooseMethodSubtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: OpeiBrand.inkSecondary,
              letterSpacing: -0.1,
            ),
          ),
          const SizedBox(height: 24),

          // ── Options ─────────────────────────────────────
          const _RowDivider(),
          _WithdrawRow(
            title: l10n.withdrawMobileMoneyTitle,
            subtitle: l10n.withdrawMobileMoneySubtitle,
            onTap: () {
              Navigator.of(context).pop();
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => const _MobileMoneyCountrySheet(),
              );
            },
          ),
          const _RowDivider(),
          _WithdrawRow(
            title: l10n.withdrawBankTransferTitle,
            subtitle: l10n.withdrawBankTransferSubtitle,
            onTap: () {
              Navigator.of(context).pop();
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => const BankTransferCountrySheet(),
              );
            },
          ),
          const _RowDivider(),
          if (FeatureFlags.enableClassicP2P) ...[
            _WithdrawRow(
              title: l10n.withdrawP2PExchangeTitle,
              subtitle: l10n.withdrawP2PExchangeSubtitle,
              onTap: () {
                context.pop();
                context.push(
                  '/p2p?intent=sell',
                  extra: const {'disableTransition': true},
                );
              },
            ),
            const _RowDivider(),
          ],
          _WithdrawRow(
            title: l10n.depositStablecoinTitle,
            subtitle: l10n.withdrawStablecoinSubtitle,
            onTap: () {
              context.pop();
              context.push('/withdraw/crypto-currency');
            },
          ),
          const _RowDivider(),

          SizedBox(height: 16 + bottomPadding),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MOBILE MONEY — COUNTRY SELECTION SHEET
// ─────────────────────────────────────────────────────────────────────────────

class _MobileMoneyCountrySheet extends StatelessWidget {
  const _MobileMoneyCountrySheet();

  static const _countries = [
    ('🇬🇭', 'Ghana', 'GH'),
    ('🇰🇪', 'Kenya', 'KE'),
    ('🇺🇬', 'Uganda', 'UG'),
    ('🇷🇼', 'Rwanda', 'RW'),
    ('🇸🇳', 'Senegal', 'SN'),
    ('🇨🇮', "Côte d'Ivoire", 'CI'),
    ('🇨🇲', 'Cameroon', 'CM'),
    ('🇨🇩', 'DR Congo', 'CD'),
    ('🇬🇦', 'Gabon', 'GA'),
    ('🇬🇲', 'Gambia', 'GM'),
    ('🇿🇲', 'Zambia', 'ZM'),
  ];

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;
    final maxHeight = MediaQuery.of(context).size.height * 0.82;

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: const BoxDecoration(
        color: OpeiBrand.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Handle ─────────────────────────────────────
          const SizedBox(height: 14),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: OpeiBrand.hairlineStrong,
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          const SizedBox(height: 22),

          // ── Header ─────────────────────────────────────
          const Text(
            'Select country',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: OpeiBrand.ink,
              letterSpacing: -0.4,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Mobile Money supported countries',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: OpeiBrand.inkSecondary,
              letterSpacing: -0.1,
            ),
          ),
          const SizedBox(height: 22),

          // ── Country list ────────────────────────────────
          const Divider(height: 1, thickness: 0.5, color: OpeiBrand.hairline),
          Flexible(
            child: ListView.separated(
              padding: EdgeInsets.zero,
              physics: const ClampingScrollPhysics(),
              itemCount: _countries.length,
              separatorBuilder: (context, i) => const Divider(
                height: 1,
                thickness: 0.5,
                color: OpeiBrand.hairline,
              ),
              itemBuilder: (context, i) {
                final (flag, name, code) = _countries[i];
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      final navigator = Navigator.of(context);
                      navigator.pop();
                      navigator.push(
                        OpeiPageRoute(
                          builder: (_) => MobileMoneyReceiversScreen(
                            country: code,
                            countryName: name,
                            flag: flag,
                          ),
                        ),
                      );
                    },
                    splashColor: OpeiBrand.primary.withValues(alpha: 0.04),
                    highlightColor: OpeiBrand.surfaceMuted,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      child: Row(
                        children: [
                          Text(flag, style: const TextStyle(fontSize: 22)),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: OpeiBrand.ink,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ),
                          Text(
                            code,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: OpeiBrand.inkTertiary,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1, thickness: 0.5, color: OpeiBrand.hairline),

          SizedBox(height: 16 + bottomPadding),
        ],
      ),
    );
  }
}

class _WithdrawRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _WithdrawRow({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: OpeiBrand.primary.withValues(alpha: 0.04),
        highlightColor: OpeiBrand.surfaceMuted,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: OpeiBrand.ink,
                        letterSpacing: -0.25,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: OpeiBrand.inkSecondary,
                        letterSpacing: -0.1,
                        height: 1.3,
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
    );
  }
}

class _RowDivider extends StatelessWidget {
  const _RowDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, thickness: 0.5, color: OpeiBrand.hairline);
  }
}

class WithdrawOptionCard extends StatefulWidget {
  final IconData? icon;
  final String? iconAsset;
  final String title;
  final String description;
  final VoidCallback onTap;

  const WithdrawOptionCard({
    super.key,
    this.icon,
    this.iconAsset,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  State<WithdrawOptionCard> createState() => _WithdrawOptionCardState();
}

class _WithdrawOptionCardState extends State<WithdrawOptionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.97,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: OpeiColors.iosSeparator, width: 0.6),
              bottom: BorderSide(color: OpeiColors.iosSeparator, width: 0.6),
            ),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 28,
                height: 28,
                child: widget.iconAsset != null
                    ? SvgPicture.asset(widget.iconAsset!, fit: BoxFit.contain)
                    : (widget.icon != null
                          ? Icon(
                              widget.icon,
                              color: OpeiColors.pureBlack,
                              size: 24,
                            )
                          : const SizedBox()),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 13.5,
                        color: OpeiColors.iosLabelSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: OpeiColors.iosLabelTertiary,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WithdrawCurrencySelectionScreen extends ConsumerWidget {
  const WithdrawCurrencySelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spacing = context.responsiveSpacingUnit;
    final tokens = context.responsiveTokens;

    return ResponsiveScaffold(
      useSafeArea: false,
      padding: EdgeInsets.zero,
      appBar: AppBar(
        backgroundColor: OpeiColors.pureWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: OpeiColors.pureBlack,
            size: 20,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Select Method',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(tokens.horizontalPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose the method you want to withdraw with',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 15,
                color: OpeiColors.iosLabelSecondary,
              ),
            ),
            SizedBox(height: spacing * 2.5),
            _CurrencyOption(
              currency: 'USDT',
              name: 'Tether',
              networksLabel: 'Tron • Polygon • Ethereum • BSC',
              onTap: () {
                ref
                    .read(withdrawControllerProvider.notifier)
                    .setCurrency('USDT');
                context.push('/withdraw/crypto-network', extra: 'USDT');
              },
            ),
            SizedBox(height: spacing * 0.5),
            _CurrencyOption(
              currency: 'USDC',
              name: 'USD Coin',
              networksLabel: 'Polygon • Ethereum • BSC',
              onTap: () {
                ref
                    .read(withdrawControllerProvider.notifier)
                    .setCurrency('USDC');
                context.push('/withdraw/crypto-network', extra: 'USDC');
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _CurrencyOption extends StatefulWidget {
  final String currency;
  final String name;
  final String networksLabel;
  final VoidCallback onTap;

  const _CurrencyOption({
    required this.currency,
    required this.name,
    required this.networksLabel,
    required this.onTap,
  });

  @override
  State<_CurrencyOption> createState() => _CurrencyOptionState();
}

class _CurrencyOptionState extends State<_CurrencyOption>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  String? get _iconAsset {
    switch (widget.currency.toUpperCase()) {
      case 'USDT':
        return 'assets/images/usdt-svgrepo-com.svg';
      case 'USDC':
        return 'assets/images/usdc1.svg';
      default:
        return null;
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.97,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: OpeiColors.iosSeparator, width: 0.6),
            ),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 32,
                height: 32,
                child: _iconAsset != null
                    ? SvgPicture.asset(_iconAsset!, fit: BoxFit.contain)
                    : Center(
                        child: Text(
                          widget.currency,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.currency,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.networksLabel,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 12.5,
                        color: OpeiColors.iosLabelSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: OpeiColors.iosLabelTertiary,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WithdrawNetworkSelectionScreen extends ConsumerWidget {
  final String currency;

  const WithdrawNetworkSelectionScreen({super.key, required this.currency});

  List<String> get _networks {
    switch (currency.toUpperCase()) {
      case 'USDC':
        return const ['polygon', 'ethereum', 'bsc'];
      default:
        return const ['tron', 'polygon', 'ethereum', 'bsc'];
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(withdrawControllerProvider.notifier);
    final spacing = context.responsiveSpacingUnit;
    final tokens = context.responsiveTokens;

    return ResponsiveScaffold(
      useSafeArea: false,
      padding: EdgeInsets.zero,
      appBar: AppBar(
        backgroundColor: OpeiColors.pureWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: OpeiColors.pureBlack,
            size: 20,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Select Network',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(tokens.horizontalPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose the network for your $currency withdrawal',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 15,
                color: OpeiColors.iosLabelSecondary,
              ),
            ),
            SizedBox(height: spacing * 2.5),
            ..._networks.map(
              (network) => Padding(
                padding: EdgeInsets.only(bottom: spacing * 0.75),
                child: _NetworkOption(
                  network: network,
                  onTap: () {
                    notifier.setNetwork(network);
                    context.push(
                      '/withdraw/crypto-form',
                      extra: {'currency': currency, 'network': network},
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NetworkOption extends StatefulWidget {
  final String network;
  final VoidCallback onTap;

  const _NetworkOption({required this.network, required this.onTap});

  @override
  State<_NetworkOption> createState() => _NetworkOptionState();
}

class _NetworkOptionState extends State<_NetworkOption>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  String? get _iconAsset {
    switch (widget.network.toLowerCase()) {
      case 'ethereum':
        return 'assets/images/eth.svg';
      case 'bsc':
        return 'assets/images/binance.svg';
      case 'tron':
        return 'assets/images/tron.svg';
      case 'polygon':
        return 'assets/images/polygon.svg';
      default:
        return null;
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.97,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String get _displayName {
    switch (widget.network) {
      case 'tron':
        return 'Tron (TRC-20)';
      case 'polygon':
        return 'Polygon (MATIC)';
      case 'ethereum':
        return 'Ethereum (ERC-20)';
      case 'bsc':
        return 'BNB Smart Chain (BEP-20)';
      default:
        return widget.network;
    }
  }

  String get _networkHint {
    switch (widget.network) {
      case 'tron':
        return 'Very low fees • Fast confirmations';
      case 'polygon':
        return 'Low fees • Fast confirmations';
      case 'bsc':
        return 'Low fees • Broad support';
      case 'ethereum':
        return 'High fees • Most compatible';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: OpeiColors.iosSeparator, width: 0.6),
            ),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 32,
                height: 32,
                child: _iconAsset != null
                    ? SvgPicture.asset(_iconAsset!, fit: BoxFit.contain)
                    : Center(
                        child: Text(
                          widget.network.toUpperCase()[0],
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _displayName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _networkHint,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 12,
                        color: OpeiColors.iosLabelSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: OpeiColors.iosLabelTertiary,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CryptoWithdrawFormScreen extends ConsumerStatefulWidget {
  final String currency;
  final String network;

  const CryptoWithdrawFormScreen({
    super.key,
    required this.currency,
    required this.network,
  });

  @override
  ConsumerState<CryptoWithdrawFormScreen> createState() =>
      _CryptoWithdrawFormScreenState();
}

class _CryptoWithdrawFormScreenState
    extends ConsumerState<CryptoWithdrawFormScreen> {
  late final TextEditingController _amountController;
  late final TextEditingController _addressController;
  late final TextEditingController _memoController;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
    _addressController = TextEditingController();
    _memoController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(withdrawControllerProvider.notifier)
          .setCurrency(widget.currency);
      ref.read(withdrawControllerProvider.notifier).setNetwork(widget.network);
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _addressController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  String get _networkLabel {
    switch (widget.network.toLowerCase()) {
      case 'tron':
        return 'Tron';
      case 'polygon':
        return 'Polygon';
      case 'ethereum':
        return 'Ethereum';
      case 'bsc':
        return 'BSC';
      default:
        return widget.network;
    }
  }

  bool get _requiresConfirmation {
    final currency = widget.currency.toUpperCase();
    return currency == 'USDC' || currency == 'USDT';
  }

  Future<void> _handlePrimaryAction() async {
    final l10n = AppLocalizations.of(context)!;
    final amountText = _amountController.text.trim();
    final addressText = _addressController.text.trim();

    // Validate required fields
    if (amountText.isEmpty) {
      showError(context, l10n.withdrawEnterAmountError);
      return;
    }

    if (addressText.isEmpty) {
      showError(context, l10n.withdrawEnterDestinationError);
      return;
    }

    // Validate amount is a valid number
    final amountValue = double.tryParse(amountText.replaceAll(',', ''));
    if (amountValue == null || amountValue <= 0) {
      showError(context, l10n.withdrawEnterValidAmountError);
      return;
    }

    final addressValidationError = _validateAddressForNetwork(addressText);
    if (addressValidationError != null) {
      showError(context, addressValidationError);
      return;
    }

    if (_requiresConfirmation) {
      final confirmed = await _showConfirmationSheet();
      if (confirmed != true) {
        return;
      }
    }
    await _handleSubmit();
  }

  Future<void> _handleSubmit() async {
    final amountText = _amountController.text.trim();
    final addressText = _addressController.text.trim();
    final memoText = _memoController.text.trim();

    final notifier = ref.read(withdrawControllerProvider.notifier);
    final success = await notifier.submitCryptoWithdrawal(
      currency: widget.currency,
      network: widget.network,
      amount: amountText,
      address: addressText,
      description: memoText.isEmpty ? null : memoText,
    );

    if (!mounted) return;

    if (success) {
      context.push(
        '/withdraw/crypto-success',
        extra: {'currency': widget.currency, 'network': widget.network},
      );
    }
  }

  Future<bool?> _showConfirmationSheet() {
    final amountText = _amountController.text.trim();
    final addressText = _addressController.text.trim();
    final currencyCode = widget.currency.toUpperCase();
    final amountDisplay = amountText.isEmpty
        ? '—'
        : '$amountText $currencyCode';
    final addressDisplay = addressText.isEmpty
        ? 'Not provided'
        : _shortenAddress(addressText);
    const feeDisplay = '\$1.50';

    return showResponsiveBottomSheet<bool>(
      context: context,
      enableDrag: true,
      builder: (sheetContext) => _WithdrawConfirmationSheet(
        currency: currencyCode,
        networkLabel: _networkLabel,
        amountDisplay: amountDisplay,
        addressDisplay: addressDisplay,
        feeDisplay: feeDisplay,
        onConfirm: () => Navigator.of(sheetContext).pop(true),
        onCancel: () => Navigator.of(sheetContext).pop(false),
      ),
    );
  }

  String _shortenAddress(String value) {
    const visible = 6;
    final trimmed = value.trim();
    if (trimmed.length <= visible * 2 + 1) {
      return trimmed;
    }
    return '${trimmed.substring(0, visible)}…${trimmed.substring(trimmed.length - visible)}';
  }

  String? _validateAddressForNetwork(String rawAddress) {
    final trimmed = rawAddress.trim();
    final currency = widget.currency.toUpperCase();
    final network = widget.network.toLowerCase();

    final isStablecoin = currency == 'USDT' || currency == 'USDC';
    if (!isStablecoin) {
      return null;
    }

    if (network == 'tron') {
      if (trimmed.length != 34) {
        return 'TRC-20 addresses must be exactly 34 characters long.';
      }
      if (!trimmed.startsWith('T')) {
        return 'TRC-20 addresses must start with the letter T.';
      }
      final base58Regex = RegExp(r'^[1-9A-HJ-NP-Za-km-z]+$');
      if (!base58Regex.hasMatch(trimmed)) {
        return 'TRC-20 addresses use Base58 characters only.';
      }
      return null;
    }

    if (network == 'polygon' || network == 'ethereum' || network == 'bsc') {
      if (!trimmed.startsWith('0x')) {
        return 'This network requires addresses that start with 0x.';
      }
      if (trimmed.length != 42) {
        return 'This address must be exactly 42 characters long.';
      }
      final hexPart = trimmed.substring(2);
      final hexRegex = RegExp(r'^[0-9a-fA-F]+$');
      if (!hexRegex.hasMatch(hexPart)) {
        return 'Use hexadecimal characters only (0-9, a-f).';
      }
      return null;
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    ref.listen<WithdrawState>(withdrawControllerProvider, (previous, next) {
      final error = next.error;
      if (error != null && error != previous?.error && mounted) {
        showError(context, error);
      }
    });

    final state = ref.watch(withdrawControllerProvider);
    final textTheme = Theme.of(context).textTheme;
    final spacing = context.responsiveSpacingUnit;
    final tokens = context.responsiveTokens;

    return ResponsiveScaffold(
      useSafeArea: false,
      padding: EdgeInsets.zero,
      backgroundColor: OpeiColors.pureWhite,
      appBar: AppBar(
        backgroundColor: OpeiColors.pureWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: OpeiColors.pureBlack,
            size: 20,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Withdraw ${widget.currency}',
          style: textTheme.titleLarge?.copyWith(
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(
          horizontal: tokens.horizontalPadding,
          vertical: spacing * 2.5,
        ),
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        children: [
          Text(
            l10n.withdrawDetailsSubtitle(widget.currency, _networkLabel),
            style: textTheme.bodyMedium?.copyWith(
              fontSize: 15,
              color: OpeiColors.iosLabelSecondary,
            ),
          ),
          SizedBox(height: spacing * 2.5),
          _SummaryPill(currency: widget.currency, networkLabel: _networkLabel),
          SizedBox(height: spacing * 3),
          _LabeledField(
            label: l10n.amountLabel,
            helper: l10n.withdrawAmountHelper,
            child: CupertinoTextField(
              controller: _amountController,
              placeholder: l10n.withdrawAmountPlaceholder,
              padding: EdgeInsets.symmetric(
                horizontal: spacing * 1.75,
                vertical: spacing * 1.25,
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
              ],
              decoration: BoxDecoration(
                color: OpeiColors.pureWhite,
                borderRadius: BorderRadius.circular(tokens.inputRadius),
                border: Border.all(
                  color: OpeiColors.iosSeparator.withValues(alpha: 0.8),
                ),
              ),
              style: textTheme.titleMedium?.copyWith(
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(height: spacing * 1.75),
          _LabeledField(
            label: l10n.withdrawDestinationAddressLabel,
            helper: l10n.withdrawDestinationAddressHelper,
            child: CupertinoTextField(
              controller: _addressController,
              placeholder: l10n.withdrawDestinationAddressPlaceholder,
              padding: EdgeInsets.symmetric(
                horizontal: spacing * 1.75,
                vertical: spacing * 1.25,
              ),
              textInputAction: TextInputAction.next,
              decoration: BoxDecoration(
                color: OpeiColors.pureWhite,
                borderRadius: BorderRadius.circular(tokens.inputRadius),
                border: Border.all(
                  color: OpeiColors.iosSeparator.withValues(alpha: 0.8),
                ),
              ),
              style: textTheme.bodyMedium?.copyWith(fontSize: 15, height: 1.4),
            ),
          ),
          SizedBox(height: spacing * 1.75),
          _LabeledField(
            label: l10n.withdrawMemoOptionalLabel,
            helper: l10n.withdrawMemoHelper,
            child: CupertinoTextField(
              controller: _memoController,
              placeholder: l10n.withdrawMemoPlaceholder,
              padding: EdgeInsets.symmetric(
                horizontal: spacing * 1.75,
                vertical: spacing * 1.25,
              ),
              decoration: BoxDecoration(
                color: OpeiColors.pureWhite,
                borderRadius: BorderRadius.circular(tokens.inputRadius),
                border: Border.all(
                  color: OpeiColors.iosSeparator.withValues(alpha: 0.8),
                ),
              ),
              style: textTheme.bodyMedium?.copyWith(fontSize: 15),
            ),
          ),
          SizedBox(height: spacing * 3),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: spacing * 0.5,
              vertical: spacing * 2,
            ),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: OpeiColors.iosSeparator, width: 0.6),
                bottom: BorderSide(color: OpeiColors.iosSeparator, width: 0.6),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InfoRow(text: l10n.withdrawInfoDoubleCheck),
                const SizedBox(height: 10),
                _InfoRow(text: l10n.withdrawInfoStatusUpdates),
              ],
            ),
          ),
          SizedBox(height: spacing * 3.25),
          CupertinoButton.filled(
            borderRadius: BorderRadius.circular(tokens.buttonRadius),
            padding: EdgeInsets.symmetric(vertical: spacing * 1.75),
            onPressed: state.isLoading ? null : _handlePrimaryAction,
            child: state.isLoading
                ? const CupertinoActivityIndicator(color: OpeiColors.pureWhite)
                : Text(
                    l10n.dashboardActionWithdraw,
                    style: textTheme.titleMedium?.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: OpeiColors.pureWhite,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _SummaryPill extends StatelessWidget {
  final String currency;
  final String networkLabel;

  const _SummaryPill({required this.currency, required this.networkLabel});

  String? get _iconAsset {
    switch (currency.toUpperCase()) {
      case 'USDT':
        return 'assets/images/usdt-svgrepo-com.svg';
      case 'USDC':
        return 'assets/images/usdc1.svg';
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: _iconAsset != null
                ? SvgPicture.asset(_iconAsset!, fit: BoxFit.contain)
                : Center(
                    child: Text(
                      currency,
                      style: textTheme.titleMedium?.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$currency withdrawal',
                  style: textTheme.titleMedium?.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  networkLabel,
                  style: textTheme.bodyMedium?.copyWith(
                    fontSize: 13,
                    color: OpeiColors.iosLabelSecondary,
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

class _LabeledField extends StatelessWidget {
  final String label;
  final String helper;
  final Widget child;

  const _LabeledField({
    required this.label,
    required this.helper,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: textTheme.bodyMedium?.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.1,
          ),
        ),
        const SizedBox(height: 6),
        child,
        const SizedBox(height: 4),
        Text(
          helper,
          style: textTheme.bodySmall?.copyWith(
            fontSize: 12.5,
            color: OpeiColors.iosLabelTertiary,
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String text;

  const _InfoRow({required this.text});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 6),
          width: 4,
          height: 4,
          decoration: const BoxDecoration(
            color: OpeiColors.iosLabelSecondary,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: textTheme.bodyMedium?.copyWith(
              fontSize: 14,
              color: OpeiColors.iosLabelSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

class _WithdrawConfirmationSheet extends StatelessWidget {
  final String currency;
  final String networkLabel;
  final String amountDisplay;
  final String addressDisplay;
  final String feeDisplay;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const _WithdrawConfirmationSheet({
    required this.currency,
    required this.networkLabel,
    required this.amountDisplay,
    required this.addressDisplay,
    required this.feeDisplay,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = context.responsiveSpacingUnit;
    final tokens = context.responsiveTokens;
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewPadding.bottom + spacing * 2,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: OpeiColors.iosLabelTertiary,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          SizedBox(height: spacing * 2),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: tokens.horizontalPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.withdrawReviewTitle,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.withdrawReviewSubtitle(currency),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: OpeiColors.iosLabelSecondary,
                    height: 1.35,
                  ),
                ),
                SizedBox(height: spacing * 2.5),
                _ReviewRow(label: l10n.amountLabel, value: amountDisplay),
                SizedBox(height: spacing * 1.5),
                const Divider(color: OpeiColors.iosSeparator),
                SizedBox(height: spacing * 1.5),
                _ReviewRow(label: l10n.withdrawAssetLabel, value: currency),
                SizedBox(height: spacing * 1.5),
                const Divider(color: OpeiColors.iosSeparator),
                SizedBox(height: spacing * 1.5),
                _ReviewRow(
                  label: l10n.withdrawNetworkLabel,
                  value: networkLabel,
                ),
                SizedBox(height: spacing * 1.5),
                const Divider(color: OpeiColors.iosSeparator),
                SizedBox(height: spacing * 1.5),
                _ReviewRow(
                  label: l10n.withdrawDestinationLabel,
                  value: addressDisplay,
                ),
                SizedBox(height: spacing * 1.5),
                const Divider(color: OpeiColors.iosSeparator),
                SizedBox(height: spacing * 1.5),
                _ReviewRow(label: l10n.feeRow, value: feeDisplay),
                SizedBox(height: spacing * 2.5),
                SizedBox(
                  width: double.infinity,
                  child: CupertinoButton.filled(
                    borderRadius: BorderRadius.circular(tokens.buttonRadius),
                    padding: EdgeInsets.symmetric(vertical: spacing * 1.75),
                    onPressed: onConfirm,
                    child: Text(
                      l10n.withdrawConfirmCta,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: OpeiColors.pureWhite,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: spacing * 1.5),
                SizedBox(
                  width: double.infinity,
                  child: CupertinoButton(
                    padding: EdgeInsets.symmetric(vertical: spacing * 1.5),
                    onPressed: onCancel,
                    child: Center(
                      child: Text(
                        l10n.cancelCta,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: OpeiColors.iosLabelSecondary,
                        ),
                      ),
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

class _ReviewRow extends StatelessWidget {
  final String label;
  final String value;

  const _ReviewRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: textTheme.labelMedium?.copyWith(
            fontSize: 12.5,
            color: OpeiColors.iosLabelSecondary,
            letterSpacing: 0.25,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: textTheme.bodyMedium?.copyWith(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.1,
          ),
        ),
      ],
    );
  }
}

class CryptoWithdrawSuccessScreen extends ConsumerWidget {
  final String currency;
  final String network;

  const CryptoWithdrawSuccessScreen({
    super.key,
    required this.currency,
    required this.network,
  });

  String _resolveNetworkLabel(String value) {
    switch (value.toLowerCase()) {
      case 'tron':
        return 'Tron';
      case 'polygon':
        return 'Polygon';
      case 'ethereum':
        return 'Ethereum';
      case 'bsc':
        return 'BSC';
      default:
        return value;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(withdrawControllerProvider);
    final response = state.transferResponse;
    final textTheme = Theme.of(context).textTheme;
    final spacing = context.responsiveSpacingUnit;
    final tokens = context.responsiveTokens;

    if (response == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) {
          return;
        }
        final navigator = Navigator.of(context);
        if (navigator.canPop()) {
          navigator.pop();
        } else {
          context.go('/dashboard');
        }
      });
      return const SizedBox.shrink();
    }

    final networkLabel = _resolveNetworkLabel(network);
    final statusLabel =
        response.status[0].toUpperCase() + response.status.substring(1);
    final amountDisplay = response.amount;

    return ResponsiveScaffold(
      useSafeArea: false,
      padding: EdgeInsets.zero,
      backgroundColor: OpeiColors.pureWhite,
      appBar: AppBar(
        backgroundColor: OpeiColors.pureWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: OpeiColors.pureBlack, size: 20),
          onPressed: () {
            ref.read(withdrawControllerProvider.notifier).resetSubmission();
            context.go('/dashboard');
          },
        ),
        title: Text(
          l10n.withdrawSubmittedTitle,
          style: textTheme.titleLarge?.copyWith(
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(
          horizontal: tokens.horizontalPadding,
          vertical: spacing * 3,
        ),
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        children: [
          SizedBox(height: spacing * 1.5),
          const SuccessHero(iconHeight: 72, gap: 2),
          SizedBox(height: spacing * 2),
          Text(
            l10n.withdrawSentTitle,
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: spacing * 1.75),
          Text(
            l10n.withdrawSentSubtitle(
              response.asset.toUpperCase(),
              networkLabel,
            ),
            style: textTheme.bodyMedium?.copyWith(
              fontSize: 14,
              color: OpeiColors.iosLabelSecondary,
              height: 1.45,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: spacing * 3.25),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: spacing * 2.5,
              vertical: spacing * 2.25,
            ),
            decoration: BoxDecoration(
              color: OpeiColors.grey100,
              borderRadius: BorderRadius.circular(tokens.dialogRadius),
            ),
            child: Column(
              children: [
                _DetailRow(label: l10n.statusLabel, value: statusLabel),
                SizedBox(height: spacing * 1.25),
                _DetailRow(
                  label: l10n.referenceLabel,
                  value: response.reference,
                ),
                SizedBox(height: spacing * 1.25),
                _DetailRow(
                  label: l10n.withdrawRequestedLabel,
                  value:
                      '${amountDisplay.format(includeCurrencySymbol: false)} ${currency.toUpperCase()}',
                ),
                SizedBox(height: spacing * 1.25),
                _DetailRow(
                  label: l10n.withdrawNetworkLabel,
                  value: networkLabel,
                ),
              ],
            ),
          ),
          SizedBox(height: spacing * 3.25),
          CupertinoButton.filled(
            borderRadius: BorderRadius.circular(tokens.buttonRadius),
            padding: EdgeInsets.symmetric(vertical: spacing * 1.6),
            onPressed: () {
              ref.read(withdrawControllerProvider.notifier).resetSubmission();
              context.go('/dashboard');
            },
            child: Text(
              l10n.doneCta,
              style: textTheme.titleMedium?.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: OpeiColors.pureWhite,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    if (label.toLowerCase() == 'reference') {
      return ReferenceCopyValue(
        label: label,
        reference: value,
        labelStyle: textTheme.bodyMedium?.copyWith(
          fontSize: 14,
          color: OpeiColors.iosLabelSecondary,
        ),
        valueStyle: textTheme.bodyMedium?.copyWith(
          fontSize: 14.5,
          fontWeight: FontWeight.w600,
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: Text(
            label,
            style: textTheme.bodyMedium?.copyWith(
              fontSize: 14,
              color: OpeiColors.iosLabelSecondary,
            ),
          ),
        ),
        Expanded(
          flex: 5,
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: textTheme.bodyMedium?.copyWith(
              fontSize: 14.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
