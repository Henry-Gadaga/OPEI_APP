import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tt1/features/deposit/deposit_controller.dart';
import 'package:tt1/theme.dart';

class DepositOptionsSheet extends StatelessWidget {
  const DepositOptionsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: OpeiColors.pureWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
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
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add Money',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Choose how you want to add funds to your wallet.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 15,
                          color: OpeiColors.iosLabelSecondary,
                        ),
                  ),
                  const SizedBox(height: 28),
                  DepositOptionCard(
                    iconAsset: 'assets/images/btc.svg',
                    title: 'Crypto Deposit',
                    description: 'USDT or USDC on supported networks',
                    onTap: () {
                      context.pop();
                      context.push('/deposit/crypto-currency');
                    },
                  ),
                  const SizedBox(height: 4),
                  DepositOptionCard(
                    iconAsset: 'assets/images/exchange.svg',
                    title: 'Exchange',
                    description: 'Bank transfer, Mobile Payments and more',
                    onTap: () {
                      context.pop();
                      context.push('/p2p?intent=buy');
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DepositOptionCard extends StatefulWidget {
  final IconData? icon;
  final String? iconAsset;
  final String title;
  final String description;
  final VoidCallback onTap;

  const DepositOptionCard({
    super.key,
    this.icon,
    this.iconAsset,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  State<DepositOptionCard> createState() => _DepositOptionCardState();
}

class _DepositOptionCardState extends State<DepositOptionCard> with SingleTickerProviderStateMixin {
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
                        ? Icon(widget.icon, color: OpeiColors.pureBlack, size: 26)
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
                    const SizedBox(height: 4),
                    Text(
                      widget.description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 13,
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

class CryptoCurrencySelectionScreen extends StatelessWidget {
  const CryptoCurrencySelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OpeiColors.pureWhite,
      appBar: AppBar(
        backgroundColor: OpeiColors.pureWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: OpeiColors.pureBlack, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Select Currency',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Choose the cryptocurrency you want to deposit',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 15,
                      color: OpeiColors.iosLabelSecondary,
                    ),
              ),
              const SizedBox(height: 20),
              CurrencyOption(
                currency: 'USDT',
                name: 'Tether',
                networks: const ['Polygon', 'Ethereum', 'BSC', 'Tron'],
                onTap: () => context.push('/deposit/crypto-network', extra: 'USDT'),
              ),
              const SizedBox(height: 4),
              CurrencyOption(
                currency: 'USDC',
                name: 'USD Coin',
                networks: const ['Polygon', 'Ethereum', 'BSC'],
                onTap: () => context.push('/deposit/crypto-network', extra: 'USDC'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CurrencyOption extends StatefulWidget {
  final String currency;
  final String name;
  final List<String> networks;
  final VoidCallback onTap;

  const CurrencyOption({
    super.key,
    required this.currency,
    required this.name,
    required this.networks,
    required this.onTap,
  });

  @override
  State<CurrencyOption> createState() => _CurrencyOptionState();
}

class _CurrencyOptionState extends State<CurrencyOption> with SingleTickerProviderStateMixin {
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
                    ? SvgPicture.asset(_iconAsset!, fit: BoxFit.contain)
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
                      '${widget.name} • ${widget.networks.length} networks',
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

class CryptoNetworkSelectionScreen extends ConsumerWidget {
  final String currency;

  const CryptoNetworkSelectionScreen({super.key, required this.currency});

  List<String> get _availableNetworks {
    if (currency == 'USDC') {
      return ['polygon', 'ethereum', 'bsc'];
    }
    return ['polygon', 'ethereum', 'bsc', 'tron'];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: OpeiColors.pureWhite,
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Choose the network for your $currency deposit',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 15,
                      color: OpeiColors.iosLabelSecondary,
                    ),
              ),
              const SizedBox(height: 20),
              ..._availableNetworks.map((network) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: NetworkOption(
                      network: network,
                      onTap: () async {
                        final notifier = ref.read(depositControllerProvider.notifier);
                        final success = await notifier.fetchDepositAddress(
                          currency: currency,
                          network: network,
                        );

                        if (success && context.mounted) {
                          context.push('/deposit/crypto-address', extra: {'currency': currency, 'network': network});
                        } else if (context.mounted) {
                          final error = ref.read(depositControllerProvider).error;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(error ?? 'Failed to fetch deposit address'),
                              backgroundColor: const Color(0xFFFF3B30),
                              behavior: SnackBarBehavior.floating,
                              margin: const EdgeInsets.all(16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

class NetworkOption extends ConsumerStatefulWidget {
  final String network;
  final Future<void> Function()? onTap;

  const NetworkOption({
    super.key,
    required this.network,
    this.onTap,
  });

  @override
  ConsumerState<NetworkOption> createState() => _NetworkOptionState();
}

class _NetworkOptionState extends ConsumerState<NetworkOption> with SingleTickerProviderStateMixin {
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

  String get _networkDisplayName {
    switch (widget.network.toLowerCase()) {
      case 'polygon':
        return 'Polygon (MATIC)';
      case 'ethereum':
        return 'Ethereum (ERC-20)';
      case 'bsc':
        return 'BNB Smart Chain (BEP-20)';
      case 'tron':
        return 'Tron (TRC-20)';
      default:
        return widget.network;
    }
  }

  String get _networkFee {
    switch (widget.network.toLowerCase()) {
      case 'polygon':
        return 'Low fees • Fast';
      case 'ethereum':
        return 'High fees • Secure';
      case 'bsc':
        return 'Low fees • Fast';
      case 'tron':
        return 'Very low fees • Fast';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(depositControllerProvider);
    final isLoading = state.isLoading && state.loadingNetwork == widget.network.toLowerCase();

    return GestureDetector(
      onTapDown: (_) => !isLoading ? _controller.forward() : null,
      onTapUp: (_) async {
        if (!isLoading) {
          _controller.reverse();
          await widget.onTap?.call();
        }
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
                    : const Icon(Icons.hub, color: OpeiColors.pureBlack, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _networkDisplayName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _networkFee,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 12,
                            color: OpeiColors.iosLabelSecondary,
                          ),
                    ),
                  ],
                ),
              ),
              if (isLoading)
                const CupertinoActivityIndicator(radius: 10)
              else
                const Icon(Icons.arrow_forward_ios, color: OpeiColors.iosLabelTertiary, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class CryptoAddressDisplayScreen extends ConsumerWidget {
  final String currency;
  final String network;

  const CryptoAddressDisplayScreen({
    super.key,
    required this.currency,
    required this.network,
  });

  String _resolveNetworkLabel(String value) {
    switch (value.toLowerCase()) {
      case 'polygon':
        return 'Polygon';
      case 'ethereum':
        return 'Ethereum';
      case 'bsc':
        return 'BSC';
      case 'tron':
        return 'Tron';
      default:
        return value;
    }
  }

  String? _resolveNetworkIcon(String value) {
    switch (value.toLowerCase()) {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(depositControllerProvider);
    final displayCurrency = state.selectedCurrency ?? currency;
    final displayNetwork = state.selectedNetwork ?? network;
    final normalizedNetwork = displayNetwork.toLowerCase();
    final networkLabel = _resolveNetworkLabel(displayNetwork);
    final addressValue = state.addressResponse?.address ?? '';
    final hasAddress = addressValue.isNotEmpty;
    final networkIcon = _resolveNetworkIcon(displayNetwork);

    final textTheme = Theme.of(context).textTheme;
    final disableScroll = normalizedNetwork == 'polygon' || normalizedNetwork == 'ethereum';

    return Scaffold(
      backgroundColor: OpeiColors.pureWhite,
      appBar: AppBar(
        backgroundColor: OpeiColors.pureWhite,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: OpeiColors.pureBlack, size: 18),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Deposit Address',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.3,
              ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          physics: disableScroll
              ? const NeverScrollableScrollPhysics()
              : const ClampingScrollPhysics(),
          shrinkWrap: disableScroll,
          children: [
            Text(
              'Scan to deposit',
              style: textTheme.titleLarge?.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.4,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Send ${displayCurrency.toUpperCase()} on $networkLabel',
              style: textTheme.bodyMedium?.copyWith(
                    fontSize: 13,
                    color: OpeiColors.iosLabelSecondary,
                  ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: OpeiColors.iosSurfaceMuted.withOpacity(0.3),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: hasAddress
                        ? Container(
                            key: const ValueKey('qr_ready'),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: OpeiColors.pureWhite,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  width: 160,
                                  height: 160,
                                  child: BarcodeWidget(
                                    data: addressValue,
                                    barcode: Barcode.qrCode(),
                                    backgroundColor: OpeiColors.pureWhite,
                                    color: OpeiColors.pureBlack,
                                    drawText: false,
                                    errorBuilder: (context, error) => Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 24),
                                      child: Text(
                                        'QR unavailable',
                                        textAlign: TextAlign.center,
                                        style: textTheme.bodyMedium?.copyWith(
                                              fontSize: 13,
                                              color: OpeiColors.iosLabelSecondary,
                                            ),
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: OpeiColors.pureWhite,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(5),
                                    child: networkIcon != null
                                        ? SvgPicture.asset(networkIcon, fit: BoxFit.contain)
                                        : Center(
                                            child: Text(
                                              networkLabel.isNotEmpty ? networkLabel[0].toUpperCase() : '',
                                              style: textTheme.titleMedium?.copyWith(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                            ),
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : const SizedBox(
                            key: ValueKey('qr_loading'),
                            height: 160,
                            child: Center(child: CupertinoActivityIndicator(radius: 12)),
                          ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    '${displayCurrency.toUpperCase()} • $networkLabel',
                    style: textTheme.titleMedium?.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.2,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: OpeiColors.iosSurfaceMuted.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: SelectableText(
                            hasAddress ? addressValue : '— — —',
                            style: textTheme.bodyMedium?.copyWith(
                                  fontSize: 12,
                                  height: 1.3,
                                  fontFamily: 'monospace',
                                  color: OpeiColors.pureBlack,
                                ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        CupertinoButton(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          minSize: 0,
                          borderRadius: BorderRadius.circular(8),
                          color: OpeiColors.pureBlack.withOpacity(0.04),
                          onPressed: hasAddress
                              ? () {
                                  Clipboard.setData(ClipboardData(text: addressValue));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Address copied'),
                                      behavior: SnackBarBehavior.floating,
                                      duration: Duration(seconds: 1),
                                    ),
                                  );
                                }
                              : null,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                CupertinoIcons.doc_on_doc,
                                size: 14,
                                color: hasAddress ? OpeiColors.pureBlack : OpeiColors.iosLabelSecondary,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                'Copy',
                                style: textTheme.bodyMedium?.copyWith(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: hasAddress ? OpeiColors.pureBlack : OpeiColors.iosLabelSecondary,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: OpeiColors.iosSurfaceMuted.withOpacity(0.3),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(CupertinoIcons.info_circle, color: OpeiColors.iosLabelSecondary, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        'Important',
                        style: textTheme.titleMedium?.copyWith(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  InfoItem(text: 'Only send ${displayCurrency.toUpperCase()} on $networkLabel network'),
                  const SizedBox(height: 7),
                  InfoItem(text: 'Other assets or networks will cause permanent loss'),
                  const SizedBox(height: 7),
                  InfoItem(text: 'Balance updates after network confirmations'),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewPadding.bottom + 12,
              ),
              child: Align(
                alignment: Alignment.center,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 340),
                  child: SizedBox(
                    width: double.infinity,
                    child: CupertinoButton.filled(
                      borderRadius: BorderRadius.circular(12),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      onPressed: () => context.go('/dashboard'),
                      child: Text(
                        'Done',
                        style: textTheme.bodyMedium?.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: OpeiColors.pureWhite,
                        ),
                      ),
                    ),
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

class InfoItem extends StatelessWidget {
  final String text;

  const InfoItem({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 5),
          width: 3.5,
          height: 3.5,
          decoration: const BoxDecoration(
            color: OpeiColors.iosLabelSecondary,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 12,
                  height: 1.35,
                  color: OpeiColors.iosLabelSecondary,
                ),
          ),
        ),
      ],
    );
  }
}
