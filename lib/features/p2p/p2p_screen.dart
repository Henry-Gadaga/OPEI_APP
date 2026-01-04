import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:dio/dio.dart';
import 'package:opei/core/constants/currencies.dart';
import 'package:opei/core/money/money.dart';
import 'package:opei/data/models/p2p_ad.dart';
import 'package:opei/data/repositories/p2p_repository.dart';
import 'package:opei/features/p2p/p2p_controller.dart';
import 'package:opei/features/p2p/p2p_state.dart';
import 'package:opei/theme.dart';
import 'package:opei/core/providers/providers.dart';
import 'package:opei/data/models/p2p_user_payment_method.dart';
import 'package:opei/data/models/p2p_payment_method_type.dart';
import 'package:opei/data/models/p2p_user_profile.dart';
import 'package:opei/core/network/api_error.dart';
import 'package:opei/data/models/p2p_trade.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:opei/responsive/responsive_tokens.dart';
import 'package:opei/responsive/responsive_widgets.dart';
// Removed SuccessBadge usage in favor of a custom asset checkmark

const List<String> _ratingTagSuggestions = <String>[
  'fast',
  'reliable',
  'friendly',
  'professional',
  'helpful',
  'polite',
];

String _formatUsdAmount(Money value, {bool includeCode = true}) {
  final digits = NumberFormat('#,##0.00', 'en_US').format(value.cents / 100);
  return includeCode ? 'USD $digits' : digits;
}

String _formatMoneyWithCode(Money value) {
  final code = value.currency.toUpperCase();
  final raw = value
      .format(includeCurrencySymbol: false)
      .replaceAll('\u00A0', ' ')
      .trim();

  if (raw.toUpperCase().startsWith(code)) {
    final remainder = raw.substring(code.length).trimLeft();
    return remainder.isEmpty ? '$code 0' : '$code $remainder';
  }

  if (raw.isEmpty) {
    return '$code 0';
  }

  return '$code $raw';
}

String _formatLocalAmount(Money value) =>
    value.format(includeCurrencySymbol: true);

Money _resolveSendFallback({
  required P2PTrade trade,
  Money? sendAmount,
}) {
  if (sendAmount != null) {
    return sendAmount;
  }

  final usdMajorUnits = trade.amount.cents / 100;
  final rateMajorUnits = trade.rate.cents / 100;
  final derivedCents = (usdMajorUnits * rateMajorUnits * 100).round();
  final currency = _resolveSendCurrency(trade: trade, preferred: sendAmount);
  return Money.fromCents(derivedCents, currency: currency);
}

String _resolveSendCurrency({
  required P2PTrade trade,
  Money? preferred,
}) {
  if (preferred != null) {
    return preferred.currency;
  }

  final methodCurrency = (trade.selectedPaymentMethod?.currency ?? '').trim();
  if (methodCurrency.isNotEmpty) {
    return methodCurrency.toUpperCase();
  }

  final adCurrency = (trade.ad.currency).trim();
  if (adCurrency.isNotEmpty) {
    return adCurrency.toUpperCase();
  }

  return trade.currency.toUpperCase();
}

class P2PExchangeScreen extends ConsumerStatefulWidget {
  final P2PAdType? initialType;
  final int? initialTabIndex;

  const P2PExchangeScreen({super.key, this.initialType, this.initialTabIndex});

  @override
  ConsumerState<P2PExchangeScreen> createState() => _P2PExchangeScreenState();
}

class _P2PExchangeScreenState extends ConsumerState<P2PExchangeScreen> {
  late int _selectedTab;
  late final PageController _pageController;
  bool _hasSyncedInitialIntent = false;
  bool _isOpeningCreateAd = false;
  bool _isCreateAdOverlayVisible = false;

  ScrollPhysics _defaultScrollPhysics() {
    final platform = Theme.of(context).platform;
    final isCupertino =
        platform == TargetPlatform.iOS || platform == TargetPlatform.macOS;
    return AlwaysScrollableScrollPhysics(
      parent: isCupertino
          ? const BouncingScrollPhysics()
          : const ClampingScrollPhysics(),
    );
  }

  RefreshIndicator _buildRefreshWrapper({
    required Future<void> Function() onRefresh,
    required Widget child,
  }) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: OpeiColors.pureBlack,
      backgroundColor: OpeiColors.pureWhite,
      displacement: 25,
      triggerMode: RefreshIndicatorTriggerMode.onEdge,
      child: child,
    );
  }

  @override
  void initState() {
    super.initState();
    final initialTab = widget.initialTabIndex;
    _selectedTab = (initialTab != null && initialTab >= 0 && initialTab <= 3)
        ? initialTab
        : 0;
    _pageController = PageController(initialPage: _selectedTab);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _hasSyncedInitialIntent) return;
      _hasSyncedInitialIntent = true;

      final initialType = widget.initialType;
      final adsController = ref.read(p2pAdsControllerProvider.notifier);
      final currentState = ref.read(p2pAdsControllerProvider);

      if (initialType != null && currentState.selectedType != initialType) {
        unawaited(adsController.updateType(initialType));
      } else {
        unawaited(adsController.reload());
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _runTabEntryTasks(_selectedTab);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant P2PExchangeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newType = widget.initialType;
    if (newType == null || newType == oldWidget.initialType) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final adsController = ref.read(p2pAdsControllerProvider.notifier);
      final currentState = ref.read(p2pAdsControllerProvider);
      if (currentState.selectedType != newType) {
        unawaited(adsController.updateType(newType));
      }
    });
  }

  Future<void> _handleRefresh() {
    return ref.read(p2pAdsControllerProvider.notifier).refresh();
  }

  Future<void> _handleMyAdsRefresh() {
    return ref.read(myP2PAdsControllerProvider.notifier).refresh();
  }

  Future<void> _handleProfileRefresh() {
    return ref.read(p2pProfileControllerProvider.notifier).refresh();
  }

  Future<void> _handleOrdersRefresh() {
    return ref.read(p2pOrdersControllerProvider.notifier).refresh();
  }

  Future<void> _handleCancelTrade(P2PTrade trade) async {
    final confirmed = await showP2PCancelTradeWarningDialog(context);
    if (confirmed != true) {
      return;
    }

    if (!mounted) {
      return;
    }

    final controller = ref.read(p2pOrdersControllerProvider.notifier);
    final messenger = ScaffoldMessenger.maybeOf(context);

    try {
      await controller.cancelTrade(trade);
      if (!mounted) return;
      messenger
          ?.showSnackBar(const SnackBar(content: Text('Trade cancelled.')));
    } catch (error) {
      if (!mounted) return;
      final friendly = error is String
          ? error
          : 'We couldn’t cancel this trade. Please try again.';
      messenger?.showSnackBar(SnackBar(content: Text(friendly)));
    }
  }

  Future<void> _openPaymentMethodsManager() async {
    await _showResponsiveSheet<void>(
      builder: (_) => const _PaymentMethodsSheet(),
    );
  }

  Future<void> _openProfileSetup({String? suggestedCurrency}) async {
    final currency = suggestedCurrency ??
        ref.read(p2pAdsControllerProvider).selectedCurrencyCode;
    final result = await _showResponsiveSheet<bool>(
      builder: (_) => _ProfileSetupSheet(initialCurrency: currency),
    );

    if (!mounted) return;
    if (result == true) {
      await ref.read(p2pProfileControllerProvider.notifier).refresh();
    }
  }

  void _handleTabSelection(int index) {
    if (_selectedTab == index) {
      if (index == 3) {
        unawaited(ref.read(p2pProfileControllerProvider.notifier).refresh());
      }
      return;
    }

    setState(() => _selectedTab = index);
    if (_pageController.hasClients) {
      _pageController.jumpToPage(index);
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !_pageController.hasClients) {
          return;
        }
        _pageController.jumpToPage(index);
      });
    }
  }

  void _handlePageChanged(int index) {
    if (_selectedTab != index) {
      setState(() => _selectedTab = index);
    }
    _runTabEntryTasks(index);
  }

  void _runTabEntryTasks(int index) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      switch (index) {
        case 0:
          final adsNotifier = ref.read(p2pAdsControllerProvider.notifier);
          final adsState = ref.read(p2pAdsControllerProvider);
          if (adsState.hasLoaded) {
            unawaited(adsNotifier.refresh());
          } else {
            unawaited(adsNotifier.ensureInitialLoad());
          }
          break;
        case 1:
          final ordersNotifier = ref.read(p2pOrdersControllerProvider.notifier);
          final ordersState = ref.read(p2pOrdersControllerProvider);
          if (ordersState.hasLoaded) {
            unawaited(ordersNotifier.refresh());
          } else {
            unawaited(ordersNotifier.ensureInitialLoad());
          }
          break;
        case 2:
          final myAdsNotifier = ref.read(myP2PAdsControllerProvider.notifier);
          final myAdsState = ref.read(myP2PAdsControllerProvider);
          if (myAdsState.hasLoaded) {
            unawaited(myAdsNotifier.refresh());
          } else {
            unawaited(myAdsNotifier.ensureInitialLoad());
          }
          break;
        case 3:
          final profileNotifier =
              ref.read(p2pProfileControllerProvider.notifier);
          final profileState = ref.read(p2pProfileControllerProvider);
          if (profileState.hasLoaded) {
            unawaited(profileNotifier.refresh());
          } else {
            unawaited(profileNotifier.ensureProfileLoaded());
          }
          break;
      }
    });
  }

  bool? _knownProfilePresence() {
    final profileState = ref.read(p2pProfileControllerProvider);
    if (profileState.profile != null) {
      return true;
    }

    if (profileState.hasLoaded) {
      if (profileState.isMissingProfile) {
        return false;
      }

      if (profileState.errorMessage != null) {
        return null;
      }

      return profileState.profile != null;
    }

    return null;
  }

  Future<void> _openCreateAdFlow() async {
    if (_isOpeningCreateAd) {
      return;
    }

    if (mounted) {
      setState(() => _isOpeningCreateAd = true);
    }

    final selectedCurrency =
        ref.read(p2pAdsControllerProvider).selectedCurrencyCode;

    try {
      var hasProfile = _knownProfilePresence();

      if (hasProfile != true) {
        if (hasProfile == null) {
          final repo = ref.read(p2pRepositoryProvider);
          hasProfile = await repo.fetchProfileStatus();
          if (hasProfile == true) {
            await ref.read(p2pProfileControllerProvider.notifier).refresh();
          }
        }

        if (hasProfile != true) {
          final created = await _presentCreateAdSheet<bool>(
            (_) => _ProfileSetupSheet(initialCurrency: selectedCurrency),
          );
          if (created == true) {
            await ref.read(p2pProfileControllerProvider.notifier).refresh();
          } else {
            return;
          }
        }
      }

      if (!mounted) return;
      await _presentCreateAdSheet<void>(
        (_) => _CreateAdFlowSheet(
            initialCurrency: selectedCurrency, onCreated: _onAdCreated),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_friendlyGenericError(e))),
      );
    } finally {
      if (mounted) {
        setState(() => _isOpeningCreateAd = false);
      }
    }
  }

  Future<T?> _presentCreateAdSheet<T>(WidgetBuilder builder) async {
    if (!mounted) return null;

    setState(() => _isCreateAdOverlayVisible = true);

    try {
      return await _showResponsiveSheet<T>(
        builder: builder,
        enableDrag: false,
      );
    } finally {
      if (mounted) {
        setState(() => _isCreateAdOverlayVisible = false);
      }
    }
  }

  Future<T?> _showResponsiveSheet<T>({
    required WidgetBuilder builder,
    bool enableDrag = true,
  }) {
    return showResponsiveBottomSheet<T>(
      context: context,
      builder: builder,
      isScrollControlled: true,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      enableDrag: enableDrag,
    );
  }

  String _friendlyGenericError(Object e) {
    return 'Something went wrong. Please try again.';
  }

  Future<void> _onAdCreated() async {
    // On ad creation success, refresh My Ads tab
    await ref.read(myP2PAdsControllerProvider.notifier).refresh();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ad submitted for review.')),
    );
  }

  void _showMyAdDetails(P2PAd ad) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _MyAdDetailSheet(ad: ad),
    );
  }

  @override
  Widget build(BuildContext context) {
    final adsState = ref.watch(p2pAdsControllerProvider);
    final controller = ref.read(p2pAdsControllerProvider.notifier);
    final ordersState = ref.watch(p2pOrdersControllerProvider);
    final ordersController = ref.read(p2pOrdersControllerProvider.notifier);
    final myAdsState = ref.watch(myP2PAdsControllerProvider);
    final myAdsController = ref.read(myP2PAdsControllerProvider.notifier);
    final profileState = ref.watch(p2pProfileControllerProvider);
    final authSession = ref.watch(authSessionProvider);

    final spacing = context.responsiveSpacingUnit;

    return ResponsiveScaffold(
      useSafeArea: false,
      padding: EdgeInsets.zero,
      backgroundColor: OpeiColors.pureWhite,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(top: spacing),
          child: PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            onPageChanged: _handlePageChanged,
            children: [
              _buildHomeTab(adsState, controller),
              _buildOrdersTab(ordersState, ordersController, authSession.userId),
              _buildMyAdsTab(myAdsState, myAdsController),
              _buildProfileTab(profileState),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHomeTab(P2PAdsState state, P2PAdsController controller) {
    final bool showOverlay = state.isRefreshing && state.hasLoaded;
    final bool blockInteractions = !state.hasLoaded;
    final spacing = context.responsiveSpacingUnit;
    final tokens = context.responsiveTokens;

    return SafeArea(
      child: _LoadingShield(
        isBlocking: blockInteractions,
        showOverlay: showOverlay,
        child: _buildRefreshWrapper(
          onRefresh: _handleRefresh,
          child: CustomScrollView(
            physics: _defaultScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    tokens.horizontalPadding,
                    spacing * 1.5,
                    tokens.horizontalPadding,
                    0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _BackButton(onTap: () => context.go('/dashboard')),
                          SizedBox(width: spacing),
                          Text(
                            'P2P',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.2,
                              color: OpeiColors.pureBlack,
                              fontFamily: '.SF Pro Display',
                              height: 1.05,
                            ),
                          ),
                          const Spacer(),
                          _buildCurrencyPicker(state, controller),
                        ],
                      ),
                      SizedBox(height: spacing * 1.75),
                      Row(
                        children: [
                          _CompactToggleButton(
                            label: 'Buy',
                            isSelected: state.selectedType == P2PAdType.buy,
                            isLoading: state.isLoading &&
                                state.selectedType == P2PAdType.buy,
                            onTap: () => controller.updateType(P2PAdType.buy),
                          ),
                          const SizedBox(width: 8),
                          _CompactToggleButton(
                            label: 'Sell',
                            isSelected: state.selectedType == P2PAdType.sell,
                            isLoading: state.isLoading &&
                                state.selectedType == P2PAdType.sell,
                            onTap: () => controller.updateType(P2PAdType.sell),
                          ),
                          SizedBox(width: spacing * 1.5),
                          _FilterButton(
                              onTap: () =>
                                  _showAmountFilterSheet(state, controller)),
                        ],
                      ),
                      SizedBox(height: spacing * 1.5),
                      _buildPaymentMethodFilters(state, controller),
                      SizedBox(height: spacing * 1.5),
                    ],
                  ),
                ),
              ),
              if (state.errorMessage != null && state.filteredAds.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: tokens.horizontalPadding,
                    ),
                    child: _MessageBanner(
                        message: state.errorMessage!, isError: true),
                  ),
                ),
              _buildAdsSliver(state),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrencyPicker(P2PAdsState state, P2PAdsController controller) {
    return GestureDetector(
      onTap: () => _showCurrencyPicker(state, controller),
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: OpeiColors.iosSurfaceMuted,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              state.selectedCurrencyCode,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.3,
                height: 1.0,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.keyboard_arrow_down,
                size: 16, color: OpeiColors.iosLabelSecondary),
          ],
        ),
      ),
    );
  }

  void _showCurrencyPicker(P2PAdsState state, P2PAdsController controller) {
    _showResponsiveSheet<void>(
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 36,
              height: 5,
              decoration: BoxDecoration(
                color: OpeiColors.iosSeparator.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(2.5),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Select Currency',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: OpeiColors.pureBlack,
                ),
              ),
            ),
            const SizedBox(height: 12),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 420),
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                itemCount: currencies.length,
                separatorBuilder: (_, __) => Divider(
                  height: 1,
                  color: OpeiColors.iosSeparator.withValues(alpha: 0.3),
                ),
                itemBuilder: (_, i) {
                  final currency = currencies[i];
                  final isSelected =
                      currency.code == state.selectedCurrencyCode;
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        Navigator.of(ctx).pop();
                        controller.updateCurrency(currency.code);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    currency.name,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: OpeiColors.pureBlack,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    currency.code,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: OpeiColors.iosLabelSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              Icon(
                                Icons.check_circle,
                                color: OpeiColors.pureBlack,
                                size: 22,
                              ),
                          ],
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

  Widget _buildPaymentMethodFilters(
      P2PAdsState state, P2PAdsController controller) {
    final paymentMethods = state.paymentMethods;
    final hasMin = state.minAmountCents != null;
    final hasMax = state.maxAmountCents != null;
    final currency = state.selectedCurrencyCode;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _PaymentMethodChip(
                label: 'All',
                isSelected: state.selectedPaymentMethod == null,
                onTap: () => controller.updatePaymentMethod(null),
              ),
              ...paymentMethods.map(
                (method) => Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: _PaymentMethodChip(
                    label: method,
                    isSelected: state.selectedPaymentMethod == method,
                    onTap: () => controller.updatePaymentMethod(method),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (hasMin || hasMax) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              if (hasMin)
                _ActiveFilterChip(
                  label:
                      'Min ${_formatMoneyLabel(Money.fromCents(state.minAmountCents!, currency: currency))}',
                  onClear: () => controller.updateAmountBounds(
                    minAmountCents: null,
                    maxAmountCents: state.maxAmountCents,
                  ),
                ),
              if (hasMax)
                _ActiveFilterChip(
                  label:
                      'Max ${_formatMoneyLabel(Money.fromCents(state.maxAmountCents!, currency: currency))}',
                  onClear: () => controller.updateAmountBounds(
                    minAmountCents: state.minAmountCents,
                    maxAmountCents: null,
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildAdsSliver(P2PAdsState state) {
    if (state.isLoading && !state.hasLoaded) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: CircularProgressIndicator(
            strokeWidth: 1.6,
            color: OpeiColors.pureBlack,
          ),
        ),
      );
    }

    if (state.errorMessage != null && state.filteredAds.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: _CenteredMessage(
          message: state.errorMessage!,
          isError: true,
        ),
      );
    }

    if (state.filteredAds.isEmpty) {
      final message = state.infoMessage ?? 'No ads available right now.';
      return SliverFillRemaining(
        hasScrollBody: false,
        child: _CenteredMessage(message: message),
      );
    }

    final ads = state.filteredAds;
    final intentType = state.selectedType;

    final tokens = context.responsiveTokens;
    final spacing = context.responsiveSpacingUnit;

    return SliverPadding(
      padding: EdgeInsets.fromLTRB(
        tokens.horizontalPadding,
        0,
        tokens.horizontalPadding,
        spacing * 2,
      ),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final ad = ads[index];
            return Padding(
              padding:
                  EdgeInsets.only(bottom: index == ads.length - 1 ? 0 : 10),
              child: _AdSummaryCard(
                ad: ad,
                intentType: intentType,
                onOpenDetails: () => _showAdDetails(ad, intentType),
              ),
            );
          },
          childCount: ads.length,
        ),
      ),
    );
  }

  Widget _buildOrdersTab(
    P2POrdersState state,
    P2POrdersController controller,
    String? currentUserId,
  ) {
    final theme = Theme.of(context);
    final isLoading = state.isLoading;
    final scrollPhysics = _defaultScrollPhysics();
    final bool isInitialState = !state.hasLoaded &&
        !state.isLoading &&
        state.trades.isEmpty &&
        state.errorMessage == null &&
        state.infoMessage == null;

    final spacing = context.responsiveSpacingUnit;
    final tokens = context.responsiveTokens;

    Widget buildContent() {
      if ((isLoading && !state.hasLoaded) || isInitialState) {
        return ListView(
          key: ValueKey('orders-loading-${state.selectedFilter.name}'),
          physics: scrollPhysics,
          padding: const EdgeInsets.symmetric(vertical: 140),
          children: const [
            Center(
              child: CircularProgressIndicator(
                strokeWidth: 1.6,
                color: OpeiColors.pureBlack,
              ),
            ),
          ],
        );
      }

      if (state.errorMessage != null && state.trades.isEmpty) {
        return ListView(
          key: ValueKey('orders-error-${state.selectedFilter.name}'),
          physics: scrollPhysics,
          padding: EdgeInsets.fromLTRB(
            tokens.horizontalPadding,
            80,
            tokens.horizontalPadding,
            40,
          ),
          children: [
            _OrdersErrorState(
              message: state.errorMessage!,
              onRetry: controller.refresh,
            ),
          ],
        );
      }

      if (state.trades.isEmpty) {
        return ListView(
          key: ValueKey('orders-empty-${state.selectedFilter.name}'),
          physics: scrollPhysics,
          padding: EdgeInsets.fromLTRB(
            tokens.horizontalPadding + spacing,
            80,
            tokens.horizontalPadding + spacing,
            40,
          ),
          children: [
            _OrdersEmptyState(info: state.infoMessage),
          ],
        );
      }

      return ListView.separated(
        key: ValueKey(
            'orders-${state.selectedFilter.name}-${state.trades.length}'),
        physics: scrollPhysics,
        padding: EdgeInsets.fromLTRB(
          tokens.horizontalPadding,
          spacing * 1.5,
          tokens.horizontalPadding,
          26,
        ),
        itemCount: state.trades.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, index) {
          final trade = state.trades[index];
          final bool? isBuyer =
              currentUserId == null ? null : currentUserId == trade.buyerId;
          final canCancel = _canCurrentUserCancelTrade(
              trade: trade, currentUserId: currentUserId);
          final isCancelling = state.isTradeCancelling(trade.id);
          return _OrderCard(
            trade: trade,
            isBuyer: isBuyer,
            canCancel: canCancel,
            isCancelling: isCancelling,
            onCancel: canCancel ? () => _handleCancelTrade(trade) : null,
          );
        },
      );
    }

    final list = buildContent();
    final bool showOverlay = state.isRefreshing && state.hasLoaded;
    final bool blockInteractions = !state.hasLoaded;

    return SafeArea(
      child: _LoadingShield(
        isBlocking: blockInteractions,
        showOverlay: showOverlay,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                tokens.horizontalPadding,
                spacing * 1.5,
                tokens.horizontalPadding,
                0,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: _BackButton(onTap: () => _handleTabSelection(0)),
                  ),
                  Text(
                    'Orders',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: spacing),
            _OrdersFilterRow(
              selectedFilter: state.selectedFilter,
              onSelected: controller.updateFilter,
            ),
            SizedBox(height: spacing),
            if (state.errorMessage != null && state.trades.isNotEmpty)
              Padding(
                padding: EdgeInsets.fromLTRB(
                  tokens.horizontalPadding,
                  0,
                  tokens.horizontalPadding,
                  spacing * 0.5,
                ),
                child:
                    _MessageBanner(message: state.errorMessage!, isError: true),
              )
            else if (state.infoMessage != null && state.trades.isNotEmpty)
              Padding(
                padding: EdgeInsets.fromLTRB(
                  tokens.horizontalPadding,
                  0,
                  tokens.horizontalPadding,
                  spacing * 0.5,
                ),
                child:
                    _MessageBanner(message: state.infoMessage!, isError: false),
              ),
            Expanded(
              child: _buildRefreshWrapper(
                onRefresh: _handleOrdersRefresh,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  layoutBuilder: (currentChild, previousChildren) =>
                      currentChild ?? const SizedBox.shrink(),
                  child: list,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMyAdsTab(MyP2PAdsState state, MyP2PAdsController controller) {
    final theme = Theme.of(context);
    final isLoading = state.isLoading;
    final isCreateAdButtonLoading =
        _isOpeningCreateAd && !_isCreateAdOverlayVisible;
    final scrollPhysics = _defaultScrollPhysics();
    final spacing = context.responsiveSpacingUnit;
    final tokens = context.responsiveTokens;
    final bool isInitialState = !state.hasLoaded &&
        !state.isLoading &&
        state.ads.isEmpty &&
        state.errorMessage == null &&
        state.infoMessage == null;

    Widget buildContent() {
      if ((isLoading && !state.hasLoaded) || isInitialState) {
        return ListView(
          key: ValueKey('my-ads-loading-${state.selectedFilter.name}'),
          physics: scrollPhysics,
          padding: const EdgeInsets.symmetric(vertical: 140),
          children: const [
            Center(
              child: CircularProgressIndicator(
                strokeWidth: 1.6,
                color: OpeiColors.pureBlack,
              ),
            ),
          ],
        );
      }

      if (state.errorMessage != null && state.ads.isEmpty) {
        return ListView(
          key: ValueKey('my-ads-error-${state.selectedFilter.name}'),
          physics: scrollPhysics,
          padding: EdgeInsets.fromLTRB(
            tokens.horizontalPadding,
            80,
            tokens.horizontalPadding,
            40,
          ),
          children: [
            _OrdersErrorState(
              message: state.errorMessage!,
              onRetry: controller.refresh,
              title: 'We couldn’t load your ads',
            ),
          ],
        );
      }

      if (state.ads.isEmpty) {
        return ListView(
          key: ValueKey('my-ads-empty-${state.selectedFilter.name}'),
          physics: scrollPhysics,
          padding: EdgeInsets.symmetric(
            horizontal: tokens.horizontalPadding + spacing,
            vertical: 40,
          ),
          children: [
            _MyAdsEmptyState(
              onCreateAd: _openCreateAdFlow,
              isLoading: isCreateAdButtonLoading,
            ),
          ],
        );
      }

      return ListView.separated(
        key:
            ValueKey('my-ads-${state.selectedFilter.name}-${state.ads.length}'),
        physics: scrollPhysics,
        padding: EdgeInsets.fromLTRB(
          tokens.horizontalPadding,
          spacing * 2,
          tokens.horizontalPadding,
          32,
        ),
        itemCount: state.ads.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, index) {
          final ad = state.ads[index];
          return _MyAdCard(
            ad: ad,
            onTap: () => _showMyAdDetails(ad),
          );
        },
      );
    }

    final list = buildContent();
    final bool showOverlay = state.isRefreshing && state.hasLoaded;
    final bool blockInteractions = !state.hasLoaded;

    return SafeArea(
      child: _LoadingShield(
        isBlocking: blockInteractions,
        showOverlay: showOverlay,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                tokens.horizontalPadding,
                spacing * 1.5,
                tokens.horizontalPadding,
                0,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: _BackButton(onTap: () => _handleTabSelection(0)),
                  ),
                  Text(
                    'My Ads',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.3,
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: _CreateAdButton(
                      onTap: _openCreateAdFlow,
                      isLoading: isCreateAdButtonLoading,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: spacing * 1.5),
            _MyAdsFilterRow(
              selectedFilter: state.selectedFilter,
              onSelected: controller.updateFilter,
            ),
            SizedBox(height: spacing),
            if (state.errorMessage != null && state.ads.isNotEmpty)
              Padding(
                padding: EdgeInsets.fromLTRB(
                  tokens.horizontalPadding,
                  spacing * 1.5,
                  tokens.horizontalPadding,
                  0,
                ),
                child:
                    _MessageBanner(message: state.errorMessage!, isError: true),
              )
            else if (state.infoMessage != null && state.ads.isEmpty)
              Padding(
                padding: EdgeInsets.fromLTRB(
                  tokens.horizontalPadding,
                  spacing * 1.5,
                  tokens.horizontalPadding,
                  0,
                ),
                child:
                    _MessageBanner(message: state.infoMessage!, isError: false),
              ),
            SizedBox(height: spacing),
            Expanded(
              child: _buildRefreshWrapper(
                onRefresh: _handleMyAdsRefresh,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  layoutBuilder: (child, previousChildren) =>
                      child ?? const SizedBox.shrink(),
                  child: list,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileTab(P2PProfileState state) {
    final theme = Theme.of(context);
    final spacing = context.responsiveSpacingUnit;
    final tokens = context.responsiveTokens;

    final bool isInitialState = !state.hasLoaded &&
        !state.isLoading &&
        state.profile == null &&
        !state.isMissingProfile &&
        state.errorMessage == null;

    Widget content;
    if ((state.isLoading && !state.hasLoaded) || isInitialState) {
      content = const Center(child: _ProfileLoadingCard());
    } else if (state.profile != null) {
      content = _ProfileContentView(
        profile: state.profile!,
        onRefresh: _handleProfileRefresh,
        onEdit: () => _openProfileSetup(
            suggestedCurrency: state.profile!.preferredCurrency),
        onManagePaymentMethods: _openPaymentMethodsManager,
      );
    } else if (state.isMissingProfile) {
      content = Center(
        child: _ProfileEmptyCard(
          onCreate: () => _openProfileSetup(),
        ),
      );
    } else if (state.errorMessage != null) {
      content = Center(
        child: _ProfileErrorCard(
          message: state.errorMessage!,
          onRetry: _handleProfileRefresh,
        ),
      );
    } else {
      content = Center(
        child: _ProfileErrorCard(
          message:
              'We could not load your profile right now. Please try again.',
          onRetry: _handleProfileRefresh,
        ),
      );
    }

    final bool showOverlay = state.isRefreshing && state.hasLoaded;
    final bool blockInteractions = !state.hasLoaded;

    return SafeArea(
      child: _LoadingShield(
        isBlocking: blockInteractions,
        showOverlay: showOverlay,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                tokens.horizontalPadding,
                spacing * 1.5,
                tokens.horizontalPadding,
                0,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: _BackButton(onTap: () => _handleTabSelection(0)),
                  ),
                  Text(
                    'Profile',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: spacing),
            SizedBox(height: spacing * 0.5),
            if (state.errorMessage != null &&
                (state.profile != null || state.isMissingProfile))
              Padding(
                padding: EdgeInsets.fromLTRB(
                  tokens.horizontalPadding,
                  0,
                  tokens.horizontalPadding,
                  spacing,
                ),
                child:
                    _MessageBanner(message: state.errorMessage!, isError: true),
              ),
            Expanded(child: content),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    final tokens = context.responsiveTokens;

    return Container(
      decoration: BoxDecoration(
        color: OpeiColors.pureWhite,
        border: Border(
          top: BorderSide(
            color: OpeiColors.iosSeparator.withValues(alpha: 0.15),
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        child: SizedBox(
          height: 52,
          child: Padding(
            padding:
                EdgeInsets.symmetric(horizontal: tokens.horizontalPadding),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _NavItem(
                  icon: Icons.home_outlined,
                  selectedIcon: Icons.home,
                  label: 'Home',
                  isSelected: _selectedTab == 0,
                  onTap: () => _handleTabSelection(0),
                ),
                _NavItem(
                  icon: Icons.receipt_long_outlined,
                  selectedIcon: Icons.receipt_long,
                  label: 'Orders',
                  isSelected: _selectedTab == 1,
                  onTap: () => _handleTabSelection(1),
                ),
                _NavItem(
                  icon: Icons.campaign_outlined,
                  selectedIcon: Icons.campaign,
                  label: 'My Ads',
                  isSelected: _selectedTab == 2,
                  onTap: () => _handleTabSelection(2),
                ),
                _NavItem(
                  icon: Icons.person_outline,
                  selectedIcon: Icons.person,
                  label: 'Profile',
                  isSelected: _selectedTab == 3,
                  onTap: () => _handleTabSelection(3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAmountFilterSheet(
      P2PAdsState state, P2PAdsController controller) async {
    final minController = TextEditingController(
      text: state.minAmountCents != null
          ? _formatMajorAmount(
              state.minAmountCents!, state.selectedCurrencyCode)
          : '',
    );
    final maxController = TextEditingController(
      text: state.maxAmountCents != null
          ? _formatMajorAmount(
              state.maxAmountCents!, state.selectedCurrencyCode)
          : '',
    );

    String? validationError;

    await _showResponsiveSheet<void>(
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final bottomInset = MediaQuery.of(context).viewInsets.bottom;
            return AnimatedPadding(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              padding: EdgeInsets.only(bottom: bottomInset),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: OpeiColors.iosSeparator.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Amount filters',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            fontFamily: '.SF Pro Display',
                          ),
                    ),
                    const SizedBox(height: 18),
                    _AmountField(
                      label: 'Minimum amount',
                      currency: state.selectedCurrencyCode,
                      controller: minController,
                    ),
                    const SizedBox(height: 14),
                    _AmountField(
                      label: 'Maximum amount',
                      currency: state.selectedCurrencyCode,
                      controller: maxController,
                    ),
                    if (validationError != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        validationError!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontSize: 12,
                              color: const Color(0xFFFF3B30),
                            ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () async {
                              final navigator = Navigator.of(context);
                              await controller.updateAmountBounds(
                                minAmountCents: null,
                                maxAmountCents: null,
                              );
                              if (!mounted) return;
                              navigator.pop();
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: OpeiColors.pureBlack,
                              side: BorderSide(
                                color: OpeiColors.iosSeparator
                                    .withValues(alpha: 0.5),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text('Clear filters'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              final navigator = Navigator.of(context);
                              final minCents =
                                  _parseMajorToCents(minController.text);
                              final maxCents =
                                  _parseMajorToCents(maxController.text);

                              if (minCents != null &&
                                  maxCents != null &&
                                  minCents > maxCents) {
                                setSheetState(() {
                                  validationError =
                                      'The minimum amount can’t be higher than the maximum.';
                                });
                                return;
                              }

                              setSheetState(() => validationError = null);

                              await controller.updateAmountBounds(
                                minAmountCents: minCents,
                                maxAmountCents: maxCents,
                              );

                              if (!mounted) return;
                              navigator.pop();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: OpeiColors.pureBlack,
                              foregroundColor: OpeiColors.pureWhite,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                            child: const Text('Apply filters'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    minController.dispose();
    maxController.dispose();
  }

  void _showAdDetails(P2PAd ad, P2PAdType intentType) async {
    final result = await _showResponsiveSheet<dynamic>(
      builder: (context) {
        final inset = MediaQuery.of(context).viewInsets.bottom;
        return Padding(
          padding: EdgeInsets.only(bottom: inset),
          child: _AdDetailsSheet(ad: ad, intentType: intentType),
        );
      },
    );

    if (!mounted) {
      return;
    }

    if (result is Map && result['goToOrders'] == true) {
      _handleTabSelection(1);
      return;
    }

    if (result == null || result is! Money) {
      return;
    }

    final actionLabel = intentType.displayLabel;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$actionLabel ${result.format(includeCurrencySymbol: true)}',
        ),
      ),
    );
  }

  String _formatMoneyLabel(Money money) {
    return money.format(includeCurrencySymbol: true);
  }

  String _formatMajorAmount(int cents, String currency) {
    final formatter = NumberFormat('#,##0.##');
    final money = Money.fromCents(cents, currency: currency);
    return formatter.format(money.inMajorUnits);
  }

  int? _parseMajorToCents(String value) {
    final sanitized = value.replaceAll(',', '').trim();
    if (sanitized.isEmpty) {
      return null;
    }

    final parsed = double.tryParse(sanitized);
    if (parsed == null) {
      return null;
    }

    final cents = (parsed * 100).round();
    if (cents <= 0) {
      return null;
    }
    return cents;
  }
}

class _BackButton extends StatefulWidget {
  final VoidCallback onTap;

  const _BackButton({required this.onTap});

  @override
  State<_BackButton> createState() => _BackButtonState();
}

class _BackButtonState extends State<_BackButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 80));
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.94).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
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
          width: 34,
          height: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: OpeiColors.pureWhite,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: OpeiColors.iosSeparator.withValues(alpha: 0.25),
              width: 0.5,
            ),
          ),
          child: const Icon(
            Icons.arrow_back_ios_new,
            size: 15,
            color: OpeiColors.pureBlack,
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatefulWidget {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 80));
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
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
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.isSelected ? widget.selectedIcon : widget.icon,
                size: 22,
                color: widget.isSelected
                    ? OpeiColors.pureBlack
                    : OpeiColors.iosLabelTertiary,
              ),
              const SizedBox(height: 2),
              Text(
                widget.label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 10,
                      fontWeight:
                          widget.isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: widget.isSelected
                          ? OpeiColors.pureBlack
                          : OpeiColors.iosLabelTertiary,
                      letterSpacing: -0.1,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompactToggleButton extends StatefulWidget {
  final String label;
  final bool isSelected;
  final bool isLoading;
  final VoidCallback onTap;

  const _CompactToggleButton({
    required this.label,
    required this.isSelected,
    this.isLoading = false,
    required this.onTap,
  });

  @override
  State<_CompactToggleButton> createState() => _CompactToggleButtonState();
}

class _CompactToggleButtonState extends State<_CompactToggleButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 80));
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? OpeiColors.pureBlack
                : OpeiColors.iosSurfaceMuted,
            borderRadius: BorderRadius.circular(8),
          ),
          child: widget.isLoading
              ? SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.6,
                    color: widget.isSelected
                        ? OpeiColors.pureWhite
                        : OpeiColors.pureBlack,
                  ),
                )
              : Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: widget.isSelected
                        ? OpeiColors.pureWhite
                        : OpeiColors.pureBlack,
                    fontFamily: '.SF Pro Text',
                    letterSpacing: -0.2,
                    height: 1.0,
                  ),
                ),
        ),
      ),
    );
  }
}

class _PaymentMethodChip extends StatefulWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaymentMethodChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_PaymentMethodChip> createState() => _PaymentMethodChipState();
}

class _PaymentMethodChipState extends State<_PaymentMethodChip>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 70));
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.94).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
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
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? OpeiColors.pureBlack
                : OpeiColors.iosSurfaceMuted,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: widget.isSelected
                  ? OpeiColors.pureBlack
                  : OpeiColors.iosSeparator.withValues(alpha: 0.25),
              width: 0.5,
            ),
          ),
          child: Text(
            widget.label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: widget.isSelected
                      ? OpeiColors.pureWhite
                      : OpeiColors.pureBlack,
                  letterSpacing: -0.1,
                ),
          ),
        ),
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  final VoidCallback onTap;

  const _FilterButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: OpeiColors.pureWhite,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
              color: OpeiColors.iosSeparator.withValues(alpha: 0.25),
              width: 0.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.tune_rounded, size: 15, color: OpeiColors.pureBlack),
            const SizedBox(width: 6),
            Text(
              'Amount',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.1,
                    color: OpeiColors.pureBlack,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CreateAdButton extends StatefulWidget {
  final VoidCallback onTap;
  final bool isLoading;

  const _CreateAdButton({required this.onTap, this.isLoading = false});

  @override
  State<_CreateAdButton> createState() => _CreateAdButtonState();
}

class _CreateAdButtonState extends State<_CreateAdButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100));
    _scale = Tween<double>(begin: 1, end: 0.94).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AbsorbPointer(
      absorbing: widget.isLoading,
      child: GestureDetector(
        onTapDown: (_) {
          if (!widget.isLoading) {
            _controller.forward();
          }
        },
        onTapUp: (_) {
          _controller.reverse();
          if (!widget.isLoading) {
            widget.onTap();
          }
        },
        onTapCancel: () => _controller.reverse(),
        child: ScaleTransition(
          scale: _scale,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: OpeiColors.pureBlack,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.isLoading)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.6,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(OpeiColors.pureWhite),
                    ),
                  )
                else
                  const Icon(Icons.add_rounded,
                      size: 16, color: OpeiColors.pureWhite),
                SizedBox(width: widget.isLoading ? 8 : 6),
                Text(
                  widget.isLoading ? 'Opening…' : 'Create Ad',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: OpeiColors.pureWhite,
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

class _ActiveFilterChip extends StatelessWidget {
  final String label;
  final VoidCallback onClear;

  const _ActiveFilterChip({required this.label, required this.onClear});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: OpeiColors.pureBlack,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: OpeiColors.pureWhite,
                ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onClear,
            child:
                const Icon(Icons.close, size: 12, color: OpeiColors.pureWhite),
          ),
        ],
      ),
    );
  }
}

class _MessageBanner extends StatelessWidget {
  final String message;
  final bool isError;

  const _MessageBanner({required this.message, this.isError = false});

  @override
  Widget build(BuildContext context) {
    final background = isError
        ? const Color(0xFFFFF2F1)
        : OpeiColors.iosSurfaceMuted.withValues(alpha: 0.8);
    final foreground =
        isError ? const Color(0xFFFF3B30) : OpeiColors.iosLabelSecondary;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: foreground.withValues(alpha: 0.3), width: 0.5),
      ),
      child: Text(
        message,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: foreground,
            ),
      ),
    );
  }
}

class _ProfileContentView extends StatelessWidget {
  final P2PUserProfile profile;
  final Future<void> Function() onRefresh;
  final VoidCallback onEdit;
  final VoidCallback onManagePaymentMethods;

  const _ProfileContentView({
    required this.profile,
    required this.onRefresh,
    required this.onEdit,
    required this.onManagePaymentMethods,
  });

  @override
  Widget build(BuildContext context) {
    final numberFormat = NumberFormat.compact();
    final ratingLabel = profile.rating > 0
        ? profile.rating.toStringAsFixed(1)
        : 'Not rated yet';
    final tradesLabel = numberFormat.format(profile.totalTrades);
    final joinedLabel = profile.createdAt != null
        ? DateFormat('d MMM yyyy').format(profile.createdAt!.toLocal())
        : null;
    final platform = Theme.of(context).platform;
    final isCupertino =
        platform == TargetPlatform.iOS || platform == TargetPlatform.macOS;
    final scrollPhysics = AlwaysScrollableScrollPhysics(
      parent: isCupertino
          ? const BouncingScrollPhysics()
          : const ClampingScrollPhysics(),
    );

    return RefreshIndicator(
      onRefresh: onRefresh,
      color: OpeiColors.pureBlack,
      backgroundColor: OpeiColors.pureWhite,
      displacement: 25,
      triggerMode: RefreshIndicatorTriggerMode.onEdge,
      child: ListView(
        physics: scrollPhysics,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        children: [
          const SizedBox(height: 4),
          _ProfileHeroCard(
            profile: profile,
            ratingLabel: ratingLabel,
            tradesLabel: tradesLabel,
            joinedLabel: joinedLabel,
            onEdit: onEdit,
          ),
          if (profile.friendlyBio != null) ...[
            const SizedBox(height: 16),
            _ProfileBioSection(bio: profile.friendlyBio!),
          ],
          const SizedBox(height: 16),
          _ProfileDetailsSection(
            preferredLanguage: profile.friendlyLanguage,
            preferredCurrency: profile.preferredCurrency,
            joinedLabel: joinedLabel,
          ),
          const SizedBox(height: 16),
          _ProfileQuickActions(
            onManagePaymentMethods: onManagePaymentMethods,
          ),
        ],
      ),
    );
  }
}

class _ProfileLoadingCard extends StatelessWidget {
  const _ProfileLoadingCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 40,
          child: Center(
            child: CircularProgressIndicator(
              strokeWidth: 1.6,
              color: OpeiColors.pureBlack,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Loading profile…',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: OpeiColors.iosLabelSecondary,
          ),
        ),
      ],
    );
  }
}

class _ProfileErrorCard extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const _ProfileErrorCard({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final normalized = message.toLowerCase();
    final isSessionIssue =
        normalized.contains('session') || normalized.contains('sign in');
    final title = isSessionIssue
        ? 'You need to sign in again'
        : 'We couldn’t load your profile';
    final iconData = isSessionIssue ? Icons.lock_outline : Icons.error_outline;
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 26, 24, 24),
      decoration: BoxDecoration(
        color: OpeiColors.pureWhite,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: OpeiColors.iosSeparator.withValues(alpha: 0.18),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 30,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: OpeiColors.iosSurfaceMuted,
              shape: BoxShape.circle,
            ),
            child: Icon(
              iconData,
              color: OpeiColors.pureBlack,
              size: 28,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            title,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: 13,
              color: OpeiColors.iosLabelSecondary,
              height: 1.48,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => onRetry(),
              style: ElevatedButton.styleFrom(
                backgroundColor: OpeiColors.pureBlack,
                foregroundColor: OpeiColors.pureWhite,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text(
                'Refresh session',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileEmptyCard extends StatelessWidget {
  final VoidCallback onCreate;

  const _ProfileEmptyCard({required this.onCreate});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
      decoration: BoxDecoration(
        color: OpeiColors.pureWhite,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
            color: OpeiColors.iosSeparator.withValues(alpha: 0.12), width: 0.6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 30,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF111111), Color(0xFF303030)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.person_add_alt_1_rounded,
              size: 32,
              color: OpeiColors.pureWhite,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Set up your P2P profile',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Let buyers and sellers know who they’re dealing with. A verified profile speeds up trust checks and trade approvals.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: 13,
              height: 1.5,
              color: OpeiColors.iosLabelSecondary,
            ),
          ),
          const SizedBox(height: 18),
          Column(
            children: const [
              _ProfileHighlightRow(
                icon: Icons.check_circle_outline,
                text: 'Share a friendly name and short bio',
              ),
              SizedBox(height: 6),
              _ProfileHighlightRow(
                icon: Icons.lock_open_rounded,
                text: 'Unlock higher limits with verified details',
              ),
            ],
          ),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onCreate,
              style: ElevatedButton.styleFrom(
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: OpeiColors.pureBlack,
                foregroundColor: OpeiColors.pureWhite,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text(
                    'Create profile',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward_rounded, size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileHighlightRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _ProfileHighlightRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: OpeiColors.pureBlack),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: 13,
              color: OpeiColors.iosLabelSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileHeroCard extends StatelessWidget {
  final P2PUserProfile profile;
  final String ratingLabel;
  final String tradesLabel;
  final String? joinedLabel;
  final VoidCallback onEdit;

  const _ProfileHeroCard({
    required this.profile,
    required this.ratingLabel,
    required this.tradesLabel,
    required this.joinedLabel,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasRating = profile.rating > 0;
    final ratingValue = hasRating ? ratingLabel : '—';
    final tradesValue = profile.totalTrades > 0 ? tradesLabel : '—';
    final sinceValue = joinedLabel ?? '—';

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        color: OpeiColors.pureWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: OpeiColors.iosSeparator.withValues(alpha: 0.14),
          width: 0.6,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ProfileAvatar(initials: profile.initials),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.primaryName,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      profile.usernameLabel,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 11,
                        color: OpeiColors.iosLabelSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (joinedLabel != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Since $sinceValue',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 10,
                          color: OpeiColors.iosLabelSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: onEdit,
                style: TextButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  foregroundColor: OpeiColors.pureBlack,
                  backgroundColor:
                      OpeiColors.iosSurfaceMuted.withValues(alpha: 0.8),
                  textStyle: const TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w600),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  minimumSize: const Size(0, 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('Edit'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: OpeiColors.iosSurfaceMuted.withValues(alpha: 0.75),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _ProfileMetric(
                    label: 'Rating',
                    value: ratingValue,
                    emphasize: hasRating,
                  ),
                ),
                const _ProfileMetricDivider(),
                Expanded(
                  child: _ProfileMetric(
                    label: 'Trades',
                    value: tradesValue,
                  ),
                ),
                const _ProfileMetricDivider(),
                Expanded(
                  child: _ProfileMetric(
                    label: 'Since',
                    value: sinceValue,
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

class _ProfileAvatar extends StatelessWidget {
  final String initials;

  const _ProfileAvatar({required this.initials});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: OpeiColors.iosSurfaceMuted.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: OpeiColors.iosSeparator.withValues(alpha: 0.18),
          width: 0.6,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: theme.textTheme.titleLarge?.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: OpeiColors.pureBlack,
        ),
      ),
    );
  }
}

class _ProfileMetric extends StatelessWidget {
  final String label;
  final String value;
  final bool emphasize;

  const _ProfileMetric({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            fontSize: 9,
            color: OpeiColors.iosLabelSecondary,
            letterSpacing: 0.1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontSize: 13,
            fontWeight: emphasize ? FontWeight.w700 : FontWeight.w600,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }
}

class _ProfileMetricDivider extends StatelessWidget {
  const _ProfileMetricDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 28,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: OpeiColors.iosSeparator.withValues(alpha: 0.25),
    );
  }
}

class _ProfileBioSection extends StatelessWidget {
  final String bio;

  const _ProfileBioSection({required this.bio});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: BoxDecoration(
        color: OpeiColors.pureWhite,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
            color: OpeiColors.iosSeparator.withValues(alpha: 0.12), width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About',
            style: theme.textTheme.titleMedium?.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            bio,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: 14,
              height: 1.5,
              color: OpeiColors.pureBlack,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileDetailsSection extends StatelessWidget {
  final String preferredLanguage;
  final String preferredCurrency;
  final String? joinedLabel;

  const _ProfileDetailsSection({
    required this.preferredLanguage,
    required this.preferredCurrency,
    required this.joinedLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final entries = <MapEntry<String, String>>[
      MapEntry('Preferred currency', preferredCurrency),
      MapEntry('Preferred language', preferredLanguage),
      MapEntry('Member since', joinedLabel ?? 'Not available'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: OpeiColors.pureWhite,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
            color: OpeiColors.iosSeparator.withValues(alpha: 0.12), width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 6),
            child: Text(
              'Profile details',
              style: theme.textTheme.titleMedium?.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
              ),
            ),
          ),
          const Divider(height: 1, thickness: 0.5, color: Color(0xFFE3E3E8)),
          for (var i = 0; i < entries.length; i++) ...[
            _ProfileDetailRow(
              label: entries[i].key,
              value: entries[i].value,
            ),
            if (i != entries.length - 1)
              const Divider(
                  height: 1, thickness: 0.5, color: Color(0xFFEDEDF1)),
          ],
        ],
      ),
    );
  }
}

class _ProfileDetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _ProfileDetailRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 12,
                color: OpeiColors.iosLabelSecondary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w600,
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

  const _DetailRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 11,
                color: OpeiColors.iosLabelSecondary,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: OpeiColors.pureBlack,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileQuickActions extends StatelessWidget {
  final VoidCallback onManagePaymentMethods;

  const _ProfileQuickActions({
    required this.onManagePaymentMethods,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: OpeiColors.pureWhite,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
            color: OpeiColors.iosSeparator.withValues(alpha: 0.12), width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 6),
            child: Text(
              'Account tools',
              style: theme.textTheme.titleMedium?.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
              ),
            ),
          ),
          const Divider(height: 1, thickness: 0.5, color: Color(0xFFE3E3E8)),
          _ActionTile(
            icon: Icons.account_balance_wallet_outlined,
            iconColor: const Color(0xFF007AFF),
            title: 'Payment methods',
            subtitle: 'Manage payout accounts',
            onTap: onManagePaymentMethods,
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Icon(icon, size: 18, color: iconColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 12,
                      color: OpeiColors.iosLabelSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: OpeiColors.iosLabelSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentMethodsSheet extends ConsumerStatefulWidget {
  const _PaymentMethodsSheet();

  @override
  ConsumerState<_PaymentMethodsSheet> createState() =>
      _PaymentMethodsSheetState();
}

class _PaymentMethodsSheetState extends ConsumerState<_PaymentMethodsSheet> {
  bool _isLoading = true;
  bool _isRefreshing = false;
  String? _errorMessage;
  List<P2PUserPaymentMethod> _methods = const [];

  @override
  void initState() {
    super.initState();
    _loadMethods();
  }

  Future<void> _loadMethods({bool asRefresh = false}) async {
    setState(() {
      if (asRefresh) {
        _isRefreshing = true;
      } else {
        _isLoading = true;
      }
      _errorMessage = null;
    });

    try {
      final repo = ref.read(p2pRepositoryProvider);
      final fetched = await repo.fetchUserPaymentMethods();
      final list = fetched.toList(growable: true);
      if (!mounted) return;
      list.sort((a, b) {
        final currencyCompare = a.currency.compareTo(b.currency);
        if (currencyCompare != 0) return currencyCompare;
        return a.providerName
            .toLowerCase()
            .compareTo(b.providerName.toLowerCase());
      });
      setState(() {
        _methods = list;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = _mapError(error);
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isRefreshing = false;
        });
      }
    }
  }

  String _mapError(Object error) {
    if (error is ApiError) {
      final status = error.statusCode ?? 0;
      final message = error.message.toLowerCase();
      if (status == 400 || status == 401) {
        if (message.contains('missing') && message.contains('x-user-id')) {
          return 'We couldn’t verify your session. Please sign in again to manage payment methods.';
        }
        return 'We couldn’t verify your session. Please sign in again.';
      }
      if (status >= 500) {
        return 'We’re having trouble loading your payment methods right now. Please try again shortly.';
      }
      return 'We couldn’t load payment methods right now. Please try again.';
    }

    final message = error.toString().toLowerCase();
    if (message.contains('missing') && message.contains('x-user-id')) {
      return 'We couldn’t verify your session. Please sign in again to manage payment methods.';
    }
    if (message.contains('unauthorized')) {
      return 'We couldn’t verify your session. Please sign in again.';
    }
    return 'We couldn’t load payment methods right now. Please try again.';
  }

  Future<void> _handleAddMethod() async {
    final currency = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: OpeiColors.pureWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const _CurrencySelectorSheet(),
    );

    if (!mounted || currency == null) {
      return;
    }

    final created = await showModalBottomSheet<P2PUserPaymentMethod>(
      context: context,
      isScrollControlled: true,
      backgroundColor: OpeiColors.pureWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _AddPaymentMethodSheet(currency: currency),
    );

    if (created != null) {
      await _loadMethods(asRefresh: true);
    }
  }

  Future<void> _handleEditMethod(P2PUserPaymentMethod method) async {
    final updated = await showModalBottomSheet<P2PUserPaymentMethod>(
      context: context,
      isScrollControlled: true,
      backgroundColor: OpeiColors.pureWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _AddPaymentMethodSheet(
        currency: method.currency,
        initialMethod: method,
      ),
    );

    if (updated != null) {
      await _loadMethods(asRefresh: true);
    }
  }

  Map<String, List<P2PUserPaymentMethod>> _groupByCurrency(
      List<P2PUserPaymentMethod> methods) {
    final map = <String, List<P2PUserPaymentMethod>>{};
    for (final method in methods) {
      map
          .putIfAbsent(method.currency, () => <P2PUserPaymentMethod>[])
          .add(method);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final spacing = context.responsiveSpacingUnit;
    final tokens = context.responsiveTokens;
    final theme = Theme.of(context);
    final grouped = _groupByCurrency(_methods);
    final currenciesSorted = grouped.keys.toList()..sort();

    return ResponsiveSheet(
      padding: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          tokens.horizontalPadding,
          spacing * 2,
          tokens.horizontalPadding,
          spacing * 2 + bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: OpeiColors.iosSeparator.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: spacing * 1.5),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                  onPressed: () => Navigator.of(context).maybePop(),
                  padding: const EdgeInsets.all(8),
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Payment methods',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      fontFamily: '.SF Pro Display',
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: _handleAddMethod,
                  style: TextButton.styleFrom(
                    backgroundColor: OpeiColors.pureBlack,
                    foregroundColor: OpeiColors.pureWhite,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.add_rounded, size: 16),
                  label: const Text(
                    'Add',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Manage the accounts you accept for trades. Each method is tied to a single currency.',
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 11,
                color: OpeiColors.iosLabelSecondary,
              ),
            ),
            const SizedBox(height: 16),
            if (_isLoading && !_isRefreshing)
              Expanded(
                child: Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 1.6,
                    color: OpeiColors.pureBlack,
                  ),
                ),
              )
            else if (_errorMessage != null)
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF2F1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color:
                              const Color(0xFFFF3B30).withValues(alpha: 0.25),
                          width: 0.6),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Something went wrong',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _errorMessage!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: 13,
                            color: const Color(0xFFB3261E),
                            height: 1.45,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () => _loadMethods(asRefresh: true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: OpeiColors.pureBlack,
                            foregroundColor: OpeiColors.pureWhite,
                            padding: const EdgeInsets.symmetric(
                                vertical: 11, horizontal: 18),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text(
                            'Try again',
                            style: TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => _loadMethods(asRefresh: true),
                  color: OpeiColors.pureBlack,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics()),
                    children: [
                      if (_methods.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: OpeiColors.iosSurfaceMuted,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'No payment methods yet',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Add your first method to make it easier for buyers to pay you.',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontSize: 12,
                                  color: OpeiColors.iosLabelSecondary,
                                  height: 1.45,
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        ...currenciesSorted.map((currency) {
                          final items = grouped[currency] ??
                              const <P2PUserPaymentMethod>[];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 18),
                            child: _PaymentMethodCurrencySection(
                              currency: currency,
                              methods: items,
                              onEdit: _handleEditMethod,
                            ),
                          );
                        }),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PaymentMethodCurrencySection extends StatelessWidget {
  final String currency;
  final List<P2PUserPaymentMethod> methods;
  final ValueChanged<P2PUserPaymentMethod> onEdit;

  const _PaymentMethodCurrencySection({
    required this.currency,
    required this.methods,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              currency,
              style: theme.textTheme.titleSmall?.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: OpeiColors.iosSurfaceMuted,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '${methods.length}',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ...methods.map((method) => Padding(
              padding: EdgeInsets.only(bottom: method == methods.last ? 0 : 12),
              child: _PaymentMethodTile(
                method: method,
                onEdit: () => onEdit(method),
              ),
            )),
      ],
    );
  }
}

class _SelectAdPaymentMethodSheet extends StatefulWidget {
  final List<P2PAdPaymentMethod> methods;
  final String currency;
  final String title;
  final String subtitle;
  final String actionLabel;

  const _SelectAdPaymentMethodSheet({
    required this.methods,
    required this.currency,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
  });

  @override
  State<_SelectAdPaymentMethodSheet> createState() =>
      _SelectAdPaymentMethodSheetState();
}

class _SelectAdPaymentMethodSheetState
    extends State<_SelectAdPaymentMethodSheet> {
  String? _selectedId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final methods = widget.methods;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + bottom),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: OpeiColors.iosSeparator.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                fontFamily: '.SF Pro Display',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 12,
                color: OpeiColors.iosLabelSecondary,
              ),
            ),
            const SizedBox(height: 12),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  final m = methods[index];
                  final subtitle = '${m.methodType} · ${m.currency}';
                  final isSelected = _selectedId == m.id;
                  return Container(
                    decoration: BoxDecoration(
                      color: OpeiColors.pureWhite,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color:
                            OpeiColors.iosSeparator.withValues(alpha: 0.2),
                        width: 0.5,
                      ),
                    ),
                    child: ListTile(
                      onTap: () => setState(() => _selectedId = m.id),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      title: Text(
                        m.providerName,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      subtitle: Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 11,
                          color: OpeiColors.iosLabelSecondary,
                        ),
                      ),
                      trailing: Icon(
                        isSelected
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off,
                        color: isSelected
                            ? OpeiColors.pureBlack
                            : OpeiColors.iosLabelSecondary,
                      ),
                    ),
                  );
                },
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemCount: methods.length,
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedId == null
                    ? null
                    : () => Navigator.of(context).pop(_selectedId),
                style: ElevatedButton.styleFrom(
                  backgroundColor: OpeiColors.pureBlack,
                  foregroundColor: OpeiColors.pureWhite,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(widget.actionLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentMethodTile extends StatelessWidget {
  final P2PUserPaymentMethod method;
  final VoidCallback onEdit;

  const _PaymentMethodTile({required this.method, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accountLabel = method.accountNumber.trim().isNotEmpty
        ? method.accountNumber.trim()
        : (method.accountNumberMasked.trim().isNotEmpty
            ? method.accountNumberMasked.trim()
            : 'Account details unavailable');
    final addedLabel = method.createdAt != null
        ? DateFormat('MMM d, y').format(method.createdAt!.toLocal())
        : null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: OpeiColors.pureWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: OpeiColors.iosSeparator.withValues(alpha: 0.18), width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: OpeiColors.iosSurfaceMuted,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.account_balance_outlined,
                    size: 18, color: OpeiColors.pureBlack),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      method.providerName,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${method.methodType.toUpperCase()} · ${method.currency}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 11,
                        color: OpeiColors.iosLabelSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (method.isVerified)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE7F9EF),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.verified_rounded,
                          size: 14, color: Color(0xFF34C759)),
                      SizedBox(width: 4),
                      Text(
                        'Verified',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1F8A52)),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          _PaymentDetailRow(
            label: 'Account name',
            value: method.accountName,
            textTheme: theme.textTheme,
          ),
          const SizedBox(height: 6),
          _PaymentDetailRow(
            label: 'Account number',
            value: accountLabel,
            textTheme: theme.textTheme,
            isMonospace: true,
          ),
          if (method.extraDetails != null &&
              method.extraDetails!.isNotEmpty) ...[
            const SizedBox(height: 6),
            _PaymentDetailRow(
              label: 'Extra details',
              value: method.extraDetails!,
              textTheme: theme.textTheme,
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              if (addedLabel != null)
                Text(
                  'Added $addedLabel',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 11,
                    color: OpeiColors.iosLabelSecondary,
                  ),
                ),
              const Spacer(),
              TextButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined, size: 16),
                label: const Text('Edit'),
                style: TextButton.styleFrom(
                  foregroundColor: OpeiColors.pureBlack,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CurrencySelectorSheet extends StatefulWidget {
  const _CurrencySelectorSheet();

  @override
  State<_CurrencySelectorSheet> createState() => _CurrencySelectorSheetState();
}

class _CurrencySelectorSheetState extends State<_CurrencySelectorSheet> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final filtered = currencies
        .where((currency) =>
            currency.code.toLowerCase().contains(_search.toLowerCase()))
        .toList(growable: false);

    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, 16, 20, 20 + MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: OpeiColors.iosSeparator.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Select currency',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search_rounded, size: 18),
                hintText: 'Search currency',
                filled: true,
                fillColor: OpeiColors.iosSurfaceMuted,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                      color: OpeiColors.iosSeparator.withValues(alpha: 0.25),
                      width: 0.5),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                      color: OpeiColors.iosSeparator.withValues(alpha: 0.25),
                      width: 0.5),
                ),
              ),
              onChanged: (value) => setState(() => _search = value.trim()),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  final currency = filtered[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: OpeiColors.iosSurfaceMuted,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        currency.code,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                    title: Text(
                      currency.name,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    subtitle: Text(
                      currency.symbol,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontSize: 12,
                            color: OpeiColors.iosLabelSecondary,
                          ),
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded,
                        color: OpeiColors.iosLabelTertiary),
                    onTap: () => Navigator.of(context).pop(currency.code),
                  );
                },
                separatorBuilder: (_, __) => const SizedBox(height: 6),
                itemCount: filtered.length,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MyAdsFilterRow extends StatelessWidget {
  final MyP2PAdStatusFilter selectedFilter;
  final ValueChanged<MyP2PAdStatusFilter> onSelected;

  const _MyAdsFilterRow(
      {required this.selectedFilter, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final filter = MyP2PAdStatusFilter.values[index];
          final isSelected = filter == selectedFilter;
          return _MyAdsFilterChip(
            label: filter.displayLabel,
            isSelected: isSelected,
            onTap: () => onSelected(filter),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemCount: MyP2PAdStatusFilter.values.length,
      ),
    );
  }
}

class _OrdersFilterRow extends StatelessWidget {
  final P2POrderStatusFilter selectedFilter;
  final ValueChanged<P2POrderStatusFilter> onSelected;

  const _OrdersFilterRow(
      {required this.selectedFilter, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final filter = P2POrderStatusFilter.values[index];
          final isSelected = filter == selectedFilter;
          return _OrdersFilterChip(
            label: filter.displayLabel,
            isSelected: isSelected,
            onTap: () => onSelected(filter),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemCount: P2POrderStatusFilter.values.length,
      ),
    );
  }
}

class _OrdersFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _OrdersFilterChip(
      {required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final background =
        isSelected ? OpeiColors.pureBlack : OpeiColors.iosSurfaceMuted;
    final foreground = isSelected ? OpeiColors.pureWhite : OpeiColors.pureBlack;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? OpeiColors.pureBlack
                : OpeiColors.iosSeparator.withValues(alpha: 0.25),
            width: isSelected ? 1 : 0.5,
          ),
        ),
        child: Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: foreground,
            letterSpacing: -0.1,
          ),
        ),
      ),
    );
  }
}

class _RefreshDotsIndicator extends StatefulWidget {
  final double dotSize;
  final double gap;

  const _RefreshDotsIndicator({
    this.dotSize = 6,
    this.gap = 6,
  });

  @override
  State<_RefreshDotsIndicator> createState() => _RefreshDotsIndicatorState();
}

class _RefreshDotsIndicatorState extends State<_RefreshDotsIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            final progress = (_controller.value + index * 0.2) % 1.0;
            final normalized =
                (math.sin((progress * 2 * math.pi) - (math.pi / 2)) + 1) / 2;
            final scale = 0.6 + (0.4 * normalized);
            final opacity = 0.5 + (0.5 * normalized);

            return Padding(
              padding: EdgeInsets.only(left: index == 0 ? 0 : widget.gap),
              child: Opacity(
                opacity: opacity,
                child: Container(
                  width: widget.dotSize * scale,
                  height: widget.dotSize * scale,
                  decoration: BoxDecoration(
                    color: OpeiColors.pureBlack,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

class _LoadingShield extends StatelessWidget {
  final Widget child;
  final bool isBlocking;
  final bool showOverlay;

  const _LoadingShield({
    required this.child,
    required this.isBlocking,
    required this.showOverlay,
  });

  @override
  Widget build(BuildContext context) {
    if (!isBlocking && !showOverlay) {
      return child;
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        IgnorePointer(
          ignoring: isBlocking,
          child: child,
        ),
        if (showOverlay)
          const Positioned.fill(
            child: _CenteredLoadingDots(),
          ),
      ],
    );
  }
}

class _CenteredLoadingDots extends StatelessWidget {
  const _CenteredLoadingDots();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: true,
      child: Container(
        alignment: Alignment.center,
        color: OpeiColors.pureWhite.withValues(alpha: 0.04),
        child: const _RefreshDotsIndicator(
          dotSize: 8,
          gap: 8,
        ),
      ),
    );
  }
}

class _OrdersEmptyState extends StatelessWidget {
  final String? info;

  const _OrdersEmptyState({this.info});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Container(
          width: 82,
          height: 82,
          decoration: BoxDecoration(
            color: OpeiColors.iosSurfaceMuted,
            borderRadius: BorderRadius.circular(26),
          ),
          child: const Icon(Icons.receipt_long_outlined,
              size: 40, color: OpeiColors.pureBlack),
        ),
        const SizedBox(height: 20),
        Text(
          'No orders in this view',
          style: theme.textTheme.titleMedium?.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          info ?? 'Once you start trading, your activity will show here.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontSize: 13,
            color: OpeiColors.iosLabelSecondary,
          ),
        ),
      ],
    );
  }
}

class _OrdersErrorState extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;
  final String? title;

  const _OrdersErrorState(
      {required this.message, required this.onRetry, this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF2F1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: const Color(0xFFFF3B30).withValues(alpha: 0.25), width: 0.6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title ?? 'We couldn’t load your orders',
            style: theme.textTheme.titleMedium?.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: OpeiColors.pureBlack,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: 13,
              color: const Color(0xFFB3261E),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => onRetry(),
              style: ElevatedButton.styleFrom(
                backgroundColor: OpeiColors.pureBlack,
                foregroundColor: OpeiColors.pureWhite,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                'Try again',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderCard extends StatefulWidget {
  final P2PTrade trade;
  final bool? isBuyer;
  final bool canCancel;
  final bool isCancelling;
  final Future<void> Function()? onCancel;

  const _OrderCard({
    required this.trade,
    required this.isBuyer,
    this.canCancel = false,
    this.isCancelling = false,
    this.onCancel,
  });

  @override
  State<_OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<_OrderCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 90));
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _openDetails() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: OpeiColors.pureWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) =>
          _TradeDetailSheet(trade: widget.trade, isBuyer: widget.isBuyer),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final trade = widget.trade;
    final usdAmount = _formatUsdAmount(trade.amount);
    final rateLabel = trade.rate.format(includeCurrencySymbol: true);
    final Money? sendAmount = trade.sendAmount;
    final Money computedFallbackSend = _resolveSendFallback(
      trade: trade,
      sendAmount: sendAmount,
    );
    final Money effectiveSend = sendAmount ?? computedFallbackSend;
    final localAmountLabel = _formatLocalAmount(effectiveSend);
    final createdLabel = trade.createdAt != null
        ? DateFormat('d MMM, HH:mm').format(trade.createdAt!.toLocal())
        : '—';
    final expiresLabel = trade.expiresAt != null
        ? DateFormat('d MMM, HH:mm').format(trade.expiresAt!.toLocal())
        : null;
    final shortId = (trade.id.length <= 8 ? trade.id : trade.id.substring(0, 8))
        .toUpperCase();

    final method = trade.selectedPaymentMethod;
    final bool showRatingCta =
        widget.isBuyer != null && trade.shouldOfferRating;
    final String counterpartLabel = widget.isBuyer == true ? 'seller' : 'buyer';
    final bool showSellerReleaseShortcut =
        widget.isBuyer == false && trade.status == P2PTradeStatus.paidByBuyer;
    final String amountLabel = widget.isBuyer == true
        ? (trade.status == P2PTradeStatus.completed ? 'Sent' : 'Send')
        : (trade.status == P2PTradeStatus.completed
            ? 'Received'
            : "You'll receive");

    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        _openDetails();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: OpeiColors.pureWhite,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: OpeiColors.iosSeparator.withValues(alpha: 0.15),
                width: 0.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 6,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: widget.isBuyer == true ? 'Buy' : 'Sell',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.3,
                            color: widget.isBuyer == true
                                ? const Color(0xFF34C759)
                                : const Color(0xFFFF3B30),
                          ),
                        ),
                        TextSpan(
                          text: ' USD',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.3,
                            color: OpeiColors.pureBlack,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _OrderStatusPill(status: trade.status),
                ],
              ),
              const SizedBox(height: 12),
              _InfoRow(label: 'Amount', value: usdAmount),
              const SizedBox(height: 8),
              _InfoRow(label: 'Rate', value: '1 USD = $rateLabel'),
              const SizedBox(height: 8),
              _InfoRow(
                label: amountLabel,
                value: localAmountLabel,
              ),
              if (method != null) ...[
                const SizedBox(height: 8),
                _InfoRow(
                  label: 'Payment',
                  value: method.providerName,
                  trailing: () {
                    final accountNumber = method.accountNumber.isNotEmpty
                        ? method.accountNumber
                        : (method.accountNumberMasked ?? '');
                    if (accountNumber.isEmpty) return null;
                    return Text(
                      accountNumber,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 12,
                        color: OpeiColors.iosLabelTertiary,
                      ),
                    );
                  }(),
                ),
              ],
              const SizedBox(height: 10),
              Divider(
                  height: 1,
                  color: OpeiColors.iosSeparator.withValues(alpha: 0.25)),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'ID: $shortId',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 11,
                      color: OpeiColors.iosLabelSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    createdLabel,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 11,
                      color: OpeiColors.iosLabelTertiary,
                    ),
                  ),
                ],
              ),
              if (expiresLabel != null) ...[
                const SizedBox(height: 5),
                Text(
                  'Expires $expiresLabel',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 10,
                    color: OpeiColors.iosLabelTertiary,
                  ),
                ),
              ],
              if (widget.canCancel || showRatingCta) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (widget.canCancel)
                      Expanded(
                        child: OutlinedButton(
                          onPressed:
                              widget.isCancelling || widget.onCancel == null
                                  ? null
                                  : () async {
                                      await widget.onCancel!.call();
                                    },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: widget.isCancelling
                                ? OpeiColors.iosLabelSecondary
                                : const Color(0xFFD62E1F),
                            side: BorderSide(
                              color: widget.isCancelling
                                  ? OpeiColors.iosSeparator
                                      .withValues(alpha: 0.4)
                                  : const Color(0xFFD62E1F),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: widget.isCancelling
                              ? const SizedBox(
                                  height: 16,
                                  width: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 1.8,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Color(0xFFD62E1F)),
                                  ),
                                )
                              : Text(
                                  'Cancel trade',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    if (widget.canCancel && showRatingCta)
                      const SizedBox(width: 10),
                    if (showRatingCta)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _openDetails,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: OpeiColors.pureBlack,
                            side: BorderSide(
                                color: OpeiColors.iosSeparator
                                    .withValues(alpha: 0.35)),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text(
                            'Rate $counterpartLabel',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
              if (showSellerReleaseShortcut) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _openDetails,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: OpeiColors.pureBlack,
                      foregroundColor: OpeiColors.pureWhite,
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      'Confirm release',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: OpeiColors.pureWhite,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Widget? trailing;

  const _InfoRow({required this.label, required this.value, this.trailing});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontSize: 13,
            color: OpeiColors.iosLabelSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Flexible(
                child: Text(
                  value,
                  textAlign: TextAlign.right,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 13,
                    color: OpeiColors.pureBlack,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 4),
                trailing!,
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _OrderStatusPill extends StatelessWidget {
  final P2PTradeStatus status;

  const _OrderStatusPill({required this.status});

  @override
  Widget build(BuildContext context) {
    // Apple-style: subtle, mostly monochrome chips. No green.
    late Color background;
    late Color foreground;

    switch (status) {
      case P2PTradeStatus.initiated:
        // Shown as "Active"
        background = OpeiColors.iosSurfaceMuted;
        foreground = OpeiColors.pureBlack;
        break;
      case P2PTradeStatus.paidByBuyer:
        background = OpeiColors.iosSurfaceMuted;
        foreground = OpeiColors.iosLabelSecondary;
        break;
      case P2PTradeStatus.releasedBySeller:
        background = OpeiColors.iosSurfaceMuted;
        foreground = OpeiColors.iosLabelSecondary;
        break;
      case P2PTradeStatus.completed:
        // Avoid green, keep it neutral
        background = OpeiColors.iosSurfaceMuted;
        foreground = OpeiColors.pureBlack;
        break;
      case P2PTradeStatus.cancelled:
        background = const Color(0xFFFFF2F1);
        foreground = const Color(0xFFD62E1F);
        break;
      case P2PTradeStatus.disputed:
        background = const Color(0xFFFFF5E5);
        foreground = const Color(0xFFB37400);
        break;
      case P2PTradeStatus.expired:
        background = const Color(0xFFF2F2F7);
        foreground = OpeiColors.iosLabelSecondary;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
            color: OpeiColors.iosSeparator.withValues(alpha: 0.2), width: 0.5),
      ),
      child: Text(
        status.displayLabel,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: foreground,
              letterSpacing: -0.05,
            ),
      ),
    );
  }
}

class _MyAdsFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _MyAdsFilterChip(
      {required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final background =
        isSelected ? OpeiColors.pureBlack : OpeiColors.iosSurfaceMuted;
    final foreground = isSelected ? OpeiColors.pureWhite : OpeiColors.pureBlack;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? OpeiColors.pureBlack
                : OpeiColors.iosSeparator.withValues(alpha: 0.25),
            width: isSelected ? 1 : 0.5,
          ),
        ),
        child: Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: foreground,
            letterSpacing: -0.1,
          ),
        ),
      ),
    );
  }
}

class _TradeDetailSheet extends ConsumerStatefulWidget {
  final P2PTrade trade;
  final bool? isBuyer;

  const _TradeDetailSheet({required this.trade, required this.isBuyer});

  @override
  ConsumerState<_TradeDetailSheet> createState() => _TradeDetailSheetState();
}

class _TradeDetailSheetState extends ConsumerState<_TradeDetailSheet> {
  late P2PTrade _trade;
  bool _isDisputing = false;
  String? _disputeError;
  bool _disputeSuccess = false;
  late final TextEditingController _ratingCommentController;
  int _selectedRating = 0;
  bool _isRatingSubmitting = false;
  String? _ratingError;
  final Set<String> _selectedRatingTags = <String>{};
  static const int _maxProofImages = 3;
  static const int _maxProofBytes = 5 * 1024 * 1024;
  final List<PlatformFile> _pickedProofImages = [];
  late final TextEditingController _proofNoteController;
  bool _isProofSubmitting = false;
  bool _isProofPicking = false;
  String? _proofPickError;
  String? _proofSubmissionError;
  bool _proofSubmissionSuccess = false;
  bool _isReleaseSubmitting = false;

  @override
  void initState() {
    super.initState();
    _trade = widget.trade;
    final rating = _trade.yourRating;
    _selectedRating = rating?.score ?? 0;
    _ratingCommentController =
        TextEditingController(text: rating?.comment ?? '');
    _proofNoteController = TextEditingController();
    if (rating != null && rating.tags.isNotEmpty) {
      _selectedRatingTags.addAll(rating.tags.map((tag) => tag.toLowerCase()));
    }
  }

  @override
  void dispose() {
    _ratingCommentController.dispose();
    _proofNoteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ordersState = ref.watch(p2pOrdersControllerProvider);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final currentUserId = ref.watch(authSessionProvider).userId;
    final trade = _trade;
    final createdLabel = trade.createdAt != null
        ? DateFormat('d MMM yyyy, HH:mm').format(trade.createdAt!.toLocal())
        : null;
    final expiresLabel = trade.expiresAt != null
        ? DateFormat('d MMM yyyy, HH:mm').format(trade.expiresAt!.toLocal())
        : null;
    final paidLabel = trade.paidAt != null
        ? DateFormat('d MMM yyyy, HH:mm').format(trade.paidAt!.toLocal())
        : null;
    final releasedLabel = trade.releasedAt != null
        ? DateFormat('d MMM yyyy, HH:mm').format(trade.releasedAt!.toLocal())
        : null;
    final completedLabel = trade.completedAt != null
        ? DateFormat('d MMM yyyy, HH:mm').format(trade.completedAt!.toLocal())
        : null;

    final amountLabel = _formatUsdAmount(trade.amount);
    final rateLabel =
        '1 USD = ${trade.ad.rate.format(includeCurrencySymbol: true)}';
    final Money? sendAmount = trade.sendAmount;
    final Money fallbackSend =
        _resolveSendFallback(trade: trade, sendAmount: sendAmount);
    final Money effectiveSend = sendAmount ?? fallbackSend;
    final String sendLabel = _formatLocalAmount(effectiveSend);

    final method = trade.selectedPaymentMethod;
    final proofs = trade.proofs;
    final isBuyer = widget.isBuyer ?? false;
    final isSeller = widget.isBuyer == false;
    final showDisputeButton = _isTradeEligibleForDispute(trade.status);
    final alreadyDisputed = trade.status == P2PTradeStatus.disputed;
    final ratingSection = _buildRatingSection(trade, currentUserId);
    final canCancelTrade =
        _canCurrentUserCancelTrade(trade: trade, currentUserId: currentUserId);
    final isCancellingTrade = ordersState.isTradeCancelling(trade.id);
    final showBuyerSubmitProof =
        isBuyer && trade.status == P2PTradeStatus.initiated;
    final showSellerRelease =
        isSeller && trade.status == P2PTradeStatus.paidByBuyer;

    return Padding(
      padding: EdgeInsets.fromLTRB(18, 12, 18, 16 + bottomInset),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: OpeiColors.iosSeparator.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _OrderStatusPill(status: trade.status),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: OpeiColors.iosSurfaceMuted,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close_rounded,
                          size: 16, color: OpeiColors.pureBlack),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                amountLabel,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                '${trade.ad.typeLabel} USD · $rateLabel',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 11,
                  color: OpeiColors.iosLabelSecondary,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: OpeiColors.iosSurfaceMuted,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: OpeiColors.iosSeparator.withValues(alpha: 0.15),
                      width: 0.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (createdLabel != null)
                      _DetailRow(label: 'Created', value: createdLabel),
                    if (expiresLabel != null)
                      _DetailRow(label: 'Expires', value: expiresLabel),
                    if (paidLabel != null)
                      _DetailRow(label: 'Paid', value: paidLabel),
                    if (releasedLabel != null)
                      _DetailRow(label: 'Released', value: releasedLabel),
                    if (completedLabel != null)
                      _DetailRow(label: 'Completed', value: completedLabel),
                    if (trade.cancelledAt != null) ...[
                      _DetailRow(
                        label: 'Cancelled',
                        value: DateFormat('d MMM yyyy, HH:mm')
                            .format(trade.cancelledAt!.toLocal()),
                      ),
                      if ((trade.cancelReason ?? '').isNotEmpty)
                        _DetailRow(
                            label: 'Reason', value: trade.cancelReason ?? ''),
                    ],
                    _DetailRow(label: 'Order ID', value: trade.id),
                  ],
                ),
              ),
              if (canCancelTrade) ...[
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: isCancellingTrade ? null : _handleCancelTrade,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isCancellingTrade
                          ? OpeiColors.iosLabelSecondary
                          : const Color(0xFFD62E1F),
                      side: BorderSide(
                        color: isCancellingTrade
                            ? OpeiColors.iosSeparator.withValues(alpha: 0.4)
                            : const Color(0xFFD62E1F),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: isCancellingTrade
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 1.8,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFFD62E1F),
                              ),
                            ),
                          )
                        : const Text(
                            'Cancel trade',
                            style: TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                  ),
                ),
              ],
              if (method != null) ...[
                const SizedBox(height: 14),
                if (isBuyer) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: OpeiColors.pureWhite,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color:
                              OpeiColors.iosSeparator.withValues(alpha: 0.15),
                          width: 0.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Send this amount',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: OpeiColors.iosLabelSecondary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          sendLabel,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Transfer $sendLabel to the seller before marking payment as sent.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 11.5,
                            color: OpeiColors.iosLabelSecondary,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                Text(
                  isBuyer == true
                      ? 'Seller payment details'
                      : 'Buyer payment details',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: OpeiColors.iosLabelSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: OpeiColors.pureWhite,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: OpeiColors.iosSeparator.withValues(alpha: 0.15),
                        width: 0.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: OpeiColors.iosSurfaceMuted,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.account_balance_outlined,
                                size: 16, color: OpeiColors.pureBlack),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(method.providerName,
                                    style: theme.textTheme.titleSmall?.copyWith(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700)),
                                const SizedBox(height: 1),
                                Text(
                                    '${method.methodType} · ${method.currency}',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                        fontSize: 10,
                                        color: OpeiColors.iosLabelSecondary)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      if (method.accountName.isNotEmpty)
                        _PaymentDetailRow(
                            label: 'Account Name',
                            value: method.accountName,
                            textTheme: theme.textTheme),
                      if (method.accountNumber.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        _PaymentDetailRow(
                            label: 'Account Number',
                            value: method.accountNumber,
                            textTheme: theme.textTheme,
                            isMonospace: true),
                      ],
                      if ((method.extraDetails ?? '').isNotEmpty) ...[
                        const SizedBox(height: 8),
                        _PaymentDetailRow(
                            label: 'Additional Details',
                            value: method.extraDetails!,
                            textTheme: theme.textTheme),
                      ],
                    ],
                  ),
                ),
              ],
              if (proofs.isNotEmpty) ...[
                const SizedBox(height: 14),
                Text(
                  'Proofs submitted',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: OpeiColors.iosLabelSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: proofs
                      .where((p) => p.url.isNotEmpty)
                      .map((p) => _ProofNetworkThumb(url: p.url))
                      .toList(growable: false),
                ),
              ],
              if (_proofSubmissionError != null) ...[
                const SizedBox(height: 12),
                _MessageBanner(message: _proofSubmissionError!, isError: true),
              ],
              if (_proofSubmissionSuccess) ...[
                const SizedBox(height: 12),
                const _MessageBanner(
                  message:
                      'Payment marked as paid. Waiting for seller confirmation.',
                  isError: false,
                ),
              ],
              if (showBuyerSubmitProof) ...[
                const SizedBox(height: 14),
                _buildBuyerProofCallout(theme.textTheme),
              ],
              if (showSellerRelease) ...[
                const SizedBox(height: 14),
                _buildSellerReleaseCallout(theme.textTheme),
              ],
              if (ratingSection != null) ...[
                const SizedBox(height: 14),
                ratingSection,
              ],
              if (_disputeError != null) ...[
                const SizedBox(height: 12),
                _MessageBanner(message: _disputeError!, isError: true),
              ],
              if (_disputeSuccess) ...[
                const SizedBox(height: 12),
                const _MessageBanner(
                  message:
                      'Dispute opened. Our support team will review it shortly.',
                  isError: false,
                ),
              ],
              if (showDisputeButton) ...[
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: alreadyDisputed || _isDisputing
                        ? null
                        : _handleRaiseDispute,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: OpeiColors.pureBlack,
                      side: BorderSide(
                          color:
                              OpeiColors.iosSeparator.withValues(alpha: 0.35)),
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      alreadyDisputed ? 'Dispute opened' : 'Raise dispute',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget? _buildRatingSection(P2PTrade trade, String? currentUserId) {
    if (currentUserId == null || currentUserId.isEmpty) {
      return null;
    }

    final isParticipant =
        currentUserId == trade.buyerId || currentUserId == trade.sellerId;
    if (!isParticipant) {
      return null;
    }

    final hasRated = trade.hasUserRating;
    final shouldOffer = trade.shouldOfferRating;

    if (!hasRated && !shouldOffer) {
      return null;
    }

    final counterpartLabel =
        currentUserId == trade.buyerId ? 'seller' : 'buyer';

    if (hasRated && trade.yourRating != null) {
      return _buildRatingSummaryCard(trade.yourRating!, counterpartLabel);
    }

    return _buildRatingForm(counterpartLabel);
  }

  Widget _buildRatingSummaryCard(
      P2PTradeRating rating, String counterpartLabel) {
    final theme = Theme.of(context);
    final createdLabel = rating.createdAt != null
        ? DateFormat('d MMM yyyy, HH:mm').format(rating.createdAt!.toLocal())
        : null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: OpeiColors.iosSurfaceMuted,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: OpeiColors.iosSeparator.withValues(alpha: 0.15), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'You rated this $counterpartLabel',
            style: theme.textTheme.titleSmall?.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 10),
          _buildStaticStarRow(rating.score),
          if (rating.comment != null && rating.comment!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              rating.comment!,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ],
          if (rating.tags.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: rating.tags
                  .map((tag) =>
                      _buildTagPill(_formatRatingTag(tag), isActive: false))
                  .toList(growable: false),
            ),
          ],
          if (createdLabel != null) ...[
            const SizedBox(height: 8),
            Text(
              'Submitted $createdLabel',
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 10,
                color: OpeiColors.iosLabelTertiary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRatingForm(String counterpartLabel) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: OpeiColors.pureWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: OpeiColors.iosSeparator.withValues(alpha: 0.15), width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Rate the $counterpartLabel',
            style: textTheme.titleSmall?.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Your feedback helps keep trades safe and respectful.',
            style: textTheme.bodySmall?.copyWith(
              fontSize: 11,
              color: OpeiColors.iosLabelSecondary,
            ),
          ),
          const SizedBox(height: 12),
          _buildInteractiveStarsRow(),
          const SizedBox(height: 10),
          Text(
            'Optional comment',
            style: textTheme.bodySmall?.copyWith(
              fontSize: 11,
              color: OpeiColors.iosLabelSecondary,
            ),
          ),
          const SizedBox(height: 5),
          TextField(
            controller: _ratingCommentController,
            maxLines: 2,
            minLines: 2,
            textCapitalization: TextCapitalization.sentences,
            inputFormatters: [LengthLimitingTextInputFormatter(500)],
            onChanged: (_) {
              if (_ratingError != null) {
                setState(() => _ratingError = null);
              }
            },
            decoration: InputDecoration(
              hintText: 'Share a short note (≤500 chars)',
              hintStyle: TextStyle(fontSize: 12),
              filled: true,
              fillColor: OpeiColors.iosSurfaceMuted,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                    color: OpeiColors.iosSeparator.withValues(alpha: 0.3),
                    width: 0.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                    color: OpeiColors.iosSeparator.withValues(alpha: 0.3),
                    width: 0.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                    const BorderSide(color: OpeiColors.pureBlack, width: 0.8),
              ),
            ),
            style: TextStyle(fontSize: 12),
          ),
          const SizedBox(height: 10),
          Text(
            'Tags (optional)',
            style: textTheme.bodySmall?.copyWith(
              fontSize: 11,
              color: OpeiColors.iosLabelSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _ratingTagSuggestions.map((tag) {
              final normalized = tag.toLowerCase();
              final isSelected = _selectedRatingTags.contains(normalized);
              return GestureDetector(
                onTap: () => _toggleRatingTag(normalized),
                child:
                    _buildTagPill(_formatRatingTag(tag), isActive: isSelected),
              );
            }).toList(growable: false),
          ),
          const SizedBox(height: 10),
          if (_ratingError != null) ...[
            Text(
              _ratingError!,
              style: textTheme.bodySmall?.copyWith(
                fontSize: 11,
                color: const Color(0xFFFF3B30),
              ),
            ),
            const SizedBox(height: 10),
          ],
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isRatingSubmitting ? null : _handleSubmitRating,
              style: ElevatedButton.styleFrom(
                backgroundColor: OpeiColors.pureBlack,
                foregroundColor: OpeiColors.pureWhite,
                padding: const EdgeInsets.symmetric(vertical: 11),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(
                _isRatingSubmitting ? 'Submitting…' : 'Submit rating',
                style: textTheme.bodyMedium?.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: OpeiColors.pureWhite,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBuyerProofCallout(TextTheme textTheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: OpeiColors.pureWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: OpeiColors.iosSeparator.withValues(alpha: 0.15), width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ready to confirm payment?',
            style: textTheme.titleSmall?.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Upload clear payment proof so the seller can release the funds.',
            style: textTheme.bodySmall?.copyWith(
              fontSize: 11,
              color: OpeiColors.iosLabelSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isProofSubmitting ? null : _openSubmitProofSheet,
              style: ElevatedButton.styleFrom(
                backgroundColor: OpeiColors.pureBlack,
                foregroundColor: OpeiColors.pureWhite,
                padding: const EdgeInsets.symmetric(vertical: 11),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: _isProofSubmitting
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 1.8,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(OpeiColors.pureWhite),
                      ),
                    )
                  : Text(
                      'I’ve Paid',
                      style: textTheme.bodyMedium?.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: OpeiColors.pureWhite,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSellerReleaseCallout(TextTheme textTheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: OpeiColors.iosSeparator.withValues(alpha: 0.15), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Buyer marked payment as sent',
            style: textTheme.titleSmall?.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Confirm the funds have arrived in your account, then release the funds to complete the trade.',
            style: textTheme.bodySmall?.copyWith(
              fontSize: 11,
              color: OpeiColors.iosLabelSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed:
                  _isReleaseSubmitting ? null : _promptReleaseConfirmation,
              style: ElevatedButton.styleFrom(
                backgroundColor: OpeiColors.pureBlack,
                foregroundColor: OpeiColors.pureWhite,
                padding: const EdgeInsets.symmetric(vertical: 11),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: _isReleaseSubmitting
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 1.8,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(OpeiColors.pureWhite),
                      ),
                    )
                  : Text(
                      'Confirm release',
                      style: textTheme.bodyMedium?.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: OpeiColors.pureWhite,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagPill(String label, {required bool isActive}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isActive ? OpeiColors.pureBlack : OpeiColors.iosSurfaceMuted,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive
              ? OpeiColors.pureBlack
              : OpeiColors.iosSeparator.withValues(alpha: 0.25),
          width: isActive ? 0.8 : 0.5,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: isActive ? OpeiColors.pureWhite : OpeiColors.pureBlack,
          letterSpacing: -0.1,
        ),
      ),
    );
  }

  void _openSubmitProofSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => _UploadProofSheet(
          onConfirm: () async {
            final submitFuture = _submitPaymentProof();
            setModalState(() {});
            await submitFuture;
            if (!mounted) return;
            setModalState(() {});
            if (_proofSubmissionSuccess) {
              final navigator = Navigator.of(context);
              navigator.pop();
              await _presentProofSubmittedScreen(context);
            }
          },
          onPickImages: () async {
            final pickFuture = _handlePickProofs();
            setModalState(() {});
            await pickFuture;
            if (!mounted) return;
            setModalState(() {});
          },
          pickedImages: _pickedProofImages,
          onRemoveImage: (index) {
            _handleRemoveProof(index);
            setModalState(() {});
          },
          noteController: _proofNoteController,
          isSubmitting: _isProofSubmitting,
          isPicking: _isProofPicking,
          pickError: _proofPickError,
          submissionError: _proofSubmissionError,
        ),
      ),
    );
  }

  Future<void> _submitPaymentProof() async {
    final currentTrade = _trade;
    if (currentTrade.status != P2PTradeStatus.initiated) {
      return;
    }
    if (_pickedProofImages.isEmpty) {
      setState(() {
        _proofPickError = 'Upload at least one proof first.';
        _proofSubmissionError = null;
        _proofSubmissionSuccess = false;
      });
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isProofSubmitting = true;
      _proofSubmissionError = null;
      _proofSubmissionSuccess = false;
    });

    try {
      final candidates = _prepareLocalProofs();
      final repository = ref.read(p2pRepositoryProvider);
      final plans = await repository.prepareTradeProofUploads(
        tradeId: currentTrade.id,
        files: candidates
            .map(
              (candidate) => P2PTradeProofUploadRequest(
                fileName: candidate.fileName,
                contentType: candidate.contentType,
              ),
            )
            .toList(growable: false),
      );

      if (plans.length != candidates.length) {
        throw ApiError(
            message: 'Couldn’t prepare proof uploads. Please try again.');
      }

      await _performProofUploads(candidates, plans);

      final proofUrls =
          plans.map((plan) => plan.fileUrl).toList(growable: false);
      final note = _proofNoteController.text.trim();

      final updatedTrade = await repository.markTradeAsPaid(
        tradeId: currentTrade.id,
        message: note.isEmpty ? null : note,
        proofUrls: proofUrls,
      );

      if (!mounted) return;

      setState(() {
        _trade = updatedTrade;
        _pickedProofImages.clear();
        _proofSubmissionSuccess = true;
        _proofPickError = null;
        _proofSubmissionError = null;
      });

      _proofNoteController.clear();
      unawaited(_refreshOrdersSilently());
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _proofSubmissionError = _mapProofSubmissionError(error);
      });
    } finally {
      if (mounted) {
        setState(() {
          _isProofSubmitting = false;
        });
      }
    }
  }

  Future<void> _handlePickProofs() async {
    setState(() {
      _proofPickError = null;
      _proofSubmissionError = null;
      _proofSubmissionSuccess = false;
    });

    final remainingSlots = _maxProofImages - _pickedProofImages.length;
    if (remainingSlots <= 0) {
      setState(() {
        _proofPickError = 'You can upload up to $_maxProofImages images.';
      });
      return;
    }

    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.image,
        withData: true,
      );
      if (result == null) {
        return;
      }
      setState(() {
        _isProofPicking = true;
      });

      final selected = result.files;
      final List<PlatformFile> accepted = [];
      int skippedLarge = 0;
      int skippedNoData = 0;

      for (final file in selected) {
        if (accepted.length >= remainingSlots) break;
        final size = file.size;
        final hasBytes = file.bytes != null && file.bytes!.isNotEmpty;
        if (size > _maxProofBytes) {
          skippedLarge++;
          continue;
        }
        if (!hasBytes) {
          skippedNoData++;
          continue;
        }
        accepted.add(file);
      }

      if (accepted.isEmpty && (skippedLarge > 0 || skippedNoData > 0)) {
        setState(() {
          _proofPickError = skippedLarge > 0
              ? 'Some images exceed 5 MB and were skipped.'
              : 'Couldn’t read selected files. Please try again.';
          _isProofPicking = false;
        });
        return;
      }

      setState(() {
        _pickedProofImages.addAll(accepted);
        if (skippedLarge > 0 || skippedNoData > 0) {
          _proofPickError = [
            if (skippedLarge > 0) 'Skipped $skippedLarge images over 5 MB',
            if (skippedNoData > 0) 'Skipped $skippedNoData unreadable files',
          ].join(' • ');
        } else {
          _proofPickError = null;
        }
      });
    } catch (_) {
      setState(() {
        _proofPickError = 'Couldn’t pick images. Please try again.';
      });
    } finally {
      if (mounted && _isProofPicking) {
        setState(() {
          _isProofPicking = false;
        });
      }
    }
  }

  void _handleRemoveProof(int index) {
    setState(() {
      _pickedProofImages.removeAt(index);
      _proofPickError = null;
      _proofSubmissionError = null;
      _proofSubmissionSuccess = false;
    });
  }

  List<_ProofUploadCandidate> _prepareLocalProofs() {
    final results = <_ProofUploadCandidate>[];

    for (var i = 0; i < _pickedProofImages.length; i++) {
      final file = _pickedProofImages[i];
      final bytes = file.bytes;
      if (bytes == null || bytes.isEmpty) {
        throw ApiError(
            message:
                'One of the selected images could not be read. Please re-upload.');
      }

      final extension = _resolvePreferredExtension(file);
      final fileName = '${_sanitizeFileStem(file.name, i)}.$extension';
      final contentType = _resolveContentTypeFromExtension(extension);

      results.add(
        _ProofUploadCandidate(
          fileName: fileName,
          contentType: contentType,
          bytes: bytes,
        ),
      );
    }

    return results;
  }

  String _sanitizeFileStem(String name, int index) {
    final raw = name.split('.').first;
    final normalized = raw.replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '_');
    final collapsed = normalized.replaceAll(RegExp(r'_+'), '_').trim();
    final base = collapsed.isEmpty ? 'proof' : collapsed;
    final truncated = base.length > 40 ? base.substring(0, 40) : base;
    return '${truncated}_${index + 1}';
  }

  String _resolvePreferredExtension(PlatformFile file) {
    final ext = (file.extension ?? '').toLowerCase();
    if (ext == 'png') {
      return 'png';
    }
    if (ext == 'jpeg' || ext == 'jpg') {
      return 'jpg';
    }
    if (ext == 'heic' || ext == 'heif') {
      return 'jpg';
    }
    final lower = file.name.toLowerCase();
    if (lower.endsWith('.png')) {
      return 'png';
    }
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) {
      return 'jpg';
    }
    return 'jpg';
  }

  String _resolveContentTypeFromExtension(String extension) {
    switch (extension) {
      case 'png':
        return 'image/png';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      default:
        return 'application/octet-stream';
    }
  }

  String _mapProofSubmissionError(Object error) {
    if (error is ApiError) {
      final status = error.statusCode ?? 0;
      final message = error.message;

      if (status == 400) {
        if (message.toLowerCase().contains('already marked')) {
          return 'You already confirmed payment for this trade.';
        }
        return message.isNotEmpty
            ? message
            : 'We couldn’t submit those proofs. Please check and try again.';
      }

      if (status == 401 || status == 403) {
        return 'Your session expired. Please sign in again.';
      }

      if (status == 413) {
        return 'Those images are too large. Please upload photos under 5 MB each.';
      }

      if (status >= 500) {
        return 'Server issue while submitting your proofs. Please try again in a moment.';
      }

      return message.isNotEmpty
          ? message
          : 'We couldn’t submit your proofs right now.';
    }

    if (error is DioException) {
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.connectionError) {
        return 'Network issue while uploading. Check your connection and retry.';
      }
      return 'Upload failed. Please try again.';
    }

    return 'Something went wrong while submitting your proofs. Please try again.';
  }

  Future<void> _promptReleaseConfirmation() async {
    if (_isReleaseSubmitting || _trade.status != P2PTradeStatus.paidByBuyer) {
      return;
    }

    final confirmed = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) {
            final theme = Theme.of(dialogContext);
            final textTheme = theme.textTheme;

            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: Text(
                'Confirm release',
                style: textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Do not release funds before receiving payment.',
                    style: textTheme.bodyMedium
                        ?.copyWith(height: 1.45, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Releasing funds without confirmed payment may cause irreversible loss. Opei is not responsible for losses resulting from releasing funds before payment is received.',
                    style: textTheme.bodySmall?.copyWith(
                      height: 1.5,
                      color: const Color(0xFFD62E1F),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: OpeiColors.pureBlack,
                    foregroundColor: OpeiColors.pureWhite,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('I understand'),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!mounted || !confirmed) {
      return;
    }

    await _handleReleaseTrade();
  }

  Future<void> _handleReleaseTrade() async {
    if (_isReleaseSubmitting || _trade.status != P2PTradeStatus.paidByBuyer) {
      return;
    }

    final repository = ref.read(p2pRepositoryProvider);
    final router = GoRouter.of(context);
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (mounted) {
      setState(() {
        _isReleaseSubmitting = true;
      });
    }

    try {
      final updated = await repository.releaseTrade(tradeId: _trade.id);
      await _refreshOrdersSilently();

      if (!mounted) {
        return;
      }

      setState(() {
        _trade = updated;
        _proofSubmissionSuccess = false;
        _isReleaseSubmitting = false;
      });

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop();
      router.push('/p2p/rate-trade', extra: updated);
    } catch (error, _) {
      messenger?.showSnackBar(
        SnackBar(content: Text(_mapReleaseError(error))),
      );

      if (mounted) {
        setState(() {
          _isReleaseSubmitting = false;
        });
      }
    }
  }

  String _mapReleaseError(Object error) {
    if (error is ApiError) {
      final status = error.statusCode ?? 0;
      final message = error.message.toLowerCase();

      if (status == 401) {
        return 'We couldn’t verify your session. Please sign in again.';
      }
      if (status == 403) {
        return 'Only the seller assigned to this trade can release the funds.';
      }
      if (status == 404) {
        return 'We couldn’t find this trade. It may have been closed already.';
      }
      if (status == 400) {
        if (message.contains('already released')) {
          return 'This trade has already been released.';
        }
        if (message.contains('not paid')) {
          return 'You can only release once the buyer marks payment as sent.';
        }
        return 'We couldn’t release this trade right now. Please try again.';
      }
      if (status >= 500) {
        return 'We’re having trouble releasing funds right now. Please try again soon.';
      }
      if (error.message.isNotEmpty) {
        return error.message;
      }
    }

    final fallback = error.toString().toLowerCase();
    if (fallback.contains('missing') && fallback.contains('x-user-id')) {
      return 'We couldn’t verify your session. Please sign in again.';
    }
    if (fallback.contains('unauthorized')) {
      return 'Please sign in again to continue.';
    }
    return 'We couldn’t release this trade right now. Please try again.';
  }

  Future<void> _refreshOrdersSilently() async {
    try {
      await ref.read(p2pOrdersControllerProvider.notifier).refresh();
    } catch (_) {
      // Ignore failures so the sheet stays responsive.
    }
  }

  Widget _buildStaticStarRow(int score) {
    return Row(
      children: List.generate(5, (index) {
        final isFilled = index < score;
        return Padding(
          padding: EdgeInsets.only(right: index == 4 ? 0 : 6),
          child: Icon(
            isFilled ? Icons.star_rounded : Icons.star_outline_rounded,
            size: 22,
            color: isFilled
                ? const Color(0xFFFFD60A)
                : OpeiColors.iosSeparator.withValues(alpha: 0.8),
          ),
        );
      }),
    );
  }

  Widget _buildInteractiveStarsRow() {
    return Row(
      children: List.generate(5, (index) {
        final starIndex = index + 1;
        final isFilled = starIndex <= _selectedRating;
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedRating = starIndex;
              _ratingError = null;
            });
          },
          child: Padding(
            padding: EdgeInsets.only(right: index == 4 ? 0 : 8),
            child: Icon(
              isFilled ? Icons.star_rounded : Icons.star_outline_rounded,
              size: 30,
              color: isFilled
                  ? const Color(0xFFFFD60A)
                  : OpeiColors.iosSeparator.withValues(alpha: 0.6),
            ),
          ),
        );
      }),
    );
  }

  void _toggleRatingTag(String tag) {
    setState(() {
      if (_selectedRatingTags.contains(tag)) {
        _selectedRatingTags.remove(tag);
        _ratingError = null;
      } else {
        if (_selectedRatingTags.length >= 5) {
          _ratingError = 'You can select up to 5 tags.';
        } else {
          _selectedRatingTags.add(tag);
          _ratingError = null;
        }
      }
    });
  }

  Future<void> _handleSubmitRating() async {
    if (_selectedRating <= 0) {
      setState(() {
        _ratingError = 'Select how many stars to give before submitting.';
      });
      return;
    }

    setState(() {
      _isRatingSubmitting = true;
      _ratingError = null;
    });

    try {
      final repository = ref.read(p2pRepositoryProvider);
      final rating = await repository.rateTrade(
        tradeId: _trade.id,
        score: _selectedRating,
        comment: _ratingCommentController.text.trim(),
        tags: _selectedRatingTags.toList(growable: false),
      );

      if (!mounted) return;

      setState(() {
        _trade = _trade.copyWith(
          yourRating: rating,
          canRate: false,
          ratingPending: false,
          isRatedByMe: true,
        );
        _selectedRating = rating.score;
        _selectedRatingTags
          ..clear()
          ..addAll(rating.tags.map((tag) => tag.toLowerCase()));
        _ratingError = null;
      });

      _ratingCommentController
        ..text = rating.comment ?? ''
        ..selection = TextSelection.collapsed(
            offset: _ratingCommentController.text.length);

      if (!mounted) return;
      final messenger = ScaffoldMessenger.maybeOf(context);
      messenger
          ?.showSnackBar(const SnackBar(content: Text('Thanks for rating!')));

      try {
        await ref.read(p2pOrdersControllerProvider.notifier).refresh();
      } catch (_) {
        // ignore refresh failures so the sheet stays responsive
      }
    } catch (error) {
      if (!mounted) return;
      setState(() {
        final friendly = _mapRatingError(error);
        _ratingError = friendly;
        if (!_trade.hasUserRating &&
            friendly.toLowerCase().contains('already')) {
          _trade = _trade.copyWith(
              canRate: false, ratingPending: false, isRatedByMe: true);
        }
      });
    } finally {
      if (mounted) {
        setState(() {
          _isRatingSubmitting = false;
        });
      }
    }
  }

  Future<void> _handleCancelTrade() async {
    final warningResult = await showP2PCancelTradeWarningDialog(context);
    if (warningResult != true) {
      return;
    }

    try {
      final controller = ref.read(p2pOrdersControllerProvider.notifier);
      final updated = await controller.cancelTrade(_trade);
      if (!mounted) return;

      setState(() {
        _trade = updated;
      });

      final messenger = ScaffoldMessenger.maybeOf(context);
      messenger
          ?.showSnackBar(const SnackBar(content: Text('Trade cancelled.')));
    } catch (error) {
      if (!mounted) return;
      final messenger = ScaffoldMessenger.maybeOf(context);
      final friendly = error is String
          ? error
          : 'We couldn’t cancel this trade. Please try again.';
      messenger?.showSnackBar(SnackBar(content: Text(friendly)));
    }
  }

  String _mapRatingError(Object error) {
    if (error is ApiError) {
      final status = error.statusCode ?? 0;
      final message = error.message.toLowerCase();

      if (status == 401) {
        return 'We couldn’t verify your session. Please sign in again.';
      }

      if (status == 403) {
        return 'You’re not part of this trade, so you can’t leave a rating.';
      }

      if (status == 404) {
        return 'We couldn’t find this trade. It might have been removed.';
      }

      if (status == 400) {
        if (message.contains('already') && message.contains('rated')) {
          return 'You already rated this trade.';
        }
        if (message.contains('profile')) {
          return 'Please create your profile before leaving a rating.';
        }
        if (message.contains('completed') || message.contains('not finished')) {
          return 'You can rate once the trade is marked as completed.';
        }
        return error.message.isEmpty
            ? 'We couldn’t submit your rating. Please try again.'
            : error.message;
      }

      if (status >= 500) {
        return 'We’re having trouble saving your rating right now. Please try again shortly.';
      }

      if (error.message.isNotEmpty) {
        return error.message;
      }
    }

    final fallback = error.toString().toLowerCase();
    if (fallback.contains('missing') && fallback.contains('x-user-id')) {
      return 'We couldn’t verify your session. Please sign in again.';
    }
    if (fallback.contains('unauthorized')) {
      return 'Please sign in again to continue.';
    }

    return 'We couldn’t submit your rating right now. Please try again.';
  }

  String _formatRatingTag(String tag) {
    if (tag.isEmpty) {
      return tag;
    }
    final lower = tag.toLowerCase();
    return lower[0].toUpperCase() + lower.substring(1);
  }

  Future<void> _handleRaiseDispute() async {
    final reason = await _promptDisputeReason(context);
    if (reason == null || reason.trim().isEmpty) {
      return;
    }

    setState(() {
      _isDisputing = true;
      _disputeError = null;
      _disputeSuccess = false;
    });

    try {
      final repository = ref.read(p2pRepositoryProvider);
      final updatedTrade = await repository.raiseTradeDispute(
        tradeId: _trade.id,
        reason: reason,
      );

      if (!mounted) return;

      setState(() {
        _trade = updatedTrade;
        _disputeSuccess = true;
        _disputeError = null;
      });

      try {
        await ref.read(p2pOrdersControllerProvider.notifier).refresh();
      } catch (_) {
        // ignore refresh failures to keep sheet responsive
      }

      if (!mounted) return;
      final messenger = ScaffoldMessenger.maybeOf(context);
      messenger?.showSnackBar(
        const SnackBar(
            content: Text('Dispute submitted. Support has been notified.')),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _disputeError = _mapDisputeError(error);
        _disputeSuccess = false;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isDisputing = false;
        });
      }
    }
  }
}

class _ProofNetworkThumb extends StatelessWidget {
  final String url;

  const _ProofNetworkThumb({required this.url});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (url.isEmpty) {
          debugPrint('🖼️ Proof tapped but URL is empty; ignoring.');
          return;
        }
        _showProofViewer(context, url);
      },
      child: Container(
        width: 88,
        height: 88,
        decoration: BoxDecoration(
          color: OpeiColors.iosSurfaceMuted,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: OpeiColors.iosSeparator.withValues(alpha: 0.3),
              width: 0.5),
        ),
        clipBehavior: Clip.antiAlias,
        child: Image.network(
          url,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            debugPrint('🖼️ Thumbnail failed to load: $error');
            return Center(
              child: Icon(Icons.broken_image_outlined,
                  color: OpeiColors.iosLabelTertiary, size: 28),
            );
          },
        ),
      ),
    );
  }
}

void _showProofViewer(BuildContext context, String url) {
  if (kIsWeb) {
    debugPrint('🖼️ Opening proof in new tab (web fallback due to CORS): $url');
    _openExternal(url);
    return;
  }

  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Close',
    transitionDuration: Duration.zero,
    pageBuilder: (ctx, animation, secondaryAnimation) {
      return SafeArea(
        child: GestureDetector(
          onTap: () => Navigator.of(ctx).pop(),
          child: Scaffold(
            backgroundColor: Colors.black.withValues(alpha: 0.95),
            body: Stack(
              children: [
                Center(
                  child: InteractiveViewer(
                    minScale: 0.8,
                    maxScale: 4,
                    child: Image.network(
                      url,
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        final expected = loadingProgress.expectedTotalBytes;
                        final loaded = loadingProgress.cumulativeBytesLoaded;
                        final value = expected != null && expected > 0
                            ? loaded / expected
                            : null;
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const CircularProgressIndicator(
                                color: Colors.white),
                            const SizedBox(height: 12),
                            if (value != null)
                              Text('${(value * 100).toStringAsFixed(0)}%',
                                  style: const TextStyle(color: Colors.white)),
                          ],
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        debugPrint('🖼️ Error loading proof image: $error');
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.broken_image_outlined,
                                color: Colors.white70, size: 40),
                            SizedBox(height: 8),
                            Text('Image unavailable',
                                style: TextStyle(color: Colors.white70)),
                          ],
                        );
                      },
                    ),
                  ),
                ),
                Positioned(
                  top: 16,
                  right: 16,
                  child: IconButton(
                    icon: const Icon(Icons.close_rounded,
                        color: Colors.white, size: 26),
                    tooltip: 'Close',
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
        child: child,
      );
    },
  );
}

// Launch external URL (works on all platforms; on web opens a new tab)
Future<void> _openExternal(String url) async {
  try {
    final uri = Uri.parse(url);
    // Defer import cost if not used on non-web platforms
    // ignore: avoid_dynamic_calls
    // The following import is at file top via conditional export in url_launcher
    // but we keep this helper isolated for clarity.
    // Using dynamic to avoid analyzer complaining before package is resolved at compile time.
    // This is safe here because url_launcher is now a dependency.
    // ignore: inference_failure_on_untyped_parameter
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (e) {
    debugPrint('🔗 Failed to open external URL: $e');
  }
}

bool _isTradeEligibleForDispute(P2PTradeStatus status) {
  switch (status) {
    case P2PTradeStatus.paidByBuyer:
    case P2PTradeStatus.releasedBySeller:
    case P2PTradeStatus.completed:
    case P2PTradeStatus.disputed:
      return true;
    default:
      return false;
  }
}

bool _canCurrentUserCancelTrade({
  required P2PTrade trade,
  required String? currentUserId,
}) {
  if (currentUserId == null || currentUserId.isEmpty) {
    return false;
  }

  if (trade.status != P2PTradeStatus.initiated) {
    return false;
  }

  return trade.buyerId == currentUserId;
}

Future<String?> _promptDisputeReason(BuildContext context) async {
  final result = await showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.35),
    builder: (sheetContext) {
      return const _DisputeReasonSheet();
    },
  );

  return result?.trim();
}

class _DisputeReasonSheet extends StatefulWidget {
  const _DisputeReasonSheet();

  @override
  State<_DisputeReasonSheet> createState() => _DisputeReasonSheetState();
}

class _DisputeReasonSheetState extends State<_DisputeReasonSheet> {
  late final TextEditingController _controller;
  String? _localError;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    final reason = _controller.text.trim();
    if (reason.length < 6) {
      setState(() {
        _localError = 'Give a short reason (at least 6 characters).';
      });
      return;
    }
    Navigator.of(context).pop(reason);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return SafeArea(
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: EdgeInsets.only(bottom: bottomInset),
        child: SingleChildScrollView(
          padding: EdgeInsets.zero,
          child: Container(
            decoration: const BoxDecoration(
              color: OpeiColors.pureWhite,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: OpeiColors.iosSeparator.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Raise a dispute',
                  style: textTheme.titleMedium?.copyWith(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    fontFamily: '.SF Pro Display',
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Tell us what went wrong so our support team can review it quickly.',
                  style: textTheme.bodySmall?.copyWith(
                    fontSize: 12,
                    color: OpeiColors.iosLabelSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _controller,
                  autofocus: true,
                  maxLines: 4,
                  minLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                  inputFormatters: [LengthLimitingTextInputFormatter(250)],
                  onChanged: (_) {
                    if (_localError != null) {
                      setState(() => _localError = null);
                    }
                  },
                  decoration: InputDecoration(
                    hintText: 'Seller never released after I sent funds',
                    filled: true,
                    fillColor: OpeiColors.iosSurfaceMuted,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                          color: OpeiColors.iosSeparator.withValues(alpha: 0.3),
                          width: 0.5),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                          color: OpeiColors.iosSeparator.withValues(alpha: 0.3),
                          width: 0.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: OpeiColors.pureBlack, width: 1),
                    ),
                  ),
                ),
                if (_localError != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _localError!,
                    style: textTheme.bodySmall?.copyWith(
                      fontSize: 12,
                      color: const Color(0xFFFF3B30),
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          foregroundColor: OpeiColors.iosLabelSecondary,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _handleSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: OpeiColors.pureBlack,
                          foregroundColor: OpeiColors.pureWhite,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Submit dispute'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _mapDisputeError(Object error) {
  if (error is ApiError) {
    final status = error.statusCode ?? 0;
    final message = error.message.trim();
    final normalized = message.toLowerCase();

    if (status == 401) {
      return 'We couldn’t verify your session. Please sign in again.';
    }

    if (status == 403 || status == 404) {
      return 'We couldn’t find this trade or you’re not a participant.';
    }

    if (status == 400) {
      if (normalized.contains('after payment')) {
        return 'You can only open a dispute after marking this trade as paid.';
      }
      if (normalized.contains('already in dispute') ||
          normalized.contains('already open')) {
        return 'This trade already has an open dispute.';
      }
      return message.isEmpty
          ? 'We couldn’t open a dispute for this trade. Please try again.'
          : message;
    }

    if (status >= 500) {
      return 'We’re having trouble opening a dispute right now. Please try again shortly.';
    }

    if (message.isNotEmpty) {
      return message;
    }
  }

  final fallback = error.toString().toLowerCase();
  if (fallback.contains('missing') && fallback.contains('x-user-id')) {
    return 'We couldn’t verify your session. Please sign in again.';
  }
  if (fallback.contains('unauthorized')) {
    return 'Please sign in again to continue.';
  }

  return 'We couldn’t open a dispute right now. Please try again.';
}

class _MyAdsEmptyState extends StatelessWidget {
  final VoidCallback onCreateAd;
  final bool isLoading;

  const _MyAdsEmptyState({required this.onCreateAd, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 82,
          height: 82,
          decoration: BoxDecoration(
            color: OpeiColors.iosSurfaceMuted,
            borderRadius: BorderRadius.circular(26),
          ),
          child: const Icon(Icons.campaign_outlined,
              size: 40, color: OpeiColors.pureBlack),
        ),
        const SizedBox(height: 20),
        Text(
          'No ads just yet',
          style: theme.textTheme.titleMedium?.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Launch your first buy or sell ad to start trading directly with other users.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontSize: 13,
            color: OpeiColors.iosLabelSecondary,
          ),
        ),
        const SizedBox(height: 24),
        _CreateAdButton(
          onTap: onCreateAd,
          isLoading: isLoading,
        ),
      ],
    );
  }
}

class _MyAdCard extends StatelessWidget {
  final P2PAd ad;
  final VoidCallback onTap;

  const _MyAdCard({
    required this.ad,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final typeLabel = ad.type.displayLabel;
    final actionLabel =
        ad.type == P2PAdType.sell ? 'Selling USD' : 'Buying USD';
    final remaining = _formatUsdAmount(ad.remainingAmount);
    final rateLabel = '1 USD = ${_formatMoneyWithCode(ad.rate)}';
    final createdAt = ad.updatedAt ?? ad.createdAt;
    final createdLabel = createdAt != null
        ? DateFormat('d MMM').format(createdAt.toLocal())
        : null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: OpeiColors.pureWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: OpeiColors.iosSeparator.withValues(alpha: 0.2),
              width: 0.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _MyAdTypeBadge(typeLabel: typeLabel),
                const SizedBox(width: 7),
                _MyAdStatusBadge(status: ad.statusLabel, rawStatus: ad.status),
                const Spacer(),
                if (createdLabel != null)
                  Text(
                    createdLabel,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: OpeiColors.iosLabelSecondary,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              actionLabel,
              style: theme.textTheme.titleMedium?.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _MyAdMetricCompact(
                    label: 'Remaining',
                    value: remaining,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _MyAdMetricCompact(
                    label: 'Rate',
                    value: rateLabel,
                  ),
                ),
              ],
            ),
            if (ad.paymentMethods.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: ad.paymentMethods
                    .map(
                      (method) => _MyAdPaymentPill(label: method.displayLabel),
                    )
                    .toList(growable: false),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MyAdTypeBadge extends StatelessWidget {
  final String typeLabel;

  const _MyAdTypeBadge({required this.typeLabel});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        color: OpeiColors.pureBlack,
      ),
      child: Text(
        typeLabel,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
              color: OpeiColors.pureWhite,
            ),
      ),
    );
  }
}

class _DeactivateAdButton extends StatelessWidget {
  final bool isBusy;
  final bool isEnabled;
  final VoidCallback onPressed;

  const _DeactivateAdButton({
    required this.isBusy,
    required this.isEnabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final background =
        isEnabled ? const Color(0xFFFFEBE9) : OpeiColors.iosSurfaceMuted;
    final foreground =
        isEnabled ? const Color(0xFFD62E1F) : OpeiColors.iosLabelSecondary;
    final interactive = isEnabled && !isBusy;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 160),
      child: SizedBox(
        key: ValueKey(
            '${isBusy ? 'busy' : interactive ? 'enabled' : 'disabled'}-$isEnabled'),
        height: 44,
        width: double.infinity,
        child: Material(
          color: background,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: interactive ? onPressed : null,
            child: Center(
              child: isBusy
                  ? SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 1.8,
                        valueColor: AlwaysStoppedAnimation<Color>(foreground),
                      ),
                    )
                  : Text(
                      'Deactivate ad',
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: foreground,
                        letterSpacing: -0.1,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MyAdStatusBadge extends StatelessWidget {
  final String status;
  final String rawStatus;

  const _MyAdStatusBadge({required this.status, required this.rawStatus});

  @override
  Widget build(BuildContext context) {
    final normalized = rawStatus.trim().toUpperCase();
    Color background;
    Color foreground;

    switch (normalized) {
      case 'ACTIVE':
        background = const Color(0xFFE8FCEB);
        foreground = const Color(0xFF1C9A48);
        break;
      case 'PENDING_REVIEW':
        background = const Color(0xFFFFF5E5);
        foreground = const Color(0xFFB37400);
        break;
      case 'INACTIVE':
        background = const Color(0xFFF2F2F7);
        foreground = OpeiColors.iosLabelSecondary;
        break;
      case 'COMPLETED':
        background = const Color(0xFFE6F1FF);
        foreground = const Color(0xFF1560B9);
        break;
      case 'REJECTED':
        background = const Color(0xFFFFEDEA);
        foreground = const Color(0xFFD62E1F);
        break;
      default:
        background = OpeiColors.iosSurfaceMuted;
        foreground = OpeiColors.iosLabelSecondary;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: foreground,
              letterSpacing: -0.1,
            ),
      ),
    );
  }
}

class _MyAdMetricCompact extends StatelessWidget {
  final String label;
  final String value;

  const _MyAdMetricCompact({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: OpeiColors.iosLabelSecondary,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }
}

class _MyAdPaymentPill extends StatelessWidget {
  final String label;

  const _MyAdPaymentPill({required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: OpeiColors.iosSurfaceMuted,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: OpeiColors.iosSeparator.withValues(alpha: 0.2), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.account_balance_wallet_outlined,
              size: 10, color: OpeiColors.pureBlack),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: OpeiColors.pureBlack,
            ),
          ),
        ],
      ),
    );
  }
}

class _MyAdDetailSheet extends ConsumerWidget {
  final P2PAd ad;

  const _MyAdDetailSheet({required this.ad});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final myAdsState = ref.watch(myP2PAdsControllerProvider);
    final controller = ref.read(myP2PAdsControllerProvider.notifier);
    final latest = myAdsState.ads.firstWhere(
      (element) => element.id == ad.id,
      orElse: () => ad,
    );

    final isSelling = latest.type == P2PAdType.sell;
    final actionLabel = isSelling ? 'Selling USD' : 'Buying USD';
    final remaining = _formatUsdAmount(latest.remainingAmount);
    final total = _formatUsdAmount(latest.totalAmount);
    final rate = '1 USD = ${_formatMoneyWithCode(latest.rate)}';
    final min = _formatUsdAmount(latest.minOrder);
    final max = _formatUsdAmount(latest.maxOrder);
    final normalizedStatus = latest.status.trim().toUpperCase();
    final canDeactivate =
        normalizedStatus == 'ACTIVE' || normalizedStatus == 'PENDING_REVIEW';
    final isBusy = myAdsState.isAdDeactivating(latest.id);

    Future<void> handleDeactivate() async {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: OpeiColors.pureWhite,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Deactivate Ad',
            style: theme.textTheme.titleMedium?.copyWith(
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            'This ad will no longer be visible to traders. You can reactivate it later if needed.',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: 13,
              color: OpeiColors.iosLabelSecondary,
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              style: TextButton.styleFrom(
                foregroundColor: OpeiColors.pureBlack,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              child: const Text('Cancel',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFD62E1F),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              child: const Text('Deactivate',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      );

      if (confirmed != true) return;

      try {
        final message = await controller.deactivateAd(latest.id);
        if (!context.mounted) {
          return;
        }
        ScaffoldMessenger.maybeOf(context)
            ?.showSnackBar(SnackBar(content: Text(message)));
        Navigator.of(context).pop();
      } catch (error) {
        if (!context.mounted) {
          return;
        }
        final friendly = error is String
            ? error
            : 'We couldn\'t deactivate this ad. Please try again.';
        ScaffoldMessenger.maybeOf(context)
            ?.showSnackBar(SnackBar(content: Text(friendly)));
      }
    }

    return Container(
      decoration: const BoxDecoration(
        color: OpeiColors.pureWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: OpeiColors.iosSeparator.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                children: [
                  _MyAdTypeBadge(typeLabel: latest.type.displayLabel),
                  const SizedBox(width: 8),
                  _MyAdStatusBadge(
                      status: latest.statusLabel, rawStatus: latest.status),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: OpeiColors.iosSurfaceMuted,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close,
                          size: 18, color: OpeiColors.pureBlack),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                actionLabel,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 20),
              _MyAdDetailRow(label: 'Remaining', value: remaining),
              const SizedBox(height: 12),
              _MyAdDetailRow(label: 'Total amount', value: total),
              const SizedBox(height: 12),
              _MyAdDetailRow(label: 'Rate', value: rate),
              const SizedBox(height: 12),
              _MyAdDetailRow(label: 'Min order', value: min),
              const SizedBox(height: 12),
              _MyAdDetailRow(label: 'Max order', value: max),
              if (latest.paymentMethods.isNotEmpty) ...[
                const SizedBox(height: 20),
                Text(
                  'Payment methods',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: OpeiColors.iosLabelSecondary,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: latest.paymentMethods
                      .map(
                        (method) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: OpeiColors.iosSurfaceMuted,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: OpeiColors.iosSeparator
                                  .withValues(alpha: 0.2),
                              width: 0.5,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.account_balance_wallet_outlined,
                                size: 14,
                                color: OpeiColors.pureBlack,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                method.displayLabel,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(growable: false),
                ),
              ],
              if (latest.instructions.isNotEmpty) ...[
                const SizedBox(height: 20),
                Text(
                  'Instructions',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: OpeiColors.iosLabelSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: OpeiColors.iosSurfaceMuted.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    latest.instructions,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
              if (canDeactivate) ...[
                const SizedBox(height: 24),
                _DeactivateAdButton(
                  isBusy: isBusy,
                  isEnabled: canDeactivate,
                  onPressed: handleDeactivate,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _MyAdDetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _MyAdDetailRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: OpeiColors.iosLabelSecondary,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _CreateAdFlowSheet extends ConsumerStatefulWidget {
  final String initialCurrency;
  final Future<void> Function() onCreated;

  const _CreateAdFlowSheet(
      {required this.initialCurrency, required this.onCreated});

  @override
  ConsumerState<_CreateAdFlowSheet> createState() => _CreateAdFlowSheetState();
}

String _formatCreateAdError(Object error, {required P2PAdType adType}) {
  int? statusCode;
  String rawMessage = error.toString().trim();
  Map<String, dynamic>? fieldErrors;

  if (error is ApiError) {
    statusCode = error.statusCode;
    final trimmed = error.message.trim();
    if (trimmed.isNotEmpty) {
      rawMessage = trimmed;
    }
    fieldErrors = error.errors;

    if ((rawMessage.isEmpty || rawMessage == 'null') &&
        fieldErrors != null &&
        fieldErrors.isNotEmpty) {
      final firstValue = fieldErrors.values.first;
      if (firstValue is String && firstValue.trim().isNotEmpty) {
        rawMessage = firstValue.trim();
      } else if (firstValue is List && firstValue.isNotEmpty) {
        final candidate = firstValue.first.toString().trim();
        if (candidate.isNotEmpty) {
          rawMessage = candidate;
        }
      }
    }
  }

  final normalized = rawMessage.toLowerCase();
  final isSellAd = adType == P2PAdType.sell;

  if (statusCode == 401 || normalized.contains('missing x-user-id')) {
    return 'Please sign in again.';
  }

  if (statusCode == 403) {
    return 'You don’t have permission to publish this ad.';
  }

  if (statusCode == 404 || normalized.contains('not found')) {
    return isSellAd
        ? 'One of the selected payment methods is no longer available. Refresh and try again.'
        : 'This ad is no longer available. Refresh and try again.';
  }

  if (normalized.contains('sell') &&
      normalized.contains('without userpaymentmethodids')) {
    return 'Add at least one payment method.';
  }

  if (normalized.contains('attach at least one payment method')) {
    return 'Add at least one payment method.';
  }

  if (normalized.contains('must not include userpaymentmethodids')) {
    return 'Payment methods aren’t needed for buy ads.';
  }

  if (normalized.contains('only attach up to 5 payment methods')) {
    return 'You can attach up to five payment methods.';
  }

  if (normalized.contains('duplicate')) {
    return 'Remove duplicate payment methods before submitting.';
  }

  if (normalized.contains('payment provider') &&
      normalized.contains('inactive')) {
    return 'One of the payment providers is inactive right now. Please choose another option.';
  }

  if (normalized.contains('currency does not match')) {
    return 'Payment method currency must match your ad currency.';
  }

  if (normalized.contains('don’t belong to user') ||
      normalized.contains('dont belong to user')) {
    return 'Selected payment methods belong to another account.';
  }

  if (normalized.contains('selected payment methods') &&
      normalized.contains('invalid')) {
    return 'Selected payment methods are invalid for this ad.';
  }

  if (normalized.contains('greater than available')) {
    return 'Your sell total exceeds your available balance.';
  }

  if (normalized.contains('insufficient available balance') ||
      (normalized.contains('insufficient') && normalized.contains('balance'))) {
    return 'You don’t have enough balance to publish this ${isSellAd ? 'sell' : 'buy'} ad.';
  }

  if (normalized.contains('must be a valid integer')) {
    return 'Use whole numbers when entering amounts.';
  }

  if (normalized.contains('not numeric') ||
      normalized.contains('not ordered')) {
    return 'Please review your amounts and limits.';
  }

  if (normalized.contains(
      'totalamountcents must be greater than or equal to minordercents')) {
    return 'Total amount must be at least your minimum order.';
  }

  if (normalized.contains(
      'maxordercents must be greater than or equal to minordercents')) {
    return 'Max order must be greater than or equal to the minimum order.';
  }

  if (normalized.contains('ratecents') && normalized.contains('> 0')) {
    return 'Enter a valid price rate.';
  }

  if (normalized.contains('instructions') && normalized.contains('500')) {
    return 'Instructions are too long (max 500 characters).';
  }

  if (statusCode != null && statusCode >= 500) {
    return 'Server error. Please try again shortly.';
  }

  if (rawMessage.isNotEmpty &&
      statusCode != null &&
      statusCode >= 400 &&
      statusCode < 500) {
    return rawMessage;
  }

  if (normalized.contains('internal') || normalized.contains('server')) {
    return 'Server error. Please try again shortly.';
  }

  if (normalized.contains('timeout')) {
    return 'Request timed out. Please try again.';
  }

  return 'Failed to create ad. Check your input and try again.';
}

class _CreateAdFlowSheetState extends ConsumerState<_CreateAdFlowSheet> {
  int _step = 0; // 0: choose type, 1+: depends on type
  P2PAdType? _selectedType;
  late String _currency;

  late final TextEditingController _totalAmount;
  late final TextEditingController _minOrder;
  late final TextEditingController _maxOrder;
  late final TextEditingController _rate;
  late final TextEditingController _instructions;

  late final FocusNode _totalFocus;
  late final FocusNode _priceFocus;
  late final FocusNode _minFocus;
  late final FocusNode _maxFocus;
  late final FocusScopeNode _formFocusScope;

  List<P2PUserPaymentMethod> _methods = const [];
  final Set<String> _selectedMethodIds = <String>{};
  bool _loadingMethods = false;
  String? _methodsCurrency;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _currency = widget.initialCurrency;
    _totalAmount = TextEditingController();
    _minOrder = TextEditingController();
    _maxOrder = TextEditingController();
    _rate = TextEditingController();
    _instructions = TextEditingController();
    _totalFocus = FocusNode();
    _priceFocus = FocusNode();
    _minFocus = FocusNode();
    _maxFocus = FocusNode();
    _formFocusScope = FocusScopeNode(debugLabel: 'createAdForm');
  }

  @override
  void dispose() {
    _totalAmount.dispose();
    _minOrder.dispose();
    _maxOrder.dispose();
    _rate.dispose();
    _instructions.dispose();
    _totalFocus.dispose();
    _priceFocus.dispose();
    _minFocus.dispose();
    _maxFocus.dispose();
    _formFocusScope.dispose();
    super.dispose();
  }

  void _selectType(P2PAdType type) => setState(() {
        _selectedType = type;
        _step = 1;
        _methods = const [];
        _selectedMethodIds.clear();
        _methodsCurrency = null;
        _errorMessage = null;
      });

  void _goToStep(int next) {
    if (_selectedType == null) return;
    const maxStep = 3;
    final target = next.clamp(0, maxStep);
    setState(() => _step = target);
    if (target == 2) {
      _ensureMethodsLoaded();
    }
  }

  void _ensureMethodsLoaded() {
    if (_loadingMethods) {
      return;
    }

    final currency = _currency.toUpperCase();
    if (_methodsCurrency != currency) {
      _selectedMethodIds.clear();
      unawaited(_loadUserMethods(currency: currency));
      return;
    }

    if (_methods.isEmpty) {
      unawaited(_loadUserMethods(currency: currency));
    }
  }

  Future<void> _loadUserMethods({required String currency}) async {
    if (!mounted) return;
    setState(() => _loadingMethods = true);

    try {
      final repo = ref.read(p2pRepositoryProvider);
      final methods = await repo.fetchUserPaymentMethods(currency: currency);
      if (!mounted) return;
      if (_currency.toUpperCase() != currency) {
        return;
      }
      setState(() {
        _methodsCurrency = currency;
        _methods = methods;
      });
    } catch (e) {
      debugPrint('❌ Failed to load payment methods: $e');
      if (!mounted) return;
      if (_currency.toUpperCase() != currency) {
        return;
      }
      setState(() {
        _methods = const [];
      });
    } finally {
      if (mounted && _currency.toUpperCase() == currency) {
        setState(() => _loadingMethods = false);
      }
    }
  }

  Future<void> _handleAddPaymentMethod() async {
    final created = await showModalBottomSheet<P2PUserPaymentMethod>(
      context: context,
      isScrollControlled: true,
      backgroundColor: OpeiColors.pureWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _AddPaymentMethodSheet(currency: _currency),
    );

    if (!mounted || created == null) {
      return;
    }

    await _loadUserMethods(currency: _currency.toUpperCase());
    if (!mounted) {
      return;
    }

    setState(() {
      if (_selectedMethodIds.length < 5) {
        _selectedMethodIds.add(created.id);
        if (_errorMessage != null &&
            _errorMessage!.toLowerCase().contains('payment method')) {
          _errorMessage = null;
        }
      }
    });
  }

  int? _toCents(String text) {
    final sanitized = text.replaceAll(',', '').trim();
    if (sanitized.isEmpty) return null;
    final parsed = double.tryParse(sanitized);
    if (parsed == null) return null;
    final cents = (parsed * 100).round();
    return cents <= 0 ? null : cents;
  }

  String _mapCreateAdError(Object error) {
    final adType = _selectedType ?? P2PAdType.sell;
    return _formatCreateAdError(error, adType: adType);
  }

  Future<void> _submit() async {
    if (_isSubmitting || _selectedType == null) return;
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final total = _toCents(_totalAmount.text) ?? 0;
    final min = _toCents(_minOrder.text) ?? 0;
    final max = _toCents(_maxOrder.text) ?? 0;
    final rate = _toCents(_rate.text) ?? 0;

    if (_selectedMethodIds.isEmpty) {
      setState(() {
        _isSubmitting = false;
        _errorMessage = 'Select at least one payment method.';
      });
      return;
    }
    if (!(total > 0 && rate > 0 && min > 0 && max >= min)) {
      setState(() {
        _isSubmitting = false;
        _errorMessage = 'Enter valid amounts, limits and price.';
      });
      return;
    }

    try {
      final repo = ref.read(p2pRepositoryProvider);
      await repo.createAd(
        type: _selectedType!,
        currency: _currency,
        totalAmountCents: total,
        minOrderCents: min,
        maxOrderCents: max,
        rateCents: rate,
        instructions: _instructions.text.trim().isEmpty
            ? null
            : _instructions.text.trim(),
        userPaymentMethodIds: _selectedMethodIds.toList(growable: false),
      );
      if (!mounted) return;
      Navigator.of(context).pop();
      await widget.onCreated();
    } catch (e) {
      debugPrint('❌ Create ad failed: $e');
      if (!mounted) return;
      setState(() => _errorMessage = _mapCreateAdError(e));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _showCurrencyPicker() async {
    final selected = await showModalBottomSheet<Currency>(
      context: context,
      backgroundColor: OpeiColors.pureWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _CurrencyPickerSheet(selectedCode: _currency),
    );
    if (selected != null && mounted) {
      setState(() {
        _currency = selected.code;
        _selectedMethodIds.clear();
        _methods = const [];
        _methodsCurrency = null;
      });
      if (_step == 2) {
        _ensureMethodsLoaded();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    if (_step == 0) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('Create P2P Ad',
                      style: theme.textTheme.titleMedium?.copyWith(
                          fontSize: 17, fontWeight: FontWeight.w700)),
                  const Spacer(),
                  IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded, size: 20)),
                ],
              ),
              const SizedBox(height: 8),
              Text('Choose ad type',
                  style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 13, color: OpeiColors.iosLabelSecondary)),
              const SizedBox(height: 18),
              _CreateAdOptionTile(
                icon: Icons.shopping_cart_checkout,
                title: 'Sell USD',
                subtitle: 'Receive fiat or mobile money.',
                onTap: () => _selectType(P2PAdType.sell),
              ),
              const SizedBox(height: 12),
              _CreateAdOptionTile(
                icon: Icons.attach_money_rounded,
                title: 'Buy USD',
                subtitle: 'Specify how you will pay sellers.',
                onTap: () => _selectType(P2PAdType.buy),
              ),
            ],
          ),
        ),
      );
    }

    // Multi-step form for sell or buy
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomInset),
      child: FocusScope(
        node: _formFocusScope,
        child: FocusTraversalGroup(
          policy: OrderedTraversalPolicy(),
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: OpeiColors.iosSeparator.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Text(
                      _selectedType == P2PAdType.sell
                          ? 'Create SELL ad'
                          : 'Create BUY ad',
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontSize: 17, fontWeight: FontWeight.w700),
                    ),
                    const Spacer(),
                    if (_selectedType != null && _step >= 1)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: OpeiColors.iosSurfaceMuted,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                              color: OpeiColors.iosSeparator
                                  .withValues(alpha: 0.3),
                              width: 0.5),
                        ),
                        child: Text(
                          'Step $_step of 3',
                          style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: OpeiColors.iosLabelSecondary),
                        ),
                      ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        foregroundColor: OpeiColors.iosLabelSecondary,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  _selectedType == P2PAdType.sell
                      ? (_step == 1
                          ? 'Select payout currency'
                          : _step == 2
                              ? 'Choose payment methods'
                              : 'Set amount and price')
                      : (_step == 1
                          ? 'Select payment currency'
                          : _step == 2
                              ? 'Choose payment methods'
                              : 'Set amount and price'),
                  style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 12, color: OpeiColors.iosLabelSecondary),
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 12),
                  _MessageBanner(message: _errorMessage!, isError: true),
                ],
                const SizedBox(height: 14),
                _buildStepContent(context, theme),
                const SizedBox(height: 18),
                Row(
                  children: [
                    if (_step > 1)
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: OutlinedButton(
                            onPressed: () => _goToStep(_step - 1),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                  color: OpeiColors.pureBlack
                                      .withValues(alpha: 0.3),
                                  width: 0.5),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Text('Back',
                                style: TextStyle(
                                    color: OpeiColors.pureBlack,
                                    fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ),
                    if (_step > 1) const SizedBox(width: 10),
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : _buildNextAction(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: OpeiColors.pureBlack,
                            foregroundColor: OpeiColors.pureWhite,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: _isSubmitting
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: OpeiColors.pureWhite))
                              : Text(_buildNextLabel(),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepContent(BuildContext context, ThemeData theme) {
    if (_selectedType == P2PAdType.sell) {
      switch (_step) {
        case 1:
          return _buildCurrencyStep(theme, 'Payout currency');
        case 2:
          return _buildPaymentMethodsStep(theme, isBuy: false);
        case 3:
          return _buildDetailsStep(context, theme);
      }
    } else {
      switch (_step) {
        case 1:
          return _buildCurrencyStep(theme, 'Payment currency');
        case 2:
          return _buildPaymentMethodsStep(theme, isBuy: true);
        case 3:
          return _buildDetailsStep(context, theme);
      }
    }
    return const SizedBox.shrink();
  }

  Widget _buildCurrencyStep(ThemeData theme, String label) {
    final currentCurrency = currencies.firstWhere((c) => c.code == _currency,
        orElse: () => currencies.first);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: theme.textTheme.bodySmall
                ?.copyWith(fontSize: 12, color: OpeiColors.iosLabelSecondary)),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: _showCurrencyPicker,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: OpeiColors.iosSurfaceMuted,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: OpeiColors.iosSeparator.withValues(alpha: 0.35),
                  width: 0.5),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${currentCurrency.name} (${currentCurrency.code})',
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded,
                    size: 14, color: OpeiColors.iosLabelSecondary),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodsStep(ThemeData theme, {required bool isBuy}) {
    final helperText = isBuy
        ? 'Choose the payment methods you\'ll use to pay sellers. Only the rail name appears on your ad.'
        : 'Select how buyers can pay you in $_currency. We\'ll share the details after a trade opens.';

    final emptyCopy = 'No $_currency methods yet. Add one to continue.';
    final limitReached = _selectedMethodIds.length >= 5;

    Widget buildTile(P2PUserPaymentMethod method) {
      final isSelected = _selectedMethodIds.contains(method.id);
      final methodName = method.providerName.isNotEmpty
          ? method.providerName
          : _formatMethodType(method.methodType);
      final detailBits = <String>[];
      final readableType = _formatMethodType(method.methodType);
      if (readableType.isNotEmpty) {
        detailBits.add(readableType);
      }
      if (method.currency.isNotEmpty) {
        detailBits.add(method.currency);
      }
      final numberLabel = method.accountNumber.isNotEmpty
          ? method.accountNumber
          : method.accountNumberMasked;
      if (numberLabel.isNotEmpty) {
        detailBits.add(numberLabel);
      }

      return CheckboxListTile(
        value: isSelected,
        onChanged: (selected) {
          setState(() {
            if (selected == true) {
              if (_selectedMethodIds.length >= 5) {
                _errorMessage = 'You can attach up to five payment methods.';
              } else {
                _selectedMethodIds.add(method.id);
                if (_errorMessage != null &&
                    _errorMessage!.toLowerCase().contains('payment method')) {
                  _errorMessage = null;
                }
              }
            } else {
              _selectedMethodIds.remove(method.id);
            }
          });
        },
        dense: true,
        contentPadding: EdgeInsets.zero,
        controlAffinity: ListTileControlAffinity.leading,
        title: Text(
          methodName,
          style: theme.textTheme.bodyMedium
              ?.copyWith(fontSize: 13, fontWeight: FontWeight.w600),
        ),
        subtitle: detailBits.isEmpty
            ? null
            : Text(
                detailBits.join(' · '),
                style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 11, color: OpeiColors.iosLabelSecondary),
              ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          helperText,
          style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: 12, color: OpeiColors.iosLabelSecondary, height: 1.4),
        ),
        const SizedBox(height: 12),
        if (_loadingMethods)
          const LinearProgressIndicator(
              minHeight: 2,
              color: OpeiColors.pureBlack,
              backgroundColor: Color(0xFFE7E7E7))
        else if (_methods.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: OpeiColors.iosSurfaceMuted,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: OpeiColors.iosSeparator.withValues(alpha: 0.3),
                  width: 0.5),
            ),
            child: Text(
              emptyCopy,
              style: theme.textTheme.bodySmall
                  ?.copyWith(fontSize: 12, color: OpeiColors.iosLabelSecondary),
            ),
          )
        else
          ..._methods.map(buildTile),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: _loadingMethods ? null : _handleAddPaymentMethod,
            icon: const Icon(Icons.add_rounded,
                size: 16, color: OpeiColors.pureWhite),
            style: TextButton.styleFrom(
              backgroundColor: OpeiColors.pureBlack,
              foregroundColor: OpeiColors.pureWhite,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            label: const Text('Add payment method',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          limitReached
              ? 'Maximum of five payment methods per ad.'
              : 'You can attach up to five payment methods per ad.',
          style: theme.textTheme.bodySmall
              ?.copyWith(fontSize: 11, color: OpeiColors.iosLabelTertiary),
        ),
      ],
    );
  }

  Widget _buildDetailsStep(BuildContext context, ThemeData theme) {
    // Amounts and limits are captured in USD regardless of the fiat rail
    const String amountCurrencyLabel = 'USD';
    const String priceCurrencyLabel = 'USD';

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _AmountField(
                label: 'Total amount (USD)',
                currency: amountCurrencyLabel,
                controller: _totalAmount,
                focusNode: _totalFocus,
                textInputAction: TextInputAction.next,
                onSubmitted: (_) => _formFocusScope.requestFocus(_priceFocus),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _AmountField(
                label: 'Price (USD)',
                currency: priceCurrencyLabel,
                controller: _rate,
                focusNode: _priceFocus,
                textInputAction: TextInputAction.next,
                onSubmitted: (_) => _formFocusScope.requestFocus(_minFocus),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _AmountField(
                label: 'Min order (USD)',
                currency: amountCurrencyLabel,
                controller: _minOrder,
                focusNode: _minFocus,
                textInputAction: TextInputAction.next,
                onSubmitted: (_) => _formFocusScope.requestFocus(_maxFocus),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _AmountField(
                label: 'Max order (USD)',
                currency: amountCurrencyLabel,
                controller: _maxOrder,
                focusNode: _maxFocus,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _formFocusScope.unfocus(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _TextField(
          label: 'Instructions (optional)',
          controller: _instructions,
          hintText: 'e.g., Proof of transfer required',
          maxLines: 3,
          textInputAction: TextInputAction.newline,
        ),
      ],
    );
  }

  String _formatMethodType(String value) {
    if (value.isEmpty) {
      return '';
    }

    final parts = value
        .split(RegExp(r'[ _]+'))
        .where((segment) => segment.isNotEmpty)
        .map((segment) {
      final lower = segment.toLowerCase();
      return lower[0].toUpperCase() + lower.substring(1);
    }).toList(growable: false);

    return parts.join(' ');
  }

  VoidCallback? _buildNextAction() {
    if (_selectedType == P2PAdType.sell) {
      if (_step == 1) return () => _goToStep(2);
      if (_step == 2) return () => _goToStep(3);
      if (_step == 3) return _submit;
    } else {
      if (_step == 1) return () => _goToStep(2);
      if (_step == 2) return () => _goToStep(3);
      if (_step == 3) return _submit;
    }
    return null;
  }

  String _buildNextLabel() {
    final isLast = _selectedType != null && _step == 3;
    return isLast ? 'Publish' : 'Next';
  }
}

class _CurrencyPickerSheet extends StatelessWidget {
  final String selectedCode;

  const _CurrencyPickerSheet({required this.selectedCode});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Row(
              children: [
                Text('Select Currency',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontSize: 17, fontWeight: FontWeight.w700)),
                const Spacer(),
                IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded, size: 20)),
              ],
            ),
          ),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              itemCount: currencies.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1, thickness: 0.5),
              itemBuilder: (_, index) {
                final currency = currencies[index];
                final isSelected = currency.code == selectedCode;
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 6),
                  title: Text(currency.name,
                      style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 14, fontWeight: FontWeight.w600)),
                  subtitle: Text(currency.code,
                      style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 12, color: OpeiColors.iosLabelSecondary)),
                  trailing: isSelected
                      ? const Icon(Icons.check_rounded,
                          color: OpeiColors.pureBlack, size: 20)
                      : null,
                  onTap: () => Navigator.of(context).pop(currency),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CreateAdOptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _CreateAdOptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: OpeiColors.iosSurfaceMuted,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: OpeiColors.iosSeparator.withValues(alpha: 0.25),
              width: 0.5),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: OpeiColors.pureWhite,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 20, color: OpeiColors.pureBlack),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 12,
                      color: OpeiColors.iosLabelSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            const Icon(Icons.chevron_right_rounded,
                color: OpeiColors.iosLabelSecondary),
          ],
        ),
      ),
    );
  }
}

class _TextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? hintText;
  final int maxLines;
  final TextInputAction? textInputAction;

  const _TextField({
    required this.label,
    required this.controller,
    this.hintText,
    this.maxLines = 1,
    this.textInputAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            fontSize: 12,
            color: OpeiColors.iosLabelSecondary,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          textInputAction: textInputAction,
          style: theme.textTheme.bodyMedium?.copyWith(fontSize: 15),
          decoration: InputDecoration(
            hintText: hintText,
            filled: true,
            fillColor: OpeiColors.iosSurfaceMuted,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: OpeiColors.iosSeparator.withValues(alpha: 0.3),
                width: 0.5,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: OpeiColors.iosSeparator.withValues(alpha: 0.3),
                width: 0.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: OpeiColors.pureBlack, width: 1),
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileSetupSheet extends ConsumerStatefulWidget {
  final String initialCurrency;

  const _ProfileSetupSheet({required this.initialCurrency});

  @override
  ConsumerState<_ProfileSetupSheet> createState() => _ProfileSetupSheetState();
}

class _ProfileSetupSheetState extends ConsumerState<_ProfileSetupSheet> {
  late final TextEditingController _displayName;
  late final TextEditingController _nickname;
  late final TextEditingController _bio;
  String _preferredLanguage = 'en';
  late String _preferredCurrency;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _displayName = TextEditingController();
    _nickname = TextEditingController();
    _bio = TextEditingController();
    _preferredCurrency = widget.initialCurrency;
  }

  @override
  void dispose() {
    _displayName.dispose();
    _nickname.dispose();
    _bio.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final repo = ref.read(p2pRepositoryProvider);
    try {
      await repo.upsertUserProfile(
        displayName: _displayName.text.trim(),
        nickname: _nickname.text.trim(),
        bio: _bio.text.trim(),
        preferredLanguage: _preferredLanguage.trim(),
        preferredCurrency: _preferredCurrency.trim(),
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (error) {
      debugPrint('❌ Profile setup failed: $error');
      setState(() => _errorMessage = _mapProfileError(error));
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  String _mapProfileError(Object error) {
    final message = error.toString().toLowerCase();
    if (message.contains('missing x-user-id') || message.contains('session')) {
      return 'Please sign in again to continue.';
    }
    if (message.contains('displayname') &&
        message.contains('longer than or equal to 3')) {
      return 'Your display name must be between 3 and 50 characters.';
    }
    if (message.contains('nickname') && message.contains('3-30')) {
      return 'Your username can only contain letters, numbers, or underscores, and must be 3–30 characters long.';
    }
    if (message.contains('bio') && message.contains('500')) {
      return 'Your bio is too long. Please keep it under 500 characters.';
    }
    if (message.contains('preferredlanguage') &&
        message.contains('longer than')) {
      return 'Please select a valid language.';
    }
    if (message.contains('preferredcurrency') && message.contains('enum')) {
      return 'Please select a supported currency.';
    }
    if (message.contains('already in use')) {
      return 'That display name or username is already taken. Please choose another one.';
    }
    if (message.contains('unauthorized')) {
      return 'Please sign in again to continue.';
    }
    if (message.contains('internal server error') ||
        message.contains('server')) {
      return 'We’re having trouble saving your profile right now. Please try again shortly.';
    }
    return 'Something went wrong. Please try again.';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final currencyObjs = currencies;
    final currentCurrency = currencyObjs.firstWhere(
      (c) => c.code == _preferredCurrency,
      orElse: () => currencyObjs.first,
    );

    return AnimatedPadding(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: OpeiColors.iosSeparator.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Set up your P2P profile',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tell others how to recognize you. You can edit this later.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 12,
                        color: OpeiColors.iosLabelSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed:
                    _isSubmitting ? null : () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
            ],
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 12),
            _MessageBanner(message: _errorMessage!, isError: true),
          ],
          const SizedBox(height: 12),
          _TextField(
              label: 'Display name',
              controller: _displayName,
              hintText: 'Johnex'),
          const SizedBox(height: 10),
          _TextField(
              label: 'Username', controller: _nickname, hintText: 'john_fx'),
          const SizedBox(height: 10),
          _TextField(
              label: 'Bio',
              controller: _bio,
              hintText: '10 years trading USD/ZMW',
              maxLines: 3),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Preferred language',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 12,
                          color: OpeiColors.iosLabelSecondary,
                        )),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: OpeiColors.iosSurfaceMuted,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color:
                              OpeiColors.iosSeparator.withValues(alpha: 0.35),
                          width: 0.5,
                        ),
                      ),
                      child: DropdownButton<String>(
                        value: _preferredLanguage,
                        underline: const SizedBox.shrink(),
                        isExpanded: true,
                        items: const [
                          DropdownMenuItem(value: 'en', child: Text('English')),
                          DropdownMenuItem(
                              value: 'pt', child: Text('Portuguese')),
                          DropdownMenuItem(value: 'fr', child: Text('French')),
                        ],
                        onChanged: (v) =>
                            setState(() => _preferredLanguage = v ?? 'en'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Preferred currency',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 12,
                          color: OpeiColors.iosLabelSecondary,
                        )),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: OpeiColors.iosSurfaceMuted,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color:
                              OpeiColors.iosSeparator.withValues(alpha: 0.35),
                          width: 0.5,
                        ),
                      ),
                      child: DropdownButton<Currency>(
                        value: currentCurrency,
                        underline: const SizedBox.shrink(),
                        isExpanded: true,
                        items: currencies
                            .map((c) => DropdownMenuItem<Currency>(
                                  value: c,
                                  child: Text(c.code),
                                ))
                            .toList(),
                        onChanged: (c) => setState(
                            () => _preferredCurrency = c?.code ?? 'USD'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submit,
              style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 13)),
              child: Text(
                _isSubmitting ? 'Saving…' : 'Save profile',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: OpeiColors.pureWhite,
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

class _CreateSellAdSheet extends ConsumerStatefulWidget {
  final String initialCurrency;
  final Future<void> Function() onCreated;

  const _CreateSellAdSheet(
      {required this.initialCurrency, required this.onCreated});

  @override
  ConsumerState<_CreateSellAdSheet> createState() => _CreateSellAdSheetState();
}

class _CreateSellAdSheetState extends ConsumerState<_CreateSellAdSheet> {
  late String _currency;
  late final TextEditingController _totalAmount;
  late final TextEditingController _minOrder;
  late final TextEditingController _maxOrder;
  late final TextEditingController _rate;
  late final TextEditingController _instructions;
  bool _isSubmitting = false;
  String? _errorMessage;

  List<P2PUserPaymentMethod> _methods = const [];
  final Set<String> _selectedMethodIds = <String>{};
  bool _loadingMethods = false;
  int _step = 0; // 0: currency, 1: methods, 2: details

  @override
  void initState() {
    super.initState();
    _currency = widget.initialCurrency;
    _totalAmount = TextEditingController();
    _minOrder = TextEditingController();
    _maxOrder = TextEditingController();
    _rate = TextEditingController();
    _instructions = TextEditingController();
  }

  @override
  void dispose() {
    _totalAmount.dispose();
    _minOrder.dispose();
    _maxOrder.dispose();
    _rate.dispose();
    _instructions.dispose();
    super.dispose();
  }

  Future<void> _loadUserMethods() async {
    setState(() => _loadingMethods = true);
    try {
      final repo = ref.read(p2pRepositoryProvider);
      final methods = await repo.fetchUserPaymentMethods(currency: _currency);
      if (!mounted) return;
      setState(() => _methods = methods);
    } catch (e) {
      debugPrint('❌ Failed to load user payment methods: $e');
      if (!mounted) return;
      setState(() => _methods = const []);
    } finally {
      if (mounted) setState(() => _loadingMethods = false);
    }
  }

  void _goToStep(int next) {
    if (next == _step) return;
    setState(() => _step = next.clamp(0, 2));
    if (_step == 1) {
      // Entered methods step – load for selected currency
      _selectedMethodIds.clear();
      _loadUserMethods();
    }
  }

  int? _toCents(String text) {
    final sanitized = text.replaceAll(',', '').trim();
    if (sanitized.isEmpty) return null;
    final parsed = double.tryParse(sanitized);
    if (parsed == null) return null;
    final cents = (parsed * 100).round();
    return cents <= 0 ? null : cents;
  }

  String _mapCreateAdError(Object error) => _formatCreateAdError(
        error,
        adType: P2PAdType.sell,
      );

  Future<void> _handleAddPaymentMethod() async {
    final created = await showModalBottomSheet<P2PUserPaymentMethod>(
      context: context,
      isScrollControlled: true,
      backgroundColor: OpeiColors.pureWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _AddPaymentMethodSheet(currency: _currency),
    );
    if (created != null) {
      await _loadUserMethods();
      setState(() {
        _selectedMethodIds.add(created.id);
      });
    }
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final total = _toCents(_totalAmount.text) ?? 0;
    final min = _toCents(_minOrder.text) ?? 0;
    final max = _toCents(_maxOrder.text) ?? 0;
    final rate = _toCents(_rate.text) ?? 0;

    if (_selectedMethodIds.isEmpty) {
      setState(() {
        _isSubmitting = false;
        _errorMessage = 'Select at least one payment method.';
      });
      return;
    }
    if (!(total > 0 && rate > 0 && min > 0 && max >= min)) {
      setState(() {
        _isSubmitting = false;
        _errorMessage = 'Please enter valid amounts, limits and price.';
      });
      return;
    }

    try {
      final repo = ref.read(p2pRepositoryProvider);
      await repo.createAd(
        type: P2PAdType.sell,
        currency: _currency,
        totalAmountCents: total,
        minOrderCents: min,
        maxOrderCents: max,
        rateCents: rate,
        instructions: _instructions.text.trim().isEmpty
            ? null
            : _instructions.text.trim(),
        userPaymentMethodIds: _selectedMethodIds.toList(growable: false),
      );
      if (!mounted) return;
      Navigator.of(context).pop();
      await widget.onCreated();
    } catch (e) {
      debugPrint('❌ Create SELL ad failed: $e');
      if (!mounted) return;
      setState(() => _errorMessage = _mapCreateAdError(e));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final currentCurrency = currencies.firstWhere(
      (c) => c.code == _currency,
      orElse: () => currencies.first,
    );

    Widget stepHeader() {
      return Row(
        children: [
          Text(
            'Create SELL ad',
            style: theme.textTheme.titleMedium
                ?.copyWith(fontSize: 17, fontWeight: FontWeight.w700),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: OpeiColors.iosSurfaceMuted,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                  color: OpeiColors.iosSeparator.withValues(alpha: 0.3),
                  width: 0.5),
            ),
            child: Text(
              'Step ${_step + 1} of 3',
              style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: OpeiColors.iosLabelSecondary),
            ),
          ),
        ],
      );
    }

    Widget stepContent() {
      switch (_step) {
        case 0:
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Choose the currency you want to get paid in',
                  style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 12, color: OpeiColors.iosLabelSecondary)),
              const SizedBox(height: 12),
              Text('Payout currency',
                  style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 12, color: OpeiColors.iosLabelSecondary)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: OpeiColors.iosSurfaceMuted,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: OpeiColors.iosSeparator.withValues(alpha: 0.35),
                      width: 0.5),
                ),
                child: DropdownButton<Currency>(
                  value: currentCurrency,
                  underline: const SizedBox.shrink(),
                  isExpanded: true,
                  items: currencies
                      .map((c) => DropdownMenuItem<Currency>(
                          value: c, child: Text(c.code)))
                      .toList(),
                  onChanged: (c) {
                    setState(() {
                      _currency = c?.code ?? _currency;
                      _selectedMethodIds.clear();
                    });
                  },
                ),
              ),
            ],
          );
        case 1:
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Select or add payment methods for $_currency',
                  style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 12, color: OpeiColors.iosLabelSecondary)),
              const SizedBox(height: 10),
              if (_loadingMethods)
                const LinearProgressIndicator(
                    minHeight: 2,
                    color: OpeiColors.pureBlack,
                    backgroundColor: Color(0xFFE7E7E7))
              else if (_methods.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: OpeiColors.iosSurfaceMuted,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: OpeiColors.iosSeparator.withValues(alpha: 0.3),
                        width: 0.5),
                  ),
                  child: Text(
                    'No $_currency methods yet. Add one to continue.',
                    style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 12, color: OpeiColors.iosLabelSecondary),
                  ),
                )
              else ...[
                ..._methods.map((m) => CheckboxListTile(
                      value: _selectedMethodIds.contains(m.id),
                      onChanged: (selected) {
                        setState(() {
                          if (selected == true) {
                            if (_selectedMethodIds.length < 5) {
                              _selectedMethodIds.add(m.id);
                            }
                          } else {
                            _selectedMethodIds.remove(m.id);
                          }
                        });
                      },
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      title: Text(
                        m.providerName,
                        style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        () {
                          final summary = m.accountNumber.isNotEmpty
                              ? m.accountNumber
                              : m.accountNumberMasked;
                          final suffix =
                              summary.isNotEmpty ? ' · $summary' : '';
                          return '${m.methodType} · ${m.currency}$suffix';
                        }(),
                        style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 11, color: OpeiColors.iosLabelSecondary),
                      ),
                    )),
              ],
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: _handleAddPaymentMethod,
                  icon: const Icon(Icons.add_rounded,
                      size: 16, color: OpeiColors.pureWhite),
                  style: TextButton.styleFrom(
                    backgroundColor: OpeiColors.pureBlack,
                    foregroundColor: OpeiColors.pureWhite,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  label: const Text('Add payment method',
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          );
        default:
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  'Set the amount, limits, price, and instructions (optional).',
                  style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 12, color: OpeiColors.iosLabelSecondary)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                      child: _AmountField(
                          label: 'Total amount',
                          currency: _currency,
                          controller: _totalAmount)),
                  const SizedBox(width: 10),
                  Expanded(
                      child: _AmountField(
                          label: 'Price (rate)',
                          currency: _currency,
                          controller: _rate)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                      child: _AmountField(
                          label: 'Min order',
                          currency: _currency,
                          controller: _minOrder)),
                  const SizedBox(width: 10),
                  Expanded(
                      child: _AmountField(
                          label: 'Max order',
                          currency: _currency,
                          controller: _maxOrder)),
                ],
              ),
              const SizedBox(height: 10),
              _TextField(
                  label: 'Instructions (optional)',
                  controller: _instructions,
                  hintText: 'e.g., Available 08:00–21:00'),
            ],
          );
      }
    }

    Widget bottomButtons() {
      final isLast = _step == 2;
      return Row(
        children: [
          if (_step > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: () => _goToStep(_step - 1),
                style: OutlinedButton.styleFrom(
                  foregroundColor: OpeiColors.pureBlack,
                  side: BorderSide(
                      color: OpeiColors.iosSeparator.withValues(alpha: 0.5)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Back'),
              ),
            ),
          if (_step > 0) const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () async {
                if (isLast) {
                  await _submit();
                  return;
                }
                // Validate before moving forward
                if (_step == 0) {
                  _goToStep(1);
                  return;
                }
                if (_step == 1) {
                  if (_selectedMethodIds.isEmpty) {
                    setState(() =>
                        _errorMessage = 'Select at least one payment method.');
                    return;
                  }
                  setState(() => _errorMessage = null);
                  _goToStep(2);
                }
              },
              style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 13)),
              child: Text(
                isLast
                    ? (_isSubmitting ? 'Submitting…' : 'Submit for review')
                    : 'Continue',
                style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: OpeiColors.pureWhite),
              ),
            ),
          ),
        ],
      );
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomInset),
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: OpeiColors.iosSeparator.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            stepHeader(),
            const SizedBox(height: 6),
            if (_errorMessage != null) ...[
              _MessageBanner(message: _errorMessage!, isError: true),
              const SizedBox(height: 8),
            ],
            stepContent(),
            const SizedBox(height: 18),
            bottomButtons(),
          ],
        ),
      ),
    );
  }
}

class _CreateBuyAdSheet extends ConsumerStatefulWidget {
  final String initialCurrency;
  final Future<void> Function() onCreated;

  const _CreateBuyAdSheet(
      {required this.initialCurrency, required this.onCreated});

  @override
  ConsumerState<_CreateBuyAdSheet> createState() => _CreateBuyAdSheetState();
}

class _CreateBuyAdSheetState extends ConsumerState<_CreateBuyAdSheet> {
  late String _currency;
  late final TextEditingController _totalAmount;
  late final TextEditingController _minOrder;
  late final TextEditingController _maxOrder;
  late final TextEditingController _rate;
  late final TextEditingController _instructions;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _currency = widget.initialCurrency;
    _totalAmount = TextEditingController();
    _minOrder = TextEditingController();
    _maxOrder = TextEditingController();
    _rate = TextEditingController();
    _instructions = TextEditingController();
  }

  @override
  void dispose() {
    _totalAmount.dispose();
    _minOrder.dispose();
    _maxOrder.dispose();
    _rate.dispose();
    _instructions.dispose();
    super.dispose();
  }

  int? _toCents(String text) {
    final sanitized = text.replaceAll(',', '').trim();
    if (sanitized.isEmpty) return null;
    final parsed = double.tryParse(sanitized);
    if (parsed == null) return null;
    final cents = (parsed * 100).round();
    return cents <= 0 ? null : cents;
  }

  String _mapCreateAdError(Object error) => _formatCreateAdError(
        error,
        adType: P2PAdType.buy,
      );

  Future<void> _submit() async {
    if (_isSubmitting) return;
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final total = _toCents(_totalAmount.text) ?? 0;
    final min = _toCents(_minOrder.text) ?? 0;
    final max = _toCents(_maxOrder.text) ?? 0;
    final rate = _toCents(_rate.text) ?? 0;

    if (!(total > 0 && rate > 0 && min > 0 && max >= min)) {
      setState(() {
        _isSubmitting = false;
        _errorMessage = 'Please enter valid amounts, limits and price.';
      });
      return;
    }

    try {
      final repo = ref.read(p2pRepositoryProvider);
      await repo.createAd(
        type: P2PAdType.buy,
        currency: _currency,
        totalAmountCents: total,
        minOrderCents: min,
        maxOrderCents: max,
        rateCents: rate,
        instructions: _instructions.text.trim().isEmpty
            ? null
            : _instructions.text.trim(),
      );
      if (!mounted) return;
      Navigator.of(context).pop();
      await widget.onCreated();
    } catch (e) {
      debugPrint('❌ Create BUY ad failed: $e');
      if (!mounted) return;
      setState(() => _errorMessage = _mapCreateAdError(e));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final currentCurrency = currencies.firstWhere(
      (c) => c.code == _currency,
      orElse: () => currencies.first,
    );

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomInset),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: OpeiColors.iosSeparator.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text('Create BUY ad',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontSize: 17, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text('Set the amount, limits and price you’re willing to pay.',
                style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 12, color: OpeiColors.iosLabelSecondary)),
            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              _MessageBanner(message: _errorMessage!, isError: true),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Currency',
                          style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 12,
                              color: OpeiColors.iosLabelSecondary)),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: OpeiColors.iosSurfaceMuted,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: OpeiColors.iosSeparator
                                  .withValues(alpha: 0.35),
                              width: 0.5),
                        ),
                        child: DropdownButton<Currency>(
                          value: currentCurrency,
                          underline: const SizedBox.shrink(),
                          isExpanded: true,
                          items: currencies
                              .map((c) => DropdownMenuItem<Currency>(
                                  value: c, child: Text(c.code)))
                              .toList(),
                          onChanged: (c) =>
                              setState(() => _currency = c?.code ?? _currency),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                    child: _AmountField(
                        label: 'Total amount',
                        currency: _currency,
                        controller: _totalAmount)),
                const SizedBox(width: 10),
                Expanded(
                    child: _AmountField(
                        label: 'Price (rate)',
                        currency: _currency,
                        controller: _rate)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                    child: _AmountField(
                        label: 'Min order',
                        currency: _currency,
                        controller: _minOrder)),
                const SizedBox(width: 10),
                Expanded(
                    child: _AmountField(
                        label: 'Max order',
                        currency: _currency,
                        controller: _maxOrder)),
              ],
            ),
            const SizedBox(height: 10),
            _TextField(
                label: 'Instructions (optional)',
                controller: _instructions,
                hintText: 'e.g., Need proof of transfer'),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 13)),
                child: Text(
                  _isSubmitting ? 'Submitting…' : 'Submit for review',
                  style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: OpeiColors.pureWhite),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddPaymentMethodSheet extends ConsumerStatefulWidget {
  final String currency;
  final P2PUserPaymentMethod? initialMethod;

  const _AddPaymentMethodSheet({required this.currency, this.initialMethod});

  @override
  ConsumerState<_AddPaymentMethodSheet> createState() =>
      _AddPaymentMethodSheetState();
}

class _AddPaymentMethodSheetState
    extends ConsumerState<_AddPaymentMethodSheet> {
  List<P2PPaymentMethodType> _types = const [];
  String? _selectedTypeId;
  bool _loading = false;
  String? _errorMessage;

  final _accountName = TextEditingController();
  final _accountNumber = TextEditingController();
  final _extraDetails = TextEditingController();
  bool _isSubmitting = false;

  bool get _isEditing => widget.initialMethod != null;

  P2PPaymentMethodType? _currentType() {
    if (_selectedTypeId == null) return null;
    for (final type in _types) {
      if (type.id == _selectedTypeId) {
        return type;
      }
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    if (widget.initialMethod != null) {
      _accountName.text = widget.initialMethod!.accountName;
      _accountNumber.text = widget.initialMethod!.accountNumber;
      _extraDetails.text = widget.initialMethod!.extraDetails ?? '';
    }
    _loadTypes();
  }

  @override
  void dispose() {
    _accountName.dispose();
    _accountNumber.dispose();
    _extraDetails.dispose();
    super.dispose();
  }

  Future<void> _loadTypes() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    try {
      final repo = ref.read(p2pRepositoryProvider);
      final list = await repo.fetchPaymentMethodTypes(widget.currency);
      if (!mounted) return;
      setState(() {
        _types = list;
        _selectedTypeId ??= widget.initialMethod?.paymentMethodTypeId;
      });
    } catch (e) {
      debugPrint('❌ Failed to load payment method types: $e');
      if (!mounted) return;
      setState(() => _errorMessage =
          'We couldn’t load payment options. Please try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _mapError(Object error) {
    String msg = error.toString().toLowerCase();
    int? statusCode;
    if (error is ApiError) {
      statusCode = error.statusCode;
      msg = (error.message).toLowerCase();
    }
    if (msg.contains('missing x-user-id')) {
      return 'Please sign in again to continue.';
    }
    if (msg.contains('inactive')) {
      return 'Payment provider is currently inactive.';
    }
    if (msg.contains('payment method not found')) {
      return 'Payment method no longer exists.';
    }
    if (msg.contains('active ad')) {
      return 'This payment method is attached to an active ad and can’t be edited.';
    }
    if (msg.contains('ongoing trade')) {
      return 'This payment method is being used in an ongoing trade.';
    }
    if (msg.contains('not available') || msg.contains('not found')) {
      return 'Payment provider is not available.';
    }
    if (msg.contains('already exists') || msg.contains('account number')) {
      return 'Account number already exists for this user.';
    }
    if (msg.contains('maximum number')) {
      return 'Maximum payment methods reached for this currency.';
    }
    if (statusCode == 404) {
      return 'Payment method no longer exists.';
    }
    if (statusCode == 400 && msg.contains('active ad')) {
      return 'This payment method is attached to an active ad and can’t be edited.';
    }
    if (statusCode == 400 && msg.contains('ongoing')) {
      return 'This payment method is being used in an ongoing trade.';
    }
    if (msg.contains('validation') || msg.contains('bad request')) {
      return 'Please check your details and try again.';
    }
    return 'We couldn’t save this method. Please try again.';
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;
    if (!_isEditing && _selectedTypeId == null) {
      setState(() => _errorMessage = 'Select a payment provider.');
      return;
    }
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });
    try {
      final repo = ref.read(p2pRepositoryProvider);
      final trimmedName = _accountName.text.trim();
      final trimmedNumber = _accountNumber.text.trim();
      final trimmedExtra = _extraDetails.text.trim();
      if (_isEditing) {
        final initial = widget.initialMethod!;
        final changedName =
            trimmedName != initial.accountName ? trimmedName : null;
        final changedNumber =
            trimmedNumber != initial.accountNumber ? trimmedNumber : null;
        final String? changedExtra;
        if ((initial.extraDetails ?? '').trim() != trimmedExtra) {
          changedExtra = trimmedExtra.isEmpty ? '' : trimmedExtra;
        } else {
          changedExtra = null;
        }
        if (changedName == null &&
            changedNumber == null &&
            changedExtra == null) {
          if (mounted) {
            setState(() {
              _isSubmitting = false;
              _errorMessage = 'No changes detected.';
            });
          }
          return;
        }
        final updated = await repo.updateUserPaymentMethod(
          paymentMethodId: initial.id,
          accountName: changedName,
          accountNumber: changedNumber,
          extraDetails: changedExtra,
        );
        if (!mounted) return;
        Navigator.of(context).pop(updated);
      } else {
        final created = await repo.createUserPaymentMethod(
          paymentMethodTypeId: _selectedTypeId!,
          accountName: trimmedName,
          accountNumber: trimmedNumber,
          extraDetails: trimmedExtra.isEmpty ? null : trimmedExtra,
        );
        if (!mounted) return;
        Navigator.of(context).pop(created);
      }
    } catch (e) {
      debugPrint('❌ Add payment method failed: $e');
      if (!mounted) return;
      setState(() => _errorMessage = _mapError(e));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _showProviderPicker() async {
    if (_types.isEmpty) return;
    final selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final spacing = sheetContext.responsiveSpacingUnit;
        final tokens = sheetContext.responsiveTokens;
        return ResponsiveSheet(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              tokens.horizontalPadding,
              spacing * 2,
              tokens.horizontalPadding,
              spacing * 2,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: OpeiColors.iosSeparator.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                SizedBox(height: spacing * 1.5),
                Text(
                  'Select provider',
                  style: Theme.of(sheetContext).textTheme.titleMedium?.copyWith(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 8),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      final type = _types[index];
                      final isSelected = type.id == _selectedTypeId;
                      return ListTile(
                        onTap: () => Navigator.of(context).pop(type.id),
                        title: Text(
                          type.providerName,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          type.methodType,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: OpeiColors.iosLabelSecondary),
                        ),
                        trailing: isSelected
                            ? const Icon(Icons.check_rounded,
                                color: OpeiColors.pureBlack)
                            : null,
                      );
                    },
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemCount: _types.length,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    if (selected != null && mounted) {
      setState(() => _selectedTypeId = selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottom),
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: OpeiColors.iosSeparator.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              _isEditing ? 'Edit payment method' : 'Add payment method',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontSize: 17, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
                _isEditing
                    ? 'Update the details for this payment method.'
                    : 'Choose a provider and add your account details.',
                style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 12, color: OpeiColors.iosLabelSecondary)),
            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              _MessageBanner(message: _errorMessage!, isError: true),
            ],
            const SizedBox(height: 12),
            if (_loading)
              const LinearProgressIndicator(
                  minHeight: 2,
                  color: OpeiColors.pureBlack,
                  backgroundColor: Color(0xFFE7E7E7))
            else ...[
              Text('Provider',
                  style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 12, color: OpeiColors.iosLabelSecondary)),
              const SizedBox(height: 6),
              if (_isEditing)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: OpeiColors.iosSurfaceMuted,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: OpeiColors.iosSeparator.withValues(alpha: 0.35),
                        width: 0.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.initialMethod!.providerName,
                        style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${widget.initialMethod!.methodType} · ${widget.initialMethod!.currency}',
                        style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 11, color: OpeiColors.iosLabelSecondary),
                      ),
                    ],
                  ),
                )
              else
                InkWell(
                  onTap: _loading || _types.isEmpty ? null : _showProviderPicker,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    decoration: BoxDecoration(
                      color: OpeiColors.iosSurfaceMuted,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: OpeiColors.iosSeparator.withValues(alpha: 0.35),
                        width: 0.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (_selectedTypeId == null)
                                Text(
                                  _types.isEmpty
                                      ? 'No providers available'
                                      : 'Select provider…',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontSize: 13,
                                    color: OpeiColors.iosLabelSecondary,
                                  ),
                                )
                              else ...[
                                Text(
                                  _currentType()?.providerName ?? '',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _currentType()?.methodType ?? '',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontSize: 11,
                                    color: OpeiColors.iosLabelSecondary,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const Icon(Icons.keyboard_arrow_down_rounded,
                            color: OpeiColors.iosLabelSecondary),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 12),
              _TextField(
                  label: 'Account name',
                  controller: _accountName,
                  hintText: 'Name on account'),
              const SizedBox(height: 10),
              _TextField(
                  label: 'Account number',
                  controller: _accountNumber,
                  hintText: 'Account number'),
              const SizedBox(height: 10),
              _TextField(
                  label: 'Extra details (optional)',
                  controller: _extraDetails,
                  hintText: 'Branch, reference',
                  maxLines: 2),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 13)),
                  child: Text(
                      _isSubmitting
                          ? 'Saving…'
                          : _isEditing
                              ? 'Update method'
                              : 'Save method',
                      style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: OpeiColors.pureWhite)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CenteredMessage extends StatelessWidget {
  final String message;
  final bool isError;

  const _CenteredMessage({required this.message, this.isError = false});

  @override
  Widget build(BuildContext context) {
    final color =
        isError ? const Color(0xFFFF3B30) : OpeiColors.iosLabelSecondary;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          isError ? Icons.error_outline : Icons.hourglass_empty,
          size: 48,
          color: color.withValues(alpha: 0.7),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 14,
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ],
    );
  }
}

class _AdSummaryCard extends StatefulWidget {
  final P2PAd ad;
  final P2PAdType intentType;
  final VoidCallback onOpenDetails;

  const _AdSummaryCard({
    required this.ad,
    required this.intentType,
    required this.onOpenDetails,
  });

  @override
  State<_AdSummaryCard> createState() => _AdSummaryCardState();
}

class _AdSummaryCardState extends State<_AdSummaryCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 90));
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ad = widget.ad;
    final intentType = widget.intentType;

    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onOpenDetails();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: OpeiColors.pureWhite,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: OpeiColors.iosSeparator.withValues(alpha: 0.2),
              width: 0.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF000000).withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _CompactSellerRow(ad: ad),
                    const SizedBox(height: 10),
                    _CompactAdInfo(ad: ad),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              TextButton(
                onPressed: widget.onOpenDetails,
                style: TextButton.styleFrom(
                  backgroundColor: OpeiColors.pureBlack,
                  foregroundColor: OpeiColors.pureWhite,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  minimumSize: const Size(50, 32),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: Text(
                  intentType.displayLabel,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: OpeiColors.pureWhite,
                        letterSpacing: -0.2,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompactSellerRow extends StatelessWidget {
  final P2PAd ad;

  const _CompactSellerRow({required this.ad});

  @override
  Widget build(BuildContext context) {
    final seller = ad.seller;
    final theme = Theme.of(context);
    final displayName = seller.displayName.trim();
    final nickname = seller.nickname.trim();
    final hasDisplayName = displayName.isNotEmpty;
    final hasNickname = nickname.isNotEmpty;
    final primaryName = hasDisplayName
        ? displayName
        : hasNickname
            ? nickname
            : 'Trader';
    final ratingValue = seller.rating.clamp(0, 5).toDouble();
    final isNewSeller = ratingValue <= 0;
    final ratingDisplay = ratingValue.toStringAsFixed(1);
    final tradesFormatter = NumberFormat.compact();
    final tradesDisplay = tradesFormatter.format(seller.totalTrades);

    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            gradient: const LinearGradient(
              colors: [Color(0xFFF8F8F8), Color(0xFFE5E5E5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: OpeiColors.iosSeparator.withValues(alpha: 0.2),
              width: 0.5,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            primaryName.isEmpty ? '?' : primaryName[0].toUpperCase(),
            style: theme.textTheme.titleMedium?.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: OpeiColors.pureBlack,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                primaryName,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 3),
              Row(
                children: [
                  Icon(Icons.star_rounded,
                      size: 11,
                      color: isNewSeller
                          ? OpeiColors.iosLabelTertiary
                          : const Color(0xFFFFB800)),
                  const SizedBox(width: 3),
                  Text(
                    ratingDisplay,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: OpeiColors.pureBlack,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '•',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 11,
                      color: OpeiColors.iosLabelTertiary,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '$tradesDisplay trades',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: OpeiColors.iosLabelSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SellerIdentityRow extends StatelessWidget {
  final P2PAd ad;

  const _SellerIdentityRow({required this.ad});

  @override
  Widget build(BuildContext context) {
    final seller = ad.seller;
    final theme = Theme.of(context);
    final displayName = seller.displayName.trim();
    final nickname = seller.nickname.trim();
    final hasDisplayName = displayName.isNotEmpty;
    final hasNickname = nickname.isNotEmpty;
    final primaryName = hasDisplayName
        ? displayName
        : hasNickname
            ? nickname
            : 'Trader';
    final ratingValue = seller.rating.clamp(0, 5).toDouble();
    final isNewSeller = ratingValue <= 0;
    final ratingDisplay = ratingValue.toStringAsFixed(1);
    final tradesFormatter = NumberFormat.compact();
    final tradesDisplay = tradesFormatter.format(seller.totalTrades);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _SellerAvatar(seed: primaryName),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      primaryName,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(Icons.star_rounded,
                      size: 11,
                      color: isNewSeller
                          ? OpeiColors.iosLabelTertiary
                          : const Color(0xFFFFD60A)),
                  const SizedBox(width: 2),
                  Text(
                    ratingDisplay,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '•',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 10,
                      color: OpeiColors.iosLabelTertiary,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '$tradesDisplay trades',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: OpeiColors.iosLabelSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        _CurrencyChip(code: ad.currency),
      ],
    );
  }
}

class _SellerAvatar extends StatelessWidget {
  final String seed;

  const _SellerAvatar({required this.seed});

  @override
  Widget build(BuildContext context) {
    final trimmed = seed.trim();
    final initial = trimmed.isEmpty ? '?' : trimmed[0].toUpperCase();

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: const LinearGradient(
          colors: [Color(0xFFFAFAFA), Color(0xFFEDEDED)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: OpeiColors.iosSeparator.withValues(alpha: 0.4),
          width: 0.5,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: OpeiColors.pureBlack,
            ),
      ),
    );
  }
}

class _CurrencyChip extends StatelessWidget {
  final String code;

  const _CurrencyChip({required this.code});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: OpeiColors.iosSurfaceMuted,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: OpeiColors.iosSeparator.withValues(alpha: 0.3),
          width: 0.5,
        ),
      ),
      child: Text(
        code,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
      ),
    );
  }
}

class _CompactAdInfo extends StatelessWidget {
  final P2PAd ad;

  const _CompactAdInfo({required this.ad});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Show price as a USD-to-local conversion, e.g. "1 USD = ₦1,500"
    final localRate = ad.rate.format(includeCurrencySymbol: true);
    final rateLabel = '1 USD = $localRate';
    final remainingLabel =
        ad.remainingAmount.format(includeCurrencySymbol: true);
    final minLabel = ad.minOrder.format(includeCurrencySymbol: true);
    final maxLabel = ad.maxOrder.cents > 0
        ? ad.maxOrder.format(includeCurrencySymbol: true)
        : 'No limit';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Price',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 9,
                      fontWeight: FontWeight.w500,
                      color: OpeiColors.iosLabelSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    rateLabel,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Available',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 9,
                      fontWeight: FontWeight.w500,
                      color: OpeiColors.iosLabelSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    remainingLabel,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.1,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: Text(
                'Min: $minLabel',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                  color: OpeiColors.iosLabelSecondary,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Max: $maxLabel',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                  color: OpeiColors.iosLabelSecondary,
                ),
              ),
            ),
          ],
        ),
        if (ad.paymentMethods.isNotEmpty) ...[
          const SizedBox(height: 6),
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: ad.paymentMethods.map((method) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: OpeiColors.iosSurfaceMuted,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color: OpeiColors.iosSeparator.withValues(alpha: 0.25),
                    width: 0.5,
                  ),
                ),
                child: Text(
                  method.displayLabel,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 8,
                    fontWeight: FontWeight.w600,
                    color: OpeiColors.iosLabelSecondary,
                    letterSpacing: -0.1,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}

class _PaymentPill extends StatelessWidget {
  final String label;

  const _PaymentPill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: OpeiColors.iosSurfaceMuted,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: OpeiColors.iosSeparator.withValues(alpha: 0.28),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.account_balance_wallet_outlined,
              size: 12, color: OpeiColors.pureBlack),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: OpeiColors.pureBlack,
                  ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _AmountField extends StatelessWidget {
  final String label;
  final String currency;
  final TextEditingController controller;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;

  const _AmountField({
    required this.label,
    required this.currency,
    required this.controller,
    this.focusNode,
    this.textInputAction,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: OpeiColors.iosLabelSecondary,
              ),
        ),
        const SizedBox(height: 8),
        TextField(
          focusNode: focusNode,
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          textInputAction: textInputAction,
          onSubmitted: onSubmitted,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
          ],
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 15),
          decoration: InputDecoration(
            prefixText: '$currency ',
            prefixStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 13,
                  color: OpeiColors.iosLabelSecondary,
                  fontWeight: FontWeight.w600,
                ),
            filled: true,
            fillColor: OpeiColors.iosSurfaceMuted,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: OpeiColors.iosSeparator.withValues(alpha: 0.3),
                width: 0.5,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: OpeiColors.iosSeparator.withValues(alpha: 0.3),
                width: 0.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: OpeiColors.pureBlack, width: 1),
            ),
            hintText: '0.00',
            hintStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 13,
                  color: OpeiColors.iosLabelTertiary,
                ),
          ),
        ),
      ],
    );
  }
}

class _AdDetailsSheet extends ConsumerStatefulWidget {
  final P2PAd ad;
  final P2PAdType intentType;

  const _AdDetailsSheet({required this.ad, required this.intentType});

  @override
  ConsumerState<_AdDetailsSheet> createState() => _AdDetailsSheetState();
}

class _AdDetailsSheetState extends ConsumerState<_AdDetailsSheet> {
  late final TextEditingController _amountController;
  String? _validationMessage;
  String? _costEstimate;
  String? _actionError;
  bool _isSubmitting = false;
  P2PTrade? _completedTrade;
  P2PTradePaymentMethod? _completedPaymentMethod;
  P2PAdPaymentMethod? _selectedAdMethod;

  bool get _isBuyerFlow => widget.intentType == P2PAdType.buy;
  bool get _isSellerFlow => widget.intentType == P2PAdType.sell;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
    _amountController.addListener(_updateCostEstimate);
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _updateCostEstimate() {
    if (_validationMessage != null) {
      setState(() => _validationMessage = null);
    }

    final text = _amountController.text.trim();
    if (text.isEmpty) {
      setState(() => _costEstimate = null);
      return;
    }

    final rate = widget.ad.rate; // local currency per 1 USD
    if (_isBuyerFlow) {
      // Buyer enters USD and pays local fiat based on seller's rate.
      final usd = Money.parse(text, currency: 'USD');
      if (usd.cents <= 0) {
        setState(() => _costEstimate = null);
        return;
      }
      final localCents = (usd.cents * rate.cents) ~/ 100;
      final local = Money.fromCents(localCents, currency: rate.currency);
      setState(() {
        _costEstimate =
            'You’ll pay ${local.format(includeCurrencySymbol: true)}';
      });
      return;
    }

    if (_isSellerFlow) {
      // Seller enters USD amount they’ll release; buyer sends local fiat.
      final usd = Money.parse(text, currency: 'USD');
      if (usd.cents <= 0) {
        setState(() => _costEstimate = null);
        return;
      }
      final localCents = (usd.cents * rate.cents) ~/ 100;
      final local = Money.fromCents(localCents, currency: rate.currency);
      setState(() {
        _costEstimate =
            'Buyer will send ${local.format(includeCurrencySymbol: true)}';
      });
      return;
    }

    // Fallback for any other future intent types.
    final amount = Money.parse(text, currency: widget.ad.currency);
    if (amount.cents <= 0) {
      setState(() => _costEstimate = null);
      return;
    }
    final totalCostCents = (amount.cents * rate.cents) ~/ 100;
    final totalCost = Money.fromCents(totalCostCents, currency: rate.currency);
    setState(() {
      _costEstimate = totalCost.cents > 0
          ? 'Total value ${totalCost.format(includeCurrencySymbol: true)}'
          : null;
    });
  }

  void _handleAmountChanged(String _) {
    _updateCostEstimate();
  }

  void _handleSubmit() {
    final ad = widget.ad;
    final rate = ad.rate;

    int cents;
    Money localAmount;
    Money usdAmount;

    if (_isBuyerFlow || _isSellerFlow) {
      usdAmount = Money.parse(_amountController.text, currency: 'USD');
      final localCents = (usdAmount.cents * rate.cents) ~/ 100;
      localAmount = Money.fromCents(localCents, currency: rate.currency);
      cents = usdAmount.cents;
    } else {
      final amount = Money.parse(_amountController.text, currency: ad.currency);
      usdAmount = amount;
      localAmount = amount;
      cents = amount.cents;
    }

    if (cents <= 0) {
      setState(() => _validationMessage = 'Enter a valid amount to continue.');
      return;
    }

    final minCents = ad.minOrder.cents;
    if (cents < minCents) {
      setState(() => _validationMessage =
          'Enter at least ${ad.minOrder.format(includeCurrencySymbol: true)}.');
      return;
    }

    final maxCents = ad.maxOrder.cents;
    if (maxCents > 0 && cents > maxCents) {
      setState(() => _validationMessage =
          'Enter no more than ${ad.maxOrder.format(includeCurrencySymbol: true)}.');
      return;
    }

    if (cents > ad.remainingAmount.cents) {
      setState(() => _validationMessage =
          'Only ${ad.remainingAmount.format(includeCurrencySymbol: true)} left in this ad.');
      return;
    }

    setState(() => _validationMessage = null);

    if (_isBuyerFlow) {
      _startBuyTradeFlow(usdAmount);
      return;
    }

    if (_isSellerFlow) {
      _startSellTradeFlow(usdAmount);
      return;
    }

    Navigator.of(context).pop(localAmount);
  }

  Future<void> _startBuyTradeFlow(Money amount) async {
    if (_isSubmitting) return;
    setState(() {
      _isSubmitting = true;
      _actionError = null;
    });

    try {
      final repo = ref.read(p2pRepositoryProvider);

      // 1) Ensure profile exists
      final hasProfile = await repo.fetchProfileStatus();
      if (!hasProfile) {
        if (!mounted) return;
        // Open inline profile setup sheet (reuses existing UI)
        final created = await showModalBottomSheet<bool>(
          context: context,
          isScrollControlled: true,
          backgroundColor: OpeiColors.pureWhite,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          builder: (_) =>
              _ProfileSetupSheet(initialCurrency: widget.ad.currency),
        );
        if (created == true) {
          // Try to refresh profile state if parent is listening (best-effort)
          try {
            await ref.read(p2pProfileControllerProvider.notifier).refresh();
          } catch (_) {}
        } else {
          setState(() => _actionError = 'Set up your P2P profile to continue.');
          return;
        }
      }

      // 2) Let the buyer pick one of the seller's ad payment methods
      final methods = widget.ad.paymentMethods;
      if (methods.isEmpty) {
        setState(
            () => _actionError = 'This ad can’t accept payments right now.');
        return;
      }

      if (!mounted) return;
      final selectedMethodId = await showModalBottomSheet<String>(
        context: context,
        backgroundColor: OpeiColors.pureWhite,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (_) => _SelectAdPaymentMethodSheet(
          methods: methods,
          currency: widget.ad.currency,
          title: 'Choose how you’ll pay',
          subtitle:
              'Select one of the seller’s payment methods for ${widget.ad.currency}.',
          actionLabel: 'Continue',
        ),
      );

      if (!mounted) return;
      if (selectedMethodId == null || selectedMethodId.isEmpty) {
        // User cancelled selection
        return;
      }

      final selectedMethod = methods.firstWhere(
        (method) => method.id == selectedMethodId,
        orElse: () => methods.first,
      );
      _selectedAdMethod = selectedMethod;

      // 3) Create trade
      final tradePayload = await repo.createTrade(
        adId: widget.ad.id,
        amountCents: amount.cents,
        adPaymentMethodId: selectedMethodId,
      );

      if (!mounted) return;
      final trade = P2PTrade.fromJson(tradePayload);
      final tradeMethod = trade.selectedPaymentMethod ??
          _mapAdMethodToTradeMethod(selectedMethod);

      FocusScope.of(context).unfocus();
      setState(() {
        _completedTrade = trade;
        _completedPaymentMethod = tradeMethod;
        _costEstimate = null;
        _validationMessage = null;
        _actionError = null;
      });

      // Best-effort refresh so the Orders tab reflects the new trade
      try {
        await ref.read(p2pOrdersControllerProvider.notifier).refresh();
      } catch (_) {
        // Ignored: orders view will update on next manual refresh.
      }
    } catch (error) {
      debugPrint('❌ Create trade failed: $error');
      if (!mounted) return;
      setState(() => _actionError = _mapTradeError(error));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _startSellTradeFlow(Money amount) async {
    if (_isSubmitting) return;
    setState(() {
      _isSubmitting = true;
      _actionError = null;
    });

    try {
      final repo = ref.read(p2pRepositoryProvider);

      final hasProfile = await repo.fetchProfileStatus();
      if (!hasProfile) {
        if (!mounted) return;
        final created = await showModalBottomSheet<bool>(
          context: context,
          isScrollControlled: true,
          backgroundColor: OpeiColors.pureWhite,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          builder: (_) =>
              _ProfileSetupSheet(initialCurrency: widget.ad.currency),
        );
        if (created == true) {
          try {
            await ref.read(p2pProfileControllerProvider.notifier).refresh();
          } catch (_) {}
        } else {
          setState(() => _actionError = 'Set up your P2P profile to continue.');
          return;
        }
      }

      final methods = widget.ad.paymentMethods;
      if (methods.isEmpty) {
        setState(
            () => _actionError = 'Buyer has not provided any payment methods.');
        return;
      }

      if (!mounted) return;
      final selectedMethodId = await showModalBottomSheet<String>(
        context: context,
        backgroundColor: OpeiColors.pureWhite,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (_) => _SelectAdPaymentMethodSheet(
          methods: methods,
          currency: widget.ad.currency,
          title: 'Select payout rail',
          subtitle:
              'Choose the payment method the buyer should use for ${widget.ad.currency}.',
          actionLabel: 'Continue',
        ),
      );

      if (!mounted) return;
      if (selectedMethodId == null || selectedMethodId.isEmpty) {
        return;
      }

      final selectedMethod = methods.firstWhere(
        (method) => method.id == selectedMethodId,
        orElse: () => methods.first,
      );
      _selectedAdMethod = selectedMethod;

      final tradePayload = await repo.createTrade(
        adId: widget.ad.id,
        amountCents: amount.cents,
        adPaymentMethodId: selectedMethodId,
      );

      if (!mounted) return;
      final trade = P2PTrade.fromJson(tradePayload);
      final tradeMethod = trade.selectedPaymentMethod ??
          _mapAdMethodToTradeMethod(selectedMethod);

      FocusScope.of(context).unfocus();
      setState(() {
        _completedTrade = trade;
        _completedPaymentMethod = tradeMethod;
        _costEstimate = null;
        _validationMessage = null;
        _actionError = null;
      });

      try {
        await ref.read(p2pOrdersControllerProvider.notifier).refresh();
      } catch (_) {}
    } catch (error) {
      debugPrint('❌ Create SELL trade failed: $error');
      if (!mounted) return;
      setState(() => _actionError = _mapTradeError(error));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  P2PTradePaymentMethod _mapAdMethodToTradeMethod(P2PAdPaymentMethod method) {
    return P2PTradePaymentMethod(
      id: method.id,
      providerName: method.providerName,
      methodType: method.methodType,
      currency: method.currency,
      accountName: '',
      accountNumber: '',
      accountNumberMasked: '',
      extraDetails: null,
    );
  }

  String _mapTradeError(Object error) {
    if (error is ApiError) {
      final status = error.statusCode ?? 0;
      final message = error.message.trim();
      final messageLower = message.toLowerCase();
      if (status == 401) {
        if (messageLower.contains('missing') &&
            messageLower.contains('x-user-id')) {
          return 'We couldn’t verify your session. Please sign in again.';
        }
        return 'Your session has expired. Please sign in and try again.';
      }
      if ((status == 400 || status == 403 || status == 404) &&
          message.isNotEmpty &&
          !_isGenericTradeMessage(messageLower)) {
        return message;
      }
      if (status == 404) {
        return 'This ad is no longer available.';
      }
      if (status == 400) {
        if (messageLower.contains('own ad')) {
          return 'You can’t trade on your own ad.';
        }
        if (messageLower.contains('min') ||
            messageLower.contains('max') ||
            messageLower.contains('remaining')) {
          return 'Enter an amount within the ad’s limits.';
        }
        if (messageLower.contains('exceeds seller') ||
            messageLower.contains('available balance')) {
          return 'The seller doesn’t have enough available for that amount.';
        }
        if (messageLower.contains('without adpaymentmethodid') ||
            messageLower.contains('not on the ad') ||
            messageLower.contains('payment method')) {
          return 'Select a payment method offered on this ad.';
        }
        if (messageLower.contains('buyer has not specified') ||
            messageLower.contains('supported payment methods')) {
          return 'Buyer has not shared any supported payment methods yet.';
        }
        if (messageLower.contains('wallet') &&
            messageLower.contains('reservation')) {
          return 'We couldn’t reserve funds right now. Please try again.';
        }
        return 'We couldn’t start this trade. Please review your input and try again.';
      }
      if (status >= 500) {
        return 'Something went wrong on our side. Please try again.';
      }
      if (message.isNotEmpty) {
        return message;
      }
    }
    // Fallback
    final text = error.toString().toLowerCase();
    if (text.contains('unauthorized') || text.contains('missing x-user-id')) {
      return 'We couldn’t verify your session. Please sign in again.';
    }
    return 'We couldn’t start this trade. Please try again.';
  }

  bool _isGenericTradeMessage(String messageLower) {
    if (messageLower.isEmpty) {
      return true;
    }

    const genericTokens = <String>[
      'bad request',
      'invalid request',
      'forbidden',
      'not found',
      'requested resource was not found',
      'an error occurred',
      'server error',
      'permission to access this resource',
    ];

    for (final token in genericTokens) {
      if (messageLower == token || messageLower.startsWith('$token ')) {
        return true;
      }
      if (messageLower.endsWith(' $token')) {
        return true;
      }
      if (messageLower.contains(token)) {
        return true;
      }
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    final completedTrade = _completedTrade;
    if (completedTrade != null) {
      if (_isBuyerFlow) {
        return BuyTradeSuccessView(
          trade: completedTrade,
          paymentMethod: _completedPaymentMethod,
          fallbackMethod: _selectedAdMethod,
          instructions: widget.ad.instructions,
          onClose: () => context.pop(),
          onViewOrders: () => context.pop({'goToOrders': true}),
        );
      }

      if (_isSellerFlow) {
        return SellTradeSuccessView(
          trade: completedTrade,
          paymentMethod: _completedPaymentMethod,
          fallbackMethod: _selectedAdMethod,
          instructions: widget.ad.instructions,
          onClose: () => context.pop(),
          onViewOrders: () => context.pop({'goToOrders': true}),
        );
      }

      return BuyTradeSuccessView(
        trade: completedTrade,
        paymentMethod: _completedPaymentMethod,
        fallbackMethod: _selectedAdMethod,
        instructions: widget.ad.instructions,
        onClose: () => context.pop(),
        onViewOrders: () => context.pop({'goToOrders': true}),
      );
    }

    final ad = widget.ad;
    final intentType = widget.intentType;
    final intentLabel = intentType.displayLabel;
    final bottomPadding = 24 + MediaQuery.of(context).padding.bottom;
    final minLabel = ad.minOrder.format(includeCurrencySymbol: true);
    final hasMaxOrder = ad.maxOrder.cents > 0;
    final maxLabel = ad.maxOrder.format(includeCurrencySymbol: true);
    final limitsText =
        hasMaxOrder ? 'Min $minLabel · Max $maxLabel' : 'Min $minLabel';
    final amountPrefix =
        (_isBuyerFlow || _isSellerFlow) ? 'USD ' : '${ad.currency} ';
    final actionLabel = intentType == P2PAdType.buy
        ? 'Buy USD'
        : intentType == P2PAdType.sell
            ? 'Sell USD'
            : '$intentLabel ${ad.currency}';
    final primaryButtonLabel = _isSubmitting ? 'Please wait…' : actionLabel;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(24, 16, 24, bottomPadding),
      physics: const ClampingScrollPhysics(),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: OpeiColors.iosSeparator.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            actionLabel,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  fontFamily: '.SF Pro Display',
                ),
          ),
          const SizedBox(height: 8),
          if (ad.paymentMethods.isNotEmpty) ...[
            Text(
              'Payment methods',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: OpeiColors.iosLabelSecondary,
                  ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: ad.paymentMethods.map((method) {
                return _PaymentPill(label: method.displayLabel);
              }).toList(),
            ),
          ],
          const SizedBox(height: 20),
          _SellerIdentityRow(ad: ad),
          const SizedBox(height: 20),
          Text(
            intentType == P2PAdType.buy
                ? 'How much USD do you want to buy?'
                : 'How much USD do you want to sell?',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
            ],
            onChanged: _handleAmountChanged,
            style:
                Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 15),
            decoration: InputDecoration(
              prefixText: amountPrefix,
              prefixStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 14,
                    color: OpeiColors.iosLabelSecondary,
                    fontWeight: FontWeight.w600,
                  ),
              filled: true,
              fillColor: OpeiColors.iosSurfaceMuted,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: OpeiColors.iosSeparator.withValues(alpha: 0.3),
                  width: 0.5,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: OpeiColors.iosSeparator.withValues(alpha: 0.3),
                  width: 0.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: OpeiColors.pureBlack, width: 1),
              ),
              hintText: '0.00',
              hintStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 13,
                    color: OpeiColors.iosLabelTertiary,
                  ),
            ),
          ),
          if (_validationMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              _validationMessage!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 12,
                    color: const Color(0xFFFF3B30),
                  ),
            ),
          ],
          if (_costEstimate != null) ...[
            const SizedBox(height: 8),
            Text(
              _costEstimate!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: OpeiColors.pureBlack,
                  ),
            ),
          ],
          if (_actionError != null) ...[
            const SizedBox(height: 10),
            _MessageBanner(message: _actionError!, isError: true),
          ],
          const SizedBox(height: 12),
          Text(
            limitsText,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 12,
                  color: OpeiColors.iosLabelSecondary,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Available ${ad.remainingAmount.format(includeCurrencySymbol: true)}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 12,
                  color: OpeiColors.iosLabelSecondary,
                ),
          ),
          const SizedBox(height: 24),
          _DetailRow(label: 'Status', value: ad.statusLabel),
          _DetailRow(
            label: 'Rate',
            value: ad.rate.format(includeCurrencySymbol: true),
          ),
          _DetailRow(
            label: 'Available',
            value: ad.remainingAmount.format(includeCurrencySymbol: true),
          ),
          _DetailRow(
            label: 'Minimum order',
            value: ad.minOrder.format(includeCurrencySymbol: true),
          ),
          const SizedBox(height: 20),
          Text(
            'Instructions',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            ad.instructions.isEmpty
                ? 'No instructions provided.'
                : ad.instructions,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 14,
                  color: OpeiColors.iosLabelSecondary,
                ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _handleSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: OpeiColors.pureBlack,
                foregroundColor: OpeiColors.pureWhite,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                primaryButtonLabel,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: OpeiColors.pureWhite,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Removed local snackbar-only handler; the success view now handles file picking
}

class BuyTradeSuccessView extends ConsumerStatefulWidget {
  final P2PTrade trade;
  final P2PTradePaymentMethod? paymentMethod;
  final P2PAdPaymentMethod? fallbackMethod;
  final String instructions;
  final VoidCallback onClose;
  final VoidCallback onViewOrders;

  const BuyTradeSuccessView({
    super.key,
    required this.trade,
    required this.paymentMethod,
    required this.fallbackMethod,
    required this.instructions,
    required this.onClose,
    required this.onViewOrders,
  });

  @override
  ConsumerState<BuyTradeSuccessView> createState() =>
      _BuyTradeSuccessViewState();
}

class SellTradeSuccessView extends ConsumerStatefulWidget {
  final P2PTrade trade;
  final P2PTradePaymentMethod? paymentMethod;
  final P2PAdPaymentMethod? fallbackMethod;
  final String instructions;
  final VoidCallback onClose;
  final VoidCallback onViewOrders;

  const SellTradeSuccessView({
    super.key,
    required this.trade,
    required this.paymentMethod,
    required this.fallbackMethod,
    required this.instructions,
    required this.onClose,
    required this.onViewOrders,
  });

  @override
  ConsumerState<SellTradeSuccessView> createState() =>
      _SellTradeSuccessViewState();
}

class _SellTradeSuccessViewState extends ConsumerState<SellTradeSuccessView> {
  late P2PTrade _trade;
  bool _isCancelling = false;
  String? _cancelError;

  @override
  void initState() {
    super.initState();
    _trade = widget.trade;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final bottomPadding = 24 + MediaQuery.of(context).padding.bottom;
    final method =
        widget.paymentMethod ?? _fallbackAsTradeMethod(widget.fallbackMethod);
    final providerName = method?.providerName ?? 'Payment method';
    final methodTypeLabel = _humanizeType(method?.methodType ?? '');
    final sendAmount =
        _resolveSendFallback(trade: _trade, sendAmount: _trade.sendAmount);
    final currency = ((method?.currency ?? '').trim().isNotEmpty
            ? method!.currency.trim()
            : _resolveSendCurrency(trade: _trade, preferred: sendAmount))
        .toUpperCase();
    final amountLabel = _formatLocalAmount(sendAmount);
    final rateLabel =
        '1 USD = ${_trade.ad.rate.format(includeCurrencySymbol: true)}';
    final currentUserId = ref.watch(authSessionProvider).userId;
    final canCancelTrade =
        _canCurrentUserCancelTrade(trade: _trade, currentUserId: currentUserId);
    final heroDescription = _trade.status == P2PTradeStatus.initiated
        ? 'We reserved your USD. The buyer will pay using the method below.'
        : _statusDescription(_trade.status);

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20, 16, 20, bottomPadding),
      physics: const ClampingScrollPhysics(),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: OpeiColors.iosSeparator.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Column(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: OpeiColors.iosSurfaceMuted,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  alignment: Alignment.center,
                  child: SvgPicture.asset(
                    'assets/images/checkmark2.svg',
                    width: 24,
                    height: 24,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Trade created',
                  style: textTheme.titleLarge?.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  heroDescription,
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium?.copyWith(
                    fontSize: 12,
                    color: OpeiColors.iosLabelSecondary,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: OpeiColors.pureWhite,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: OpeiColors.iosSeparator.withValues(alpha: 0.15),
                  width: 0.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'You will receive',
                  style: textTheme.bodySmall?.copyWith(
                    fontSize: 11,
                    color: OpeiColors.iosLabelSecondary,
                    letterSpacing: -0.1,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  amountLabel,
                  style: textTheme.titleLarge?.copyWith(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                    color: OpeiColors.pureBlack,
                  ),
                ),
                const SizedBox(height: 12),
                _summaryRow(
                  textTheme: textTheme,
                  label: 'Buyer pays via',
                  value: providerName,
                  emphasizeValue: true,
                ),
                if (_isNotEmpty(methodTypeLabel))
                  Padding(
                    padding: const EdgeInsets.only(top: 4, left: 4),
                    child: Text(
                      methodTypeLabel,
                      style: textTheme.bodySmall?.copyWith(
                        fontSize: 11,
                        color: OpeiColors.iosLabelSecondary,
                      ),
                    ),
                  ),
                const SizedBox(height: 10),
                _summaryRow(
                  textTheme: textTheme,
                  label: 'Payment currency',
                  value: currency,
                ),
                const SizedBox(height: 8),
                _summaryRow(
                  textTheme: textTheme,
                  label: 'Rate',
                  value: rateLabel,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (_isNotEmpty(widget.instructions))
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: OpeiColors.iosSurfaceMuted,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ad instructions',
                    style: textTheme.bodySmall?.copyWith(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: OpeiColors.iosLabelSecondary),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.instructions,
                    style: textTheme.bodyMedium?.copyWith(
                      fontSize: 12.5,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          if (_trade.status == P2PTradeStatus.initiated) ...[
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: OpeiColors.pureWhite,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: OpeiColors.iosSeparator.withValues(alpha: 0.15),
                    width: 0.5),
              ),
              child: Text(
                'We’ll notify you once the buyer marks payment as sent. Go to Orders to review proof and release the funds.',
                style: textTheme.bodySmall?.copyWith(
                  fontSize: 12,
                  color: OpeiColors.iosLabelSecondary,
                  height: 1.35,
                ),
              ),
            ),
          ],
          if (_cancelError != null) ...[
            const SizedBox(height: 16),
            _MessageBanner(message: _cancelError!, isError: true),
          ],
          if (canCancelTrade) ...[
            const SizedBox(height: 14),
            _buildCancelButton(textTheme),
          ],
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: widget.onViewOrders,
              style: ElevatedButton.styleFrom(
                backgroundColor: OpeiColors.pureBlack,
                foregroundColor: OpeiColors.pureWhite,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                'Done',
                style: textTheme.bodyMedium?.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: OpeiColors.pureWhite,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          TextButton(
            onPressed: widget.onClose,
            style: TextButton.styleFrom(
              foregroundColor: OpeiColors.iosLabelSecondary,
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
            child: Text(
              'Close',
              style: textTheme.bodyMedium?.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleCancelTrade() async {
    if (_isCancelling) {
      return;
    }

    final confirmed = await showP2PCancelTradeWarningDialog(context);
    if (confirmed != true) {
      return;
    }

    setState(() {
      _isCancelling = true;
      _cancelError = null;
    });

    try {
      final controller = ref.read(p2pOrdersControllerProvider.notifier);
      final updated = await controller.cancelTrade(_trade);
      if (!mounted) return;

      setState(() {
        _trade = updated;
        _cancelError = null;
      });

      final messenger = ScaffoldMessenger.maybeOf(context);
      messenger
          ?.showSnackBar(const SnackBar(content: Text('Trade cancelled.')));
    } catch (error) {
      if (!mounted) return;
      final friendly = error is String
          ? error
          : 'We couldn’t cancel this trade. Please try again.';
      setState(() {
        _cancelError = friendly;
      });
      final messenger = ScaffoldMessenger.maybeOf(context);
      messenger?.showSnackBar(SnackBar(content: Text(friendly)));
    } finally {
      if (mounted) {
        setState(() {
          _isCancelling = false;
        });
      }
    }
  }

  Widget _buildCancelButton(TextTheme textTheme) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: _isCancelling ? null : _handleCancelTrade,
        style: OutlinedButton.styleFrom(
          foregroundColor: _isCancelling
              ? OpeiColors.iosLabelSecondary
              : const Color(0xFFD62E1F),
          side: BorderSide(
            color: _isCancelling
                ? OpeiColors.iosSeparator.withValues(alpha: 0.4)
                : const Color(0xFFD62E1F),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: _isCancelling
            ? const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 1.8,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFD62E1F)),
                ),
              )
            : Text(
                'Cancel trade',
                style: textTheme.bodyMedium?.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Widget _summaryRow({
    required TextTheme textTheme,
    required String label,
    required String value,
    bool emphasizeValue = false,
  }) {
    final labelStyle = textTheme.bodySmall?.copyWith(
      fontSize: 11,
      color: OpeiColors.iosLabelSecondary,
    );
    final valueStyle = emphasizeValue
        ? textTheme.bodyMedium?.copyWith(
            fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: -0.1)
        : textTheme.bodySmall?.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: OpeiColors.pureBlack);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(child: Text(label, style: labelStyle)),
          const SizedBox(width: 12),
          Flexible(
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                value,
                style: valueStyle,
                textAlign: TextAlign.right,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _statusDescription(P2PTradeStatus status) {
    switch (status) {
      case P2PTradeStatus.initiated:
        return 'Active trade.';
      case P2PTradeStatus.paidByBuyer:
        return 'Buyer marked the trade as paid. Review the proof before releasing the funds.';
      case P2PTradeStatus.releasedBySeller:
        return 'You released this trade. Funds are on the way to the buyer.';
      case P2PTradeStatus.completed:
        return 'Trade completed successfully.';
      case P2PTradeStatus.cancelled:
        return 'This trade was cancelled.';
      case P2PTradeStatus.disputed:
        return 'This trade is under review.';
      case P2PTradeStatus.expired:
        return 'This trade expired before the buyer confirmed payment.';
    }
  }

  static bool _isNotEmpty(String? value) =>
      value != null && value.trim().isNotEmpty;

  String _humanizeType(String raw) {
    final normalized = raw.trim();
    if (normalized.isEmpty) {
      return '';
    }
    final parts = normalized
        .split(RegExp(r'[ _]+'))
        .where((segment) => segment.trim().isNotEmpty)
        .map((segment) {
      final lower = segment.toLowerCase();
      return lower[0].toUpperCase() + lower.substring(1);
    }).toList(growable: false);
    return parts.join(' ');
  }

  P2PTradePaymentMethod? _fallbackAsTradeMethod(P2PAdPaymentMethod? method) {
    if (method == null) return null;
    return P2PTradePaymentMethod(
      id: method.id,
      providerName: method.providerName,
      methodType: method.methodType,
      currency: method.currency,
      accountName: '',
      accountNumber: '',
      accountNumberMasked: '',
      extraDetails: null,
    );
  }
}

class _BuyTradeSuccessViewState extends ConsumerState<BuyTradeSuccessView> {
  static const int _maxImages = 3;
  static const int _maxBytesPerImage = 5 * 1024 * 1024; // 5MB

  final List<PlatformFile> _pickedImages = [];
  String? _pickError;
  String? _submissionError;
  bool _isSubmitting = false;
  bool _submissionSuccess = false;
  bool _isDisputing = false;
  String? _disputeError;
  bool _disputeSuccess = false;
  bool _isPickingProofs = false;
  bool _isCancelling = false;
  String? _cancelError;

  late final TextEditingController _noteController;
  late P2PTrade _trade;

  @override
  void initState() {
    super.initState();
    _trade = widget.trade;
    _noteController = TextEditingController();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final bottomPadding = 24 + MediaQuery.of(context).padding.bottom;
    final method = widget.paymentMethod;
    final fallback = widget.fallbackMethod;
    final trade = _trade;
    final providerName =
        (method?.providerName ?? fallback?.providerName ?? 'Payment method')
            .toString();
    final methodType = (method?.methodType ?? fallback?.methodType)?.toString();
    final currency = (method?.currency ?? fallback?.currency)?.toString();
    final accountName = _safeString(method?.accountName);
    final accountNumber = _safeString(method?.accountNumber);
    final extraDetails =
        method?.extraDetails != null ? _safeString(method!.extraDetails) : null;
    final hasAccountDetails =
        accountName.isNotEmpty || accountNumber.isNotEmpty;

    final existingProofs = trade.proofs;
    final canSubmitProof = trade.status == P2PTradeStatus.initiated;
    final awaitingSeller = trade.status == P2PTradeStatus.paidByBuyer;
    final showDisputeButton = _isTradeEligibleForDispute(trade.status);
    final currentUserId = ref.watch(authSessionProvider).userId;
    final canCancelTrade =
        _canCurrentUserCancelTrade(trade: trade, currentUserId: currentUserId);

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(24, 20, 24, bottomPadding),
      physics: const ClampingScrollPhysics(),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: OpeiColors.iosSeparator.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Column(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: OpeiColors.iosSurfaceMuted,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.center,
                  child: SvgPicture.asset(
                    'assets/images/checkmark2.svg',
                    width: 28,
                    height: 28,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Trade created',
                  style: textTheme.titleLarge?.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Send payment using the details below.',
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium?.copyWith(
                    fontSize: 13,
                    color: OpeiColors.iosLabelSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          if (!canSubmitProof) ...[
            _buildStatusBanner(trade, textTheme),
            const SizedBox(height: 16),
          ],
          _buildAmountSummary(trade, textTheme),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: OpeiColors.iosSurfaceMuted,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.schedule,
                  size: 14,
                  color: OpeiColors.iosLabelSecondary,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Pay within 30 minutes & confirm, or this trade will be cancelled.',
                    style: textTheme.bodySmall?.copyWith(
                      fontSize: 11,
                      color: OpeiColors.iosLabelSecondary,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          _buildPaymentDetailsCard(
            textTheme,
            providerName: providerName,
            methodType: methodType,
            currency: currency,
            accountName: accountName,
            accountNumber: accountNumber,
            extraDetails: extraDetails,
            hasAccountDetails: hasAccountDetails,
          ),
          if (_isPickingProofs) ...[
            const SizedBox(height: 16),
            _buildPickingIndicator(textTheme),
          ],
          if (_pickedImages.isNotEmpty && canSubmitProof) ...[
            const SizedBox(height: 16),
            _buildProofPreview(
              textTheme,
              allowRemove: !_isSubmitting && !_isPickingProofs,
            ),
          ],
          const SizedBox(height: 18),
          _buildInstructions(textTheme),
          if (existingProofs.isNotEmpty) ...[
            const SizedBox(height: 18),
            _buildSubmittedProofs(existingProofs, textTheme),
          ],
          if (_cancelError != null) ...[
            const SizedBox(height: 16),
            _MessageBanner(message: _cancelError!, isError: true),
          ],
          if (canCancelTrade) ...[
            const SizedBox(height: 16),
            _buildCancelButton(textTheme),
          ],
          if (_disputeError != null) ...[
            const SizedBox(height: 14),
            _MessageBanner(message: _disputeError!, isError: true),
          ],
          if (_disputeSuccess) ...[
            const SizedBox(height: 14),
            const _MessageBanner(
              message: 'Dispute opened. Support will review it shortly.',
              isError: false,
            ),
          ],
          if (showDisputeButton) ...[
            const SizedBox(height: 14),
            _buildDisputeButton(textTheme),
          ],
          if (awaitingSeller) ...[
            const SizedBox(height: 20),
            _buildAwaitingSellerCard(textTheme),
            const SizedBox(height: 8),
            _buildCloseButton(textTheme),
          ] else ...[
            const SizedBox(height: 20),
            if (canSubmitProof)
              _buildIvePaidButton(
                textTheme,
                disabled: _isSubmitting || _isPickingProofs || _isCancelling,
              ),
            const SizedBox(height: 16),
            _buildCloseButton(textTheme),
          ],
        ],
      ),
    );
  }

  Widget _buildPaymentDetailsCard(
    TextTheme textTheme, {
    required String providerName,
    String? methodType,
    String? currency,
    required String accountName,
    required String accountNumber,
    String? extraDetails,
    required bool hasAccountDetails,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Seller Payment Details',
          style: textTheme.titleSmall?.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: OpeiColors.iosLabelSecondary,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: OpeiColors.pureWhite,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: OpeiColors.iosSeparator.withValues(alpha: 0.15),
                width: 0.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 12,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: hasAccountDetails
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF2F2F7),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.account_balance_outlined,
                            size: 18,
                            color: OpeiColors.pureBlack,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                providerName,
                                style: textTheme.titleSmall?.copyWith(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              if (methodType != null &&
                                  methodType.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  methodType,
                                  style: textTheme.bodySmall?.copyWith(
                                    fontSize: 11,
                                    color: OpeiColors.iosLabelSecondary,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (currency != null && currency.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF2F2F7),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              currency,
                              style: textTheme.bodySmall?.copyWith(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      height: 0.5,
                      color: OpeiColors.iosSeparator.withValues(alpha: 0.3),
                    ),
                    const SizedBox(height: 20),
                    if (accountName.isNotEmpty) ...[
                      _PaymentDetailRow(
                        label: 'Account Name',
                        value: accountName,
                        textTheme: textTheme,
                      ),
                      const SizedBox(height: 12),
                    ],
                    if (accountNumber.isNotEmpty) ...[
                      _PaymentDetailRow(
                        label: 'Account Number',
                        value: accountNumber,
                        textTheme: textTheme,
                        isMonospace: true,
                      ),
                    ],
                    if (extraDetails != null && extraDetails.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      _PaymentDetailRow(
                        label: 'Additional Details',
                        value: extraDetails,
                        textTheme: textTheme,
                      ),
                    ],
                  ],
                )
              : Column(
                  children: [
                    Icon(
                      Icons.chat_bubble_outline,
                      size: 32,
                      color: OpeiColors.iosLabelSecondary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Seller will share the final account details in chat.',
                      textAlign: TextAlign.center,
                      style: textTheme.bodySmall?.copyWith(
                        fontSize: 13,
                        color: OpeiColors.iosLabelSecondary,
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildAmountSummary(P2PTrade trade, TextTheme textTheme) {
    final Money? sendAmount = trade.sendAmount;
    final Money fallbackSend =
        _resolveSendFallback(trade: trade, sendAmount: sendAmount);
    final Money effectiveSend = sendAmount ?? fallbackSend;
    final String sendLabel = _formatLocalAmount(effectiveSend);
    final String usdReservedLabel = _formatUsdAmount(trade.amount);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: OpeiColors.pureWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: OpeiColors.iosSeparator.withValues(alpha: 0.15), width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'You send',
                style: textTheme.bodyMedium?.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: OpeiColors.iosLabelSecondary,
                  letterSpacing: -0.1,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    sendLabel,
                    style: textTheme.titleLarge?.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.4,
                      color: OpeiColors.pureBlack,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    effectiveSend.currency,
                    style: textTheme.bodySmall?.copyWith(
                      fontSize: 11,
                      color: OpeiColors.iosLabelSecondary,
                      letterSpacing: 0.1,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            height: 0.5,
            color: OpeiColors.iosSeparator.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'You\'ll receive',
                style: textTheme.bodyMedium?.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: OpeiColors.iosLabelSecondary,
                  letterSpacing: -0.1,
                ),
              ),
              Text(
                usdReservedLabel,
                style: textTheme.titleLarge?.copyWith(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.3,
                  color: OpeiColors.pureBlack,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInstructions(TextTheme textTheme) {
    final trimmed = _safeString(widget.instructions);
    final hasCopy = trimmed.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Seller Instructions',
          style: textTheme.titleSmall?.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: OpeiColors.iosLabelSecondary,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: OpeiColors.pureWhite,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: OpeiColors.iosSeparator.withValues(alpha: 0.15),
                width: 0.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 12,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F2F7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.info_outline,
                  size: 16,
                  color: OpeiColors.iosLabelSecondary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  hasCopy ? trimmed : 'No extra instructions provided.',
                  style: textTheme.bodyMedium?.copyWith(
                    fontSize: 13,
                    color: hasCopy
                        ? OpeiColors.pureBlack
                        : OpeiColors.iosLabelSecondary,
                    height: 1.5,
                    letterSpacing: -0.1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDisputeButton(TextTheme textTheme) {
    final isDisabled = _trade.status == P2PTradeStatus.disputed || _isDisputing;
    final label = _trade.status == P2PTradeStatus.disputed
        ? 'Dispute opened'
        : 'Raise dispute';

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: isDisabled ? null : _handleRaiseDispute,
        style: OutlinedButton.styleFrom(
          foregroundColor: OpeiColors.pureBlack,
          side:
              BorderSide(color: OpeiColors.iosSeparator.withValues(alpha: 0.4)),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: Text(
          label,
          style: textTheme.bodyMedium?.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildCancelButton(TextTheme textTheme) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: _isCancelling ? null : _handleCancelTrade,
        style: OutlinedButton.styleFrom(
          foregroundColor: _isCancelling
              ? OpeiColors.iosLabelSecondary
              : const Color(0xFFD62E1F),
          side: BorderSide(
            color: _isCancelling
                ? OpeiColors.iosSeparator.withValues(alpha: 0.4)
                : const Color(0xFFD62E1F),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: _isCancelling
            ? const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 1.8,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFD62E1F)),
                ),
              )
            : Text(
                'Cancel trade',
                style: textTheme.bodyMedium?.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Widget _buildAwaitingSellerCard(TextTheme textTheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: OpeiColors.iosSurfaceMuted,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: OpeiColors.iosSeparator.withValues(alpha: 0.2), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: OpeiColors.pureWhite,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: OpeiColors.iosSeparator.withValues(alpha: 0.25),
                      width: 0.5),
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.hourglass_bottom_rounded,
                    size: 16, color: OpeiColors.pureBlack),
              ),
              const SizedBox(width: 10),
              Text(
                'Waiting for the seller',
                style: textTheme.titleSmall?.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'We\'ve notified the other party. Once they confirm payment, your USD will be released to your wallet. We\'ll let you know immediately.',
            style: textTheme.bodySmall?.copyWith(
              fontSize: 13,
              height: 1.45,
              color: OpeiColors.iosLabelSecondary,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: widget.onViewOrders,
              style: ElevatedButton.styleFrom(
                backgroundColor: OpeiColors.pureBlack,
                foregroundColor: OpeiColors.pureWhite,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
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
        ],
      ),
    );
  }

  Widget _buildPickingIndicator(TextTheme textTheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: OpeiColors.pureWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: OpeiColors.iosSeparator.withValues(alpha: 0.25), width: 0.5),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(OpeiColors.pureBlack),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Adding your proof...',
              style: textTheme.bodySmall?.copyWith(
                fontSize: 12,
                color: OpeiColors.iosLabelSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIvePaidButton(TextTheme textTheme, {required bool disabled}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: disabled ? null : _showUploadProofSheet,
        style: ElevatedButton.styleFrom(
          backgroundColor: OpeiColors.pureBlack,
          foregroundColor: OpeiColors.pureWhite,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
        child: Text(
          'I\'ve Paid',
          style: textTheme.bodyMedium?.copyWith(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: OpeiColors.pureWhite,
            letterSpacing: -0.3,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBanner(P2PTrade trade, TextTheme textTheme) {
    final statusLabel = trade.status.displayLabel;
    final description = _statusDescription(trade.status);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: OpeiColors.pureWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: OpeiColors.iosSeparator.withValues(alpha: 0.2), width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: OpeiColors.iosSurfaceMuted,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              statusLabel,
              style: textTheme.bodySmall?.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.1,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: textTheme.bodySmall?.copyWith(
              fontSize: 13,
              height: 1.45,
              color: OpeiColors.iosLabelSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmittedProofs(
      List<P2PTradeProof> proofs, TextTheme textTheme) {
    final thumbnails = proofs
        .where((proof) => proof.url.isNotEmpty)
        .map((proof) => _ProofNetworkThumb(url: proof.url))
        .toList(growable: false);

    if (thumbnails.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Submitted proofs',
          style: textTheme.titleSmall?.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: OpeiColors.iosLabelSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: thumbnails,
        ),
        const SizedBox(height: 6),
        Text(
          'Visible to the seller and support team.',
          style: textTheme.bodySmall?.copyWith(
            fontSize: 11,
            color: OpeiColors.iosLabelTertiary,
          ),
        ),
      ],
    );
  }

  void _showUploadProofSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => _UploadProofSheet(
          onConfirm: () async {
            final submitFuture = _handleConfirmPaid();
            setModalState(() {});
            await submitFuture;
            if (!mounted) return;
            setModalState(() {});
            if (_submissionSuccess) {
              Navigator.of(context).pop();
              await _presentProofSubmittedScreen(context);
            }
          },
          onPickImages: () async {
            final pickFuture = _handlePickProofs();
            setModalState(() {});
            await pickFuture;
            if (!mounted) return;
            setModalState(() {});
          },
          pickedImages: _pickedImages,
          onRemoveImage: (index) {
            _handleRemoveProof(index);
            setModalState(() {});
          },
          noteController: _noteController,
          isSubmitting: _isSubmitting,
          isPicking: _isPickingProofs,
          pickError: _pickError,
          submissionError: _submissionError,
        ),
      ),
    );
  }

  Widget _buildCloseButton(TextTheme textTheme) {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: widget.onClose,
        style: TextButton.styleFrom(
          foregroundColor: OpeiColors.iosLabelSecondary,
          padding: const EdgeInsets.symmetric(vertical: 12),
          textStyle: textTheme.bodyMedium?.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        child: const Text('Close'),
      ),
    );
  }

  Future<void> _handleCancelTrade() async {
    if (_isCancelling) {
      return;
    }

    final confirmed = await showP2PCancelTradeWarningDialog(context);
    if (!confirmed) {
      return;
    }

    setState(() {
      _isCancelling = true;
      _cancelError = null;
    });

    try {
      final controller = ref.read(p2pOrdersControllerProvider.notifier);
      final updatedTrade = await controller.cancelTrade(_trade);
      if (!mounted) return;

      setState(() {
        _trade = updatedTrade;
        _cancelError = null;
      });

      final messenger = ScaffoldMessenger.maybeOf(context);
      messenger
          ?.showSnackBar(const SnackBar(content: Text('Trade cancelled.')));
    } catch (error) {
      if (!mounted) return;
      final friendly = error is String
          ? error
          : 'We couldn’t cancel this trade. Please try again.';
      setState(() {
        _cancelError = friendly;
      });
      final messenger = ScaffoldMessenger.maybeOf(context);
      messenger?.showSnackBar(SnackBar(content: Text(friendly)));
    } finally {
      if (mounted) {
        setState(() {
          _isCancelling = false;
        });
      }
    }
  }

  Future<void> _handleRaiseDispute() async {
    final reason = await _promptDisputeReason(context);
    if (reason == null || reason.trim().isEmpty) {
      return;
    }

    setState(() {
      _isDisputing = true;
      _disputeError = null;
      _disputeSuccess = false;
    });

    try {
      final repository = ref.read(p2pRepositoryProvider);
      final updatedTrade = await repository.raiseTradeDispute(
        tradeId: _trade.id,
        reason: reason,
      );

      if (!mounted) return;

      setState(() {
        _trade = updatedTrade;
        _disputeSuccess = true;
        _disputeError = null;
      });

      await _refreshOrdersSilently();

      if (!mounted) return;
      final messenger = ScaffoldMessenger.maybeOf(context);
      messenger?.showSnackBar(
        const SnackBar(
            content: Text('Dispute submitted. Support has been notified.')),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _disputeError = _mapDisputeError(error);
        _disputeSuccess = false;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isDisputing = false;
        });
      }
    }
  }

  Future<void> _handleConfirmPaid() async {
    final currentTrade = _trade;
    if (currentTrade.status != P2PTradeStatus.initiated) {
      return;
    }
    if (_pickedImages.isEmpty) {
      setState(() {
        _pickError = 'Upload at least one proof first.';
        _submissionError = null;
        _submissionSuccess = false;
      });
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isSubmitting = true;
      _submissionError = null;
      _submissionSuccess = false;
      _disputeError = null;
      _disputeSuccess = false;
    });

    try {
      debugPrint(
          '🔖 Confirm paid tapped for trade ${currentTrade.id} with ${_pickedImages.length} picked image(s)');
      final candidates = _prepareLocalProofs();
      final repository = ref.read(p2pRepositoryProvider);
      final plans = await repository.prepareTradeProofUploads(
        tradeId: currentTrade.id,
        files: candidates
            .map(
              (candidate) => P2PTradeProofUploadRequest(
                fileName: candidate.fileName,
                contentType: candidate.contentType,
              ),
            )
            .toList(growable: false),
      );

      if (plans.length != candidates.length) {
        throw ApiError(
            message: 'Couldn’t prepare proof uploads. Please try again.');
      }

      debugPrint(
          '📝 Received ${plans.length} presigned upload plan(s). Starting uploads...');
      await _performProofUploads(candidates, plans);

      final proofUrls =
          plans.map((plan) => plan.fileUrl).toList(growable: false);
      final message = _noteController.text.trim();

      final updatedTrade = await repository.markTradeAsPaid(
        tradeId: currentTrade.id,
        message: message.isEmpty ? null : message,
        proofUrls: proofUrls,
      );

      debugPrint('✅ Trade marked as paid. Proof URLs: ${proofUrls.length}');
      setState(() {
        _trade = updatedTrade;
        _pickedImages.clear();
        _submissionSuccess = true;
        _pickError = null;
        _submissionError = null;
        _disputeSuccess = false;
        _disputeError = null;
      });

      _noteController.clear();
      unawaited(_refreshOrdersSilently());
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _submissionError = _mapSubmissionError(error);
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Future<void> _refreshOrdersSilently() async {
    try {
      await ref.read(p2pOrdersControllerProvider.notifier).refresh();
    } catch (_) {
      // Best-effort refresh. Ignore errors to keep the sheet responsive.
    }
  }

  List<_ProofUploadCandidate> _prepareLocalProofs() {
    final results = <_ProofUploadCandidate>[];

    for (var i = 0; i < _pickedImages.length; i++) {
      final file = _pickedImages[i];
      final bytes = file.bytes;
      if (bytes == null || bytes.isEmpty) {
        throw ApiError(
            message:
                'One of the selected images could not be read. Please re-upload.');
      }

      final extension = _resolvePreferredExtension(file);
      final fileName = '${_sanitizeFileStem(file.name, i)}.$extension';
      final contentType = _resolveContentTypeFromExtension(extension);

      results.add(
        _ProofUploadCandidate(
          fileName: fileName,
          contentType: contentType,
          bytes: bytes,
        ),
      );
    }

    return results;
  }

  String _sanitizeFileStem(String name, int index) {
    final raw = name.split('.').first;
    final normalized = raw.replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '_');
    final collapsed = normalized.replaceAll(RegExp(r'_+'), '_').trim();
    final base = collapsed.isEmpty ? 'proof' : collapsed;
    final truncated = base.length > 40 ? base.substring(0, 40) : base;
    return '${truncated}_${index + 1}';
  }

  String _resolvePreferredExtension(PlatformFile file) {
    final ext = (file.extension ?? '').toLowerCase();
    if (ext == 'png') {
      return 'png';
    }
    if (ext == 'jpeg' || ext == 'jpg') {
      return 'jpg';
    }
    if (ext == 'heic' || ext == 'heif') {
      return 'jpg';
    }
    final lowerName = file.name.toLowerCase();
    if (lowerName.endsWith('.png')) {
      return 'png';
    }
    if (lowerName.endsWith('.jpg') || lowerName.endsWith('.jpeg')) {
      return 'jpg';
    }
    return 'jpg';
  }

  String _resolveContentTypeFromExtension(String extension) {
    switch (extension) {
      case 'png':
        return 'image/png';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      default:
        return 'application/octet-stream';
    }
  }

  String _mapSubmissionError(Object error) {
    if (error is ApiError) {
      final status = error.statusCode ?? 0;
      final message = error.message;

      if (status == 400) {
        if (message.toLowerCase().contains('already marked')) {
          return 'You already confirmed payment for this trade.';
        }
        return message.isNotEmpty
            ? message
            : 'We couldn’t submit those proofs. Please check and try again.';
      }

      if (status == 401 || status == 403) {
        return 'Your session expired. Please sign in again.';
      }

      if (status == 413) {
        return 'Those images are too large. Please upload photos under 5 MB each.';
      }

      if (status >= 500) {
        return 'Server issue while submitting your proofs. Please try again in a moment.';
      }

      return message.isNotEmpty
          ? message
          : 'We couldn’t submit your proofs right now.';
    }

    if (error is DioException) {
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.connectionError) {
        return 'Network issue while uploading. Check your connection and retry.';
      }
      return 'Upload failed. Please try again.';
    }

    return 'Something went wrong while submitting your proofs. Please try again.';
  }

  String _statusDescription(P2PTradeStatus status) {
    switch (status) {
      case P2PTradeStatus.paidByBuyer:
        return 'Payment sent. The seller has been notified. You’ll receive funds once they release the funds.';
      case P2PTradeStatus.releasedBySeller:
        return 'Seller confirmed payment. We’re releasing your funds shortly.';
      case P2PTradeStatus.completed:
        return 'Trade completed successfully. Funds should now reflect in your wallet.';
      case P2PTradeStatus.cancelled:
        return 'This trade was cancelled. Reach out to support if you need help.';
      case P2PTradeStatus.disputed:
        return 'This trade is under review. Our team will contact you if more details are needed.';
      case P2PTradeStatus.expired:
        return 'This trade expired before you confirmed payment.';
      case P2PTradeStatus.initiated:
        return 'Active trade.';
    }
  }

  String _safeString(dynamic value) {
    if (value == null) return '';
    final str = value.toString();
    return str.trim();
  }

  void _handleRemoveProof(int index) {
    setState(() {
      _pickedImages.removeAt(index);
      _pickError = null;
      _submissionError = null;
      _submissionSuccess = false;
    });
  }

  Future<void> _handlePickProofs() async {
    setState(() {
      _pickError = null;
      _submissionError = null;
      _submissionSuccess = false;
    });

    final remainingSlots = _maxImages - _pickedImages.length;
    if (remainingSlots <= 0) {
      setState(() {
        _pickError = 'You can upload up to $_maxImages images.';
      });
      return;
    }

    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.image,
        withData: true,
      );
      if (result == null) {
        return; // user cancelled
      }
      setState(() {
        _isPickingProofs = true;
      });

      final selected = result.files;
      final List<PlatformFile> accepted = [];
      int skippedLarge = 0;
      int skippedNoData = 0;

      for (final file in selected) {
        if (accepted.length >= remainingSlots) break;
        final size = file.size;
        final hasBytes = file.bytes != null && file.bytes!.isNotEmpty;
        if (size > _maxBytesPerImage) {
          skippedLarge++;
          continue;
        }
        if (!hasBytes) {
          skippedNoData++;
          continue;
        }
        accepted.add(file);
      }

      if (accepted.isEmpty && (skippedLarge > 0 || skippedNoData > 0)) {
        setState(() {
          _pickError = skippedLarge > 0
              ? 'Some images exceed 5 MB and were skipped.'
              : 'Couldn’t read selected files. Please try different images.';
        });
        return;
      }

      setState(() {
        _pickedImages.addAll(accepted);
        _submissionSuccess = false;
        if (skippedLarge > 0 || skippedNoData > 0) {
          _pickError = [
            if (skippedLarge > 0) 'Skipped $skippedLarge images over 5 MB',
            if (skippedNoData > 0) 'Skipped $skippedNoData unreadable files',
          ].join(' • ');
        }
      });
    } catch (e) {
      setState(() {
        _pickError = 'Couldn’t pick images. Please try again.';
      });
    } finally {
      if (mounted && _isPickingProofs) {
        setState(() {
          _isPickingProofs = false;
        });
      }
    }
  }

  Widget _buildProofPreview(TextTheme textTheme, {required bool allowRemove}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Proof of payment',
          style: textTheme.titleSmall?.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final file in List<PlatformFile>.from(_pickedImages))
              _ProofThumb(
                file: file,
                onRemove: allowRemove
                    ? () {
                        setState(() {
                          _pickedImages.remove(file);
                          _pickError = null;
                          _submissionError = null;
                          _submissionSuccess = false;
                        });
                      }
                    : null,
              ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          '${_pickedImages.length}/$_maxImages selected',
          style: textTheme.bodySmall?.copyWith(
            fontSize: 11,
            color: OpeiColors.iosLabelSecondary,
          ),
        ),
      ],
    );
  }
}

class _PaymentDetailRow extends StatelessWidget {
  final String label;
  final String value;
  final TextTheme textTheme;
  final bool isMonospace;

  const _PaymentDetailRow({
    required this.label,
    required this.value,
    required this.textTheme,
    this.isMonospace = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: textTheme.bodyMedium?.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: OpeiColors.iosLabelSecondary,
              letterSpacing: -0.1,
            ),
          ),
        ),
        Expanded(
          child: SelectableText(
            value,
            style: textTheme.bodyMedium?.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: isMonospace ? 0.2 : -0.2,
              fontFamily: isMonospace ? 'Courier' : null,
              color: OpeiColors.pureBlack,
            ),
          ),
        ),
      ],
    );
  }
}

class _ProofThumb extends StatelessWidget {
  final PlatformFile file;
  final VoidCallback? onRemove;

  const _ProofThumb({required this.file, this.onRemove});

  @override
  Widget build(BuildContext context) {
    final bytes = file.bytes;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            color: OpeiColors.iosSurfaceMuted,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: OpeiColors.iosSeparator.withValues(alpha: 0.3),
                width: 0.5),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: bytes != null && bytes.isNotEmpty
                ? Image.memory(bytes, fit: BoxFit.cover)
                : Center(
                    child: Icon(Icons.image_not_supported_outlined,
                        color: OpeiColors.iosLabelTertiary, size: 28),
                  ),
          ),
        ),
        if (onRemove != null)
          Positioned(
            top: -6,
            right: -6,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onRemove,
                customBorder: const CircleBorder(),
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, size: 14, color: Colors.white),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

Future<void> _presentProofSubmittedScreen(BuildContext context) async {
  await Navigator.of(context).push(
    PageRouteBuilder<void>(
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
      pageBuilder: (context, animation, secondaryAnimation) {
        return const ProofSubmittedScreen();
      },
      transitionsBuilder: (context, animation, secondaryAnimation, child) => child,
    ),
  );
}

class ProofSubmittedScreen extends StatefulWidget {
  const ProofSubmittedScreen({super.key});

  @override
  State<ProofSubmittedScreen> createState() => _ProofSubmittedScreenState();
}

class _ProofSubmittedScreenState extends State<ProofSubmittedScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleDone() async {
    if (_isNavigating) return;
    setState(() => _isNavigating = true);
    if (!mounted) return;
    context.go('/p2p?tab=orders');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaPadding = MediaQuery.of(context).padding;
    return Scaffold(
      backgroundColor: OpeiColors.pureWhite,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _fadeAnimation,
          builder: (context, child) => Opacity(
            opacity: _fadeAnimation.value,
            child: child,
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(24, 12, 24, 12 + mediaPadding.bottom),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.close_rounded,
                        size: 22, color: OpeiColors.pureBlack),
                    tooltip: 'Back to orders',
                    onPressed: _handleDone,
                  ),
                ),
                const Spacer(),
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: OpeiColors.iosSurfaceMuted,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 18,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    size: 44,
                    color: OpeiColors.pureBlack,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Proof submitted',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'We’ve notified the seller. They’ll review your proof and release the funds once they confirm payment.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 14,
                    color: OpeiColors.iosLabelSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: OpeiColors.iosSurfaceMuted.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: const BoxDecoration(
                              color: OpeiColors.pureWhite,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: const Icon(Icons.schedule_rounded,
                                size: 16, color: OpeiColors.pureBlack),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'What happens next?',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _ProofSubmittedBullet(
                        label: 'Seller reviews your payment proof.',
                      ),
                      const SizedBox(height: 6),
                      _ProofSubmittedBullet(
                        label:
                            'Once confirmed, the funds are released automatically.',
                      ),
                      const SizedBox(height: 6),
                      _ProofSubmittedBullet(
                        label:
                            'You’ll receive a notification for every update.',
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _handleDone,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: OpeiColors.pureBlack,
                      foregroundColor: OpeiColors.pureWhite,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18)),
                      elevation: 0,
                    ),
                    child: _isNavigating
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  OpeiColors.pureWhite),
                            ),
                          )
                        : Text(
                            'Done',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: OpeiColors.pureWhite,
                              letterSpacing: -0.2,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProofSubmittedBullet extends StatelessWidget {
  final String label;

  const _ProofSubmittedBullet({required this.label});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          width: 18,
          child: Text(
            '•',
            style: TextStyle(
              fontSize: 16,
              height: 1.2,
              color: OpeiColors.pureBlack,
            ),
          ),
        ),
        Expanded(
          child: Text(
            label,
            style: textTheme.bodySmall?.copyWith(
              fontSize: 12.5,
              color: OpeiColors.iosLabelSecondary,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

Future<bool> showP2PCancelTradeWarningDialog(BuildContext context) async {
  return await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          final theme = Theme.of(dialogContext);
          final textTheme = theme.textTheme;

          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text(
              'Cancel this trade?',
              style:
                  textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Do not cancel after sending money.',
                  style: textTheme.bodyMedium?.copyWith(
                    height: 1.45,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Canceling after payment may cause irreversible loss. Opei is not responsible for losses resulting from user cancellation after payment.',
                  style: textTheme.bodySmall?.copyWith(
                    height: 1.5,
                    color: const Color(0xFFD62E1F),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('Go back'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: OpeiColors.pureBlack,
                  foregroundColor: OpeiColors.pureWhite,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('I understand'),
              ),
            ],
          );
        },
      ) ??
      false;
}

class _ProofThumbLoading extends StatelessWidget {
  const _ProofThumbLoading();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(
        color: OpeiColors.iosSurfaceMuted,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: OpeiColors.iosSeparator.withValues(alpha: 0.3), width: 0.5),
      ),
      child: const Center(
        child: SizedBox(
          width: 26,
          height: 26,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation<Color>(OpeiColors.pureBlack),
          ),
        ),
      ),
    );
  }
}

class _ProofUploadCandidate {
  final String fileName;
  final String contentType;
  final Uint8List bytes;

  const _ProofUploadCandidate({
    required this.fileName,
    required this.contentType,
    required this.bytes,
  });
}

Future<void> _performProofUploads(
  List<_ProofUploadCandidate> candidates,
  List<P2PTradeProofUploadPlan> plans,
) async {
  final dio = Dio();

  for (var i = 0; i < candidates.length; i++) {
    final candidate = candidates[i];
    final plan = plans[i];
    final headers = Map<String, String>.from(plan.headers);

    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    debugPrint('📤 UPLOAD PROOF ${i + 1}/${candidates.length}');
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    debugPrint('🌐 URL: ${plan.uploadUrl}');
    debugPrint('📋 Method: PUT');
    debugPrint('📦 Body type: Uint8List (raw bytes)');
    debugPrint('📏 Body size: ${candidate.bytes.length} bytes');
    debugPrint('📄 Content-Type: ${candidate.contentType}');
    debugPrint('🔑 Headers from presign:');
    headers.forEach((key, value) {
      debugPrint('   - $key: $value');
    });

    final startTime = DateTime.now();
    try {
      debugPrint(
          '⏱️  Starting PUT request at ${startTime.toIso8601String()}...');

      final response = await dio.put<dynamic>(
        plan.uploadUrl,
        data: candidate.bytes,
        options: Options(
          headers: headers,
          validateStatus: (status) => true,
        ),
      );

      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);

      debugPrint('✅ PUT completed in ${duration.inMilliseconds}ms');
      debugPrint('📡 Response status: ${response.statusCode}');
      debugPrint('📨 Response headers:');
      response.headers.map.forEach((key, values) {
        debugPrint('   - $key: ${values.join(", ")}');
      });

      if (response.statusCode != 200 && response.statusCode != 204) {
        debugPrint('❌ Unexpected status code: ${response.statusCode}');
        debugPrint('📄 Response body: ${response.data}');
        throw ApiError(
          message: 'Upload failed with status ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }

      debugPrint('✅ Upload ${i + 1} succeeded');
    } on DioException catch (error) {
      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);

      debugPrint('❌ DioException after ${duration.inMilliseconds}ms');
      debugPrint('🔴 Error type: ${error.type}');
      debugPrint('🔴 Error message: ${error.message}');
      debugPrint('🔴 Response status: ${error.response?.statusCode}');
      debugPrint('🔴 Response headers:');
      error.response?.headers.map.forEach((key, values) {
        debugPrint('   - $key: ${values.join(", ")}');
      });
      debugPrint('🔴 Response body: ${error.response?.data}');

      throw ApiError(
        message: 'Failed to upload proof ${i + 1}. Please try again.',
        statusCode: error.response?.statusCode,
      );
    }
  }
}

class _UploadProofSheet extends StatelessWidget {
  final Future<void> Function() onConfirm;
  final VoidCallback onPickImages;
  final List<PlatformFile> pickedImages;
  final void Function(int) onRemoveImage;
  final TextEditingController noteController;
  final bool isSubmitting;
  final bool isPicking;
  final String? pickError;
  final String? submissionError;

  const _UploadProofSheet({
    required this.onConfirm,
    required this.onPickImages,
    required this.pickedImages,
    required this.onRemoveImage,
    required this.noteController,
    required this.isSubmitting,
    required this.isPicking,
    this.pickError,
    this.submissionError,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final hasImages = pickedImages.isNotEmpty;
    final canSubmit = hasImages && !isSubmitting && !isPicking;

    return Container(
      decoration: const BoxDecoration(
        color: OpeiColors.pureWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(24, 20, 24, 24 + bottomInset),
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: OpeiColors.iosSeparator.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Upload Proof',
              style: theme.textTheme.titleLarge?.copyWith(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Upload 1–3 clear images showing your payment confirmation',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: 14,
                color: OpeiColors.iosLabelSecondary,
              ),
            ),
            const SizedBox(height: 20),
            if (hasImages || isPicking) ...[
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (int i = 0; i < pickedImages.length; i++)
                    _ProofThumb(
                      file: pickedImages[i],
                      onRemove: isSubmitting ? null : () => onRemoveImage(i),
                    ),
                  if (isPicking) const _ProofThumbLoading(),
                ],
              ),
              const SizedBox(height: 16),
            ],
            if (pickedImages.length < 3)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: isSubmitting || isPicking ? null : onPickImages,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: OpeiColors.pureBlack,
                    side: BorderSide(
                      color: OpeiColors.iosSeparator.withValues(alpha: 0.5),
                      width: 1.5,
                    ),
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 18),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  icon:
                      const Icon(Icons.add_photo_alternate_outlined, size: 22),
                  label: Text(
                    hasImages ? 'Add more' : 'Choose images',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
              ),
            if (!hasImages)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Up to 3 images • Max 5 MB each',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 12,
                    color: OpeiColors.iosLabelSecondary,
                  ),
                ),
              ),
            if (pickError != null) ...[
              const SizedBox(height: 12),
              _MessageBanner(message: pickError!, isError: true),
            ],
            const SizedBox(height: 18),
            Text(
              'Note (optional)',
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: OpeiColors.iosLabelSecondary,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: noteController,
              enabled: !isSubmitting,
              maxLines: 3,
              minLines: 2,
              textInputAction: TextInputAction.newline,
              inputFormatters: [LengthLimitingTextInputFormatter(500)],
              decoration: InputDecoration(
                hintText: 'Add any details the seller should know',
                hintStyle: theme.textTheme.bodySmall?.copyWith(
                  color: OpeiColors.iosLabelTertiary,
                  fontSize: 14,
                ),
                filled: true,
                fillColor: OpeiColors.iosSurfaceMuted.withValues(alpha: 0.5),
                contentPadding: const EdgeInsets.all(14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: OpeiColors.pureBlack, width: 1.5),
                ),
              ),
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: 14,
                height: 1.4,
              ),
            ),
            if (submissionError != null) ...[
              const SizedBox(height: 12),
              _MessageBanner(message: submissionError!, isError: true),
            ],
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: canSubmit ? onConfirm : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: OpeiColors.pureBlack,
                  foregroundColor: OpeiColors.pureWhite,
                  disabledBackgroundColor:
                      OpeiColors.iosSeparator.withValues(alpha: 0.3),
                  disabledForegroundColor: OpeiColors.iosLabelTertiary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              OpeiColors.pureWhite),
                        ),
                      )
                    : Text(
                        'Submit Proof',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: OpeiColors.pureWhite,
                          letterSpacing: -0.3,
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
