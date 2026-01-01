import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:tt1/core/utils/error_helper.dart';
import 'package:tt1/features/withdraw/withdraw_controller.dart';
import 'package:tt1/features/withdraw/withdraw_state.dart';
import 'package:tt1/responsive/responsive_tokens.dart';
import 'package:tt1/responsive/responsive_widgets.dart';
import 'package:tt1/theme.dart';
import 'package:tt1/widgets/reference_copy_value.dart';
import 'package:tt1/widgets/success_hero.dart';

class WithdrawOptionsSheet extends StatelessWidget {
  const WithdrawOptionsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;
    final effectiveBottomSpacing = bottomPadding > 0 ? bottomPadding : 16.0;

    return Container(
      decoration: const BoxDecoration(
        color: OpeiColors.pureWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        bottom: false,
        child: Padding(
          padding: EdgeInsets.only(bottom: effectiveBottomSpacing),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: OpeiColors.iosLabelTertiary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Withdraw',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Choose how you want to move funds out of your wallet',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 15,
                          color: OpeiColors.iosLabelSecondary,
                        ),
                  ),
                  const SizedBox(height: 28),
                  WithdrawOptionCard(
                    iconAsset: 'assets/images/exchange.svg',
                    title: 'P2P Exchange',
                    description: 'Bank transfer, Mobile Payments and more',
                    onTap: () {
                      context.pop();
                      context.push('/p2p?intent=sell');
                    },
                  ),
                  const SizedBox(height: 4),
                  WithdrawOptionCard(
                    iconAsset: 'assets/icons/usdicon.svg',
                    title: 'USD Withdrawal',
                    description: 'Move USD stablecoins back to your own wallet',
                    onTap: () {
                      context.pop();
                      context.push('/withdraw/crypto-currency');
                    },
                  ),
                ],
              ),
            ),
          ],
          ),
        ),
      ),
    );
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

class _WithdrawOptionCardState extends State<WithdrawOptionCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
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
                    ? SvgPicture.asset(
                        widget.iconAsset!,
                        fit: BoxFit.contain,
                      )
                    : (widget.icon != null
                        ? Icon(widget.icon, color: OpeiColors.pureBlack, size: 24)
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
              const Icon(Icons.arrow_forward_ios, color: OpeiColors.iosLabelTertiary, size: 16),
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
          icon: const Icon(Icons.arrow_back_ios, color: OpeiColors.pureBlack, size: 20),
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
                ref.read(withdrawControllerProvider.notifier).setCurrency('USDT');
                context.push('/withdraw/crypto-network', extra: 'USDT');
              },
            ),
            SizedBox(height: spacing * 0.5),
            _CurrencyOption(
              currency: 'USDC',
              name: 'USD Coin',
              networksLabel: 'Polygon • Ethereum • BSC',
              onTap: () {
                ref.read(withdrawControllerProvider.notifier).setCurrency('USDC');
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

class _CurrencyOptionState extends State<_CurrencyOption> with SingleTickerProviderStateMixin {
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
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
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
                    ? SvgPicture.asset(
                        _iconAsset!,
                        fit: BoxFit.contain,
                      )
                    : Center(
                        child: Text(
                          widget.currency,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
              const Icon(Icons.arrow_forward_ios, color: OpeiColors.iosLabelTertiary, size: 16),
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
          icon: const Icon(Icons.arrow_back_ios, color: OpeiColors.pureBlack, size: 20),
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
                    context.push('/withdraw/crypto-form', extra: {
                      'currency': currency,
                      'network': network,
                    });
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

class _NetworkOptionState extends State<_NetworkOption> with SingleTickerProviderStateMixin {
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
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
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
                    ? SvgPicture.asset(
                        _iconAsset!,
                        fit: BoxFit.contain,
                      )
                    : Center(
                        child: Text(
                          widget.network.toUpperCase()[0],
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
              const Icon(Icons.arrow_forward_ios, color: OpeiColors.iosLabelTertiary, size: 16),
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

  const CryptoWithdrawFormScreen({super.key, required this.currency, required this.network});

  @override
  ConsumerState<CryptoWithdrawFormScreen> createState() => _CryptoWithdrawFormScreenState();
}

class _CryptoWithdrawFormScreenState extends ConsumerState<CryptoWithdrawFormScreen> {
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
      ref.read(withdrawControllerProvider.notifier).setCurrency(widget.currency);
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
      context.push('/withdraw/crypto-success', extra: {
        'currency': widget.currency,
        'network': widget.network,
      });
    }
  }

  Future<bool?> _showConfirmationSheet() {
    final amountText = _amountController.text.trim();
    final addressText = _addressController.text.trim();
    final currencyCode = widget.currency.toUpperCase();
    final amountDisplay = amountText.isEmpty ? '—' : '$amountText $currencyCode';
    final addressDisplay = addressText.isEmpty ? 'Not provided' : _shortenAddress(addressText);

    return showResponsiveBottomSheet<bool>(
      context: context,
      enableDrag: true,
      builder: (sheetContext) => _WithdrawConfirmationSheet(
        currency: currencyCode,
        networkLabel: _networkLabel,
        amountDisplay: amountDisplay,
        addressDisplay: addressDisplay,
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

  @override
  Widget build(BuildContext context) {
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
          icon: const Icon(Icons.arrow_back_ios, color: OpeiColors.pureBlack, size: 20),
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
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        children: [
          Text(
            'Enter the details for your ${widget.currency} withdrawal on $_networkLabel.',
            style: textTheme.bodyMedium?.copyWith(
                  fontSize: 15,
                  color: OpeiColors.iosLabelSecondary,
                ),
          ),
          SizedBox(height: spacing * 2.5),
          _SummaryPill(
            currency: widget.currency,
            networkLabel: _networkLabel,
          ),
          SizedBox(height: spacing * 3),
          _LabeledField(
            label: 'Amount',
            helper: 'Enter the amount you want to send',
            child: CupertinoTextField(
              controller: _amountController,
              placeholder: '0.00',
              padding: EdgeInsets.symmetric(horizontal: spacing * 1.75, vertical: spacing * 1.25),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
              decoration: BoxDecoration(
                color: OpeiColors.pureWhite,
                borderRadius: BorderRadius.circular(tokens.inputRadius),
                border: Border.all(color: OpeiColors.iosSeparator.withValues(alpha: 0.8)),
              ),
              style: textTheme.titleMedium?.copyWith(
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(height: spacing * 1.75),
          _LabeledField(
            label: 'Destination address',
            helper: 'Paste the wallet address that will receive the funds',
            child: CupertinoTextField(
              controller: _addressController,
              placeholder: 'Wallet address',
              padding: EdgeInsets.symmetric(horizontal: spacing * 1.75, vertical: spacing * 1.25),
              textInputAction: TextInputAction.next,
              decoration: BoxDecoration(
                color: OpeiColors.pureWhite,
                borderRadius: BorderRadius.circular(tokens.inputRadius),
                border: Border.all(color: OpeiColors.iosSeparator.withValues(alpha: 0.8)),
              ),
              style: textTheme.bodyMedium?.copyWith(
                fontSize: 15,
                height: 1.4,
              ),
            ),
          ),
          SizedBox(height: spacing * 1.75),
          _LabeledField(
            label: 'Memo (optional)',
            helper: 'Add a note for your own records',
            child: CupertinoTextField(
              controller: _memoController,
              placeholder: 'Memo or description',
              padding: EdgeInsets.symmetric(horizontal: spacing * 1.75, vertical: spacing * 1.25),
              decoration: BoxDecoration(
                color: OpeiColors.pureWhite,
                borderRadius: BorderRadius.circular(tokens.inputRadius),
                border: Border.all(color: OpeiColors.iosSeparator.withValues(alpha: 0.8)),
              ),
              style: textTheme.bodyMedium?.copyWith(fontSize: 15),
            ),
          ),
          SizedBox(height: spacing * 3),
          Container(
            padding: EdgeInsets.symmetric(horizontal: spacing * 0.5, vertical: spacing * 2),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: OpeiColors.iosSeparator, width: 0.6),
                bottom: BorderSide(color: OpeiColors.iosSeparator, width: 0.6),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                _InfoRow(text: 'Double-check the network and address before submitting.'),
                SizedBox(height: 10),
                _InfoRow(text: 'We’ll notify you when the transfer status updates.'),
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
                    'Withdraw',
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
                ? SvgPicture.asset(
                    _iconAsset!,
                    fit: BoxFit.contain,
                  )
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

  const _LabeledField({required this.label, required this.helper, required this.child});

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
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const _WithdrawConfirmationSheet({
    required this.currency,
    required this.networkLabel,
    required this.amountDisplay,
    required this.addressDisplay,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final spacing = context.responsiveSpacingUnit;
    final tokens = context.responsiveTokens;
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewPadding.bottom + spacing * 2),
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
                  'Review withdrawal',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Confirm these details before we send your $currency.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: OpeiColors.iosLabelSecondary,
                    height: 1.35,
                  ),
                ),
                SizedBox(height: spacing * 2.5),
                _ReviewRow(label: 'Amount', value: amountDisplay),
                SizedBox(height: spacing * 2),
                const Divider(color: OpeiColors.iosSeparator),
                SizedBox(height: spacing * 2),
                _ReviewRow(label: 'Asset', value: currency),
                SizedBox(height: spacing * 2),
                const Divider(color: OpeiColors.iosSeparator),
                SizedBox(height: spacing * 2),
                _ReviewRow(label: 'Network', value: networkLabel),
                SizedBox(height: spacing * 2),
                const Divider(color: OpeiColors.iosSeparator),
                SizedBox(height: spacing * 2),
                _ReviewRow(label: 'Destination', value: addressDisplay),
                SizedBox(height: spacing * 3),
                SizedBox(
                  width: double.infinity,
                  child: CupertinoButton.filled(
                    borderRadius: BorderRadius.circular(tokens.buttonRadius),
                    padding: EdgeInsets.symmetric(vertical: spacing * 1.75),
                    onPressed: onConfirm,
                    child: Text(
                      'Confirm',
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
                        'Cancel',
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
    final statusLabel = response.status[0].toUpperCase() + response.status.substring(1);
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
          'Withdrawal submitted',
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
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        children: [
          SizedBox(height: spacing * 1.5),
          const SuccessHero(iconHeight: 72, gap: 2),
          SizedBox(height: spacing * 2),
          Text(
            'Withdrawal sent',
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: spacing * 1.75),
          Text(
            'We are processing your ${response.asset.toUpperCase()} transfer on $networkLabel network. You will receive an update as soon as confirmations land.',
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
                _DetailRow(label: 'Status', value: statusLabel),
                SizedBox(height: spacing * 1.25),
                _DetailRow(label: 'Reference', value: response.reference),
                SizedBox(height: spacing * 1.25),
                _DetailRow(
                  label: 'Requested',
                  value: '${amountDisplay.format(includeCurrencySymbol: false)} ${currency.toUpperCase()}',
                ),
                SizedBox(height: spacing * 1.25),
                _DetailRow(label: 'Network', value: networkLabel),
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
              'Done',
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