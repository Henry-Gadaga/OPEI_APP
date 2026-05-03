import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:opei/core/providers/providers.dart';
import 'package:opei/data/models/full_profile_response.dart';
import 'package:opei/features/cards/cards_screen.dart';
import 'package:opei/features/dashboard/dashboard_controller.dart';
import 'package:opei/features/dashboard/dashboard_state.dart';
import 'package:opei/features/dashboard/widgets/transaction_widgets.dart';
import 'package:opei/features/deposit/deposit_screen.dart';
import 'package:opei/features/profile/profile_screen.dart';
import 'package:opei/features/transactions/transactions_screen.dart';
import 'package:opei/features/transactions/widgets/transaction_detail_sheet.dart';
import 'package:opei/features/withdraw/withdraw_screen.dart';
import 'package:opei/responsive/responsive_tokens.dart';
import 'package:opei/responsive/responsive_widgets.dart';
import 'package:opei/theme.dart';

// Matches the signup screen blue (OpeiBrand.primary family) for
// visual consistency across the whole app.
const _kHeroGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    Color(0xFF2257E0), // slightly deeper than primary for contrast at top
    Color(0xFF3D7BFF), // OpeiBrand.primary — signup button / field focus
    Color(0xFF6E9DFF), // OpeiBrand.primaryGradientEnd — lighter at base
  ],
  stops: [0.0, 0.50, 1.0],
);

// ============================================================
// ROOT SHELL — houses the 5-tab bottom nav
// ============================================================

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  void _goTo(int index) => setState(() => _selectedIndex = index);

  @override
  Widget build(BuildContext context) {
    final screens = [
      DashboardHomeScreen(
        onProfileTap: () => _goTo(3),
        onCardsTap: () => _goTo(1),
        onActivityTap: () => _goTo(2),
      ),
      const CardsScreen(),
      const TransactionsScreen(),
      const ProfileScreen(),
    ];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: IndexedStack(index: _selectedIndex, children: screens),
        bottomNavigationBar: _BottomNav(
          selectedIndex: _selectedIndex,
          onTap: _goTo,
        ),
      ),
    );
  }
}

// ============================================================
// HOME SCREEN
// ============================================================

class DashboardHomeScreen extends ConsumerStatefulWidget {
  final VoidCallback onProfileTap;
  final VoidCallback onCardsTap;
  final VoidCallback onActivityTap;

  const DashboardHomeScreen({
    super.key,
    required this.onProfileTap,
    required this.onCardsTap,
    required this.onActivityTap,
  });

  @override
  ConsumerState<DashboardHomeScreen> createState() =>
      _DashboardHomeScreenState();
}

class _DashboardHomeScreenState extends ConsumerState<DashboardHomeScreen> {
  bool _balanceHidden = false;

  @override
  Widget build(BuildContext context) {
    final dash = ref.watch(dashboardControllerProvider);
    final profile = ref.watch(profileControllerProvider);
    final controller = ref.read(dashboardControllerProvider.notifier);

    final walletReady = dash.wallet != null && !dash.showSkeleton;
    final txReady = dash.transactionsHydrated && !dash.showTransactionsSkeleton;
    final ready = walletReady && txReady;

    if (!dash.hasAttemptedInitialLoad) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.ensureBalanceLoaded();
      });
    }

    final tokens = context.responsiveTokens;
    final pad = tokens.horizontalPadding;
    final firstName = _firstName(profile.profile);

    final hasName = firstName.isNotEmpty;
    final greeting = _greetingForHour();

    final topSection = _TopFixedSection(
      pad: pad,
      firstName: hasName ? firstName : null,
      greeting: greeting,
      hasName: hasName,
      dash: dash,
      hidden: _balanceHidden,
      onToggleHidden: () =>
          setState(() => _balanceHidden = !_balanceHidden),
      onProfileTap: widget.onProfileTap,
      onAdd: () => showResponsiveBottomSheet(
        context: context,
        dismissOnBarrierTap: true,
        builder: (_) => const DepositOptionsSheet(),
      ),
      onSend: () => context.push('/send-money'),
      onWithdraw: () => showResponsiveBottomSheet(
        context: context,
        dismissOnBarrierTap: true,
        builder: (_) => const WithdrawOptionsSheet(),
      ),
      onCards: widget.onCardsTap,
    );

    final whitePanel = _ActivityWhitePanel(
      dash: dash,
      onRefresh: () => controller.refreshBalance(),
      onViewAll: widget.onActivityTap,
      onRetry: () => controller.refreshBalance(showSpinner: false),
    );

    return Container(
      decoration: const BoxDecoration(gradient: _kHeroGradient),
      child: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // ---- live content ----
            Opacity(
              opacity: ready ? 1 : 0,
              child: Column(
                children: [
                  topSection,
                  Expanded(child: whitePanel),
                ],
              ),
            ),
            // ---- loading skeleton ----
            IgnorePointer(
              ignoring: ready,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 340),
                curve: Curves.easeOut,
                opacity: ready ? 0 : 1,
                child: _HomeSkeleton(pad: pad),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _greetingForHour() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String _firstName(FullProfileResponse? p) {
    if (p == null) return '';
    final first = p.identity?.firstName.trim() ?? '';
    if (first.isNotEmpty) return first;
    final e = p.email;
    if (e.contains('@')) {
      final h = e.split('@').first;
      if (h.isNotEmpty) return h[0].toUpperCase() + h.substring(1);
    }
    return '';
  }
}

// ── Fixed top section: gradient stays, balance + actions are non-scroll ──

class _TopFixedSection extends StatelessWidget {
  final double pad;
  final String? firstName;
  final String greeting;
  final bool hasName;
  final DashboardState dash;
  final bool hidden;
  final VoidCallback onToggleHidden;
  final VoidCallback onProfileTap;
  final VoidCallback onAdd;
  final VoidCallback onSend;
  final VoidCallback onWithdraw;
  final VoidCallback onCards;

  const _TopFixedSection({
    required this.pad,
    required this.firstName,
    required this.greeting,
    required this.hasName,
    required this.dash,
    required this.hidden,
    required this.onToggleHidden,
    required this.onProfileTap,
    required this.onAdd,
    required this.onSend,
    required this.onWithdraw,
    required this.onCards,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(pad, 10, pad, 0),
          child: _TopBar(
            firstName: firstName,
            onProfileTap: onProfileTap,
          ),
        ),
        const SizedBox(height: 48),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: pad),
          child: _BalanceBlock(
            greeting: greeting,
            hasName: hasName,
            firstName: firstName ?? '',
            dash: dash,
            hidden: hidden,
            onToggle: onToggleHidden,
          ),
        ),
        const SizedBox(height: 52),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: pad),
          child: _ActionRow(
            onAdd: onAdd,
            onSend: onSend,
            onWithdraw: onWithdraw,
            onCards: onCards,
          ),
        ),
        const SizedBox(height: 28),
      ],
    );
  }
}

// ── Full-width white panel: rounded top, fills to bottom nav ─────────

class _ActivityWhitePanel extends StatelessWidget {
  final DashboardState dash;
  final Future<void> Function() onRefresh;
  final VoidCallback onViewAll;
  final VoidCallback onRetry;

  const _ActivityWhitePanel({
    required this.dash,
    required this.onRefresh,
    required this.onViewAll,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: Container(
        width: double.infinity,
        color: Colors.white,
        child: RefreshIndicator(
          color: OpeiBrand.primary,
          backgroundColor: Colors.white,
          displacement: 28,
          triggerMode: RefreshIndicatorTriggerMode.onEdge,
          onRefresh: onRefresh,
          child: _ActivityPanelContent(
            dash: dash,
            onViewAll: onViewAll,
            onRetry: onRetry,
          ),
        ),
      ),
    );
  }
}

class _ActivityPanelContent extends StatelessWidget {
  final DashboardState dash;
  final VoidCallback onViewAll;
  final VoidCallback onRetry;

  const _ActivityPanelContent({
    required this.dash,
    required this.onViewAll,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final transactions = dash.recentTransactions;
    final showSkeleton = dash.showTransactionsSkeleton;
    final mqBottom = MediaQuery.of(context).padding.bottom;

    Widget body;
    if (showSkeleton) {
      body = const Padding(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: TransactionsListSkeleton(itemCount: 6),
      );
    } else if (transactions.isEmpty) {
      if (dash.transactionsError != null) {
        body = _PanelErrorState(
          message: dash.transactionsError!,
          onRetry: onRetry,
        );
      } else {
        body = const _PanelEmptyState();
      }
    } else {
      body = AnimatedOpacity(
        duration: const Duration(milliseconds: 180),
        opacity: dash.isRefreshingTransactions ? 0.65 : 1,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          child: TransactionGroupsView(
            transactions: transactions,
            onTransactionTap: (tx) =>
                showTransactionDetailSheet(context, tx),
          ),
        ),
      );
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: EdgeInsets.fromLTRB(0, 18, 0, 24 + mqBottom),
      children: [
        // header
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 12, 12),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'Recent activity',
                  style: TextStyle(
                    fontFamily: kPrimaryFontFamily,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: OpeiBrand.ink,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              GestureDetector(
                onTap: onViewAll,
                behavior: HitTestBehavior.opaque,
                child: const Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'See all',
                        style: TextStyle(
                          fontFamily: kPrimaryFontFamily,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: OpeiBrand.primary,
                          letterSpacing: -0.1,
                        ),
                      ),
                      Icon(Icons.chevron_right_rounded,
                          size: 16, color: OpeiBrand.primary),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        body,
      ],
    );
  }
}

class _PanelEmptyState extends StatelessWidget {
  const _PanelEmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 32),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: OpeiBrand.surfaceMuted,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.receipt_long_rounded,
                size: 26, color: OpeiBrand.inkSecondary),
          ),
          const SizedBox(height: 14),
          const Text(
            'No transactions yet',
            style: TextStyle(
              fontFamily: kPrimaryFontFamily,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: OpeiBrand.ink,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Your money moves will appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: kPrimaryFontFamily,
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: OpeiBrand.inkSecondary,
              letterSpacing: -0.1,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _PanelErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _PanelErrorState(
      {required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF0F0),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.wifi_off_rounded,
                size: 26, color: OpeiBrand.danger),
          ),
          const SizedBox(height: 14),
          const Text(
            'Couldn\'t load activity',
            style: TextStyle(
              fontFamily: kPrimaryFontFamily,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: OpeiBrand.ink,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: kPrimaryFontFamily,
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: OpeiBrand.inkSecondary,
              letterSpacing: -0.1,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: onRetry,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                color: OpeiBrand.primaryTint,
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Text(
                'Try again',
                style: TextStyle(
                  fontFamily: kPrimaryFontFamily,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: OpeiBrand.primary,
                  letterSpacing: -0.1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Top bar: avatar (left) + notification (right), no wordmark ──────

class _TopBar extends StatelessWidget {
  final String? firstName;
  final VoidCallback onProfileTap;

  const _TopBar({this.firstName, required this.onProfileTap});

  @override
  Widget build(BuildContext context) {
    final initials = _initials(firstName ?? '');
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: onProfileTap,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              shape: BoxShape.circle,
              border: Border.all(
                  color: Colors.white.withValues(alpha: 0.20), width: 0.8),
            ),
            alignment: Alignment.center,
            child: initials.isEmpty
                ? const Icon(Icons.person_outline_rounded,
                    color: Colors.white, size: 19)
                : Text(
                    initials,
                    style: const TextStyle(
                      fontFamily: kPrimaryFontFamily,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
        _TopAction(
          icon: Icons.notifications_none_rounded,
          onTap: () {},
        ),
      ],
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }
}

class _TopAction extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _TopAction({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.16),
          shape: BoxShape.circle,
          border: Border.all(
              color: Colors.white.withValues(alpha: 0.20), width: 0.8),
        ),
        child: Icon(icon, size: 19, color: Colors.white),
      ),
    );
  }
}

// ── Centre: greeting + big balance ──────────────────────────────────

class _BalanceBlock extends StatelessWidget {
  final String greeting;
  final bool hasName;
  final String firstName;
  final DashboardState dash;
  final bool hidden;
  final VoidCallback onToggle;

  const _BalanceBlock({
    required this.greeting,
    required this.hasName,
    required this.firstName,
    required this.dash,
    required this.hidden,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final wallet = dash.wallet;
    final amount = wallet?.formattedAvailableBalance ?? r'$0.00';
    final reserved = wallet?.reservedBalance.format(includeCurrencySymbol: true);
    final hasHold = wallet != null && wallet.reservedBalance.cents > 0;
    final dimForRefresh = dash.isRefreshing && wallet != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Greeting label
        Text(
          hasName ? '$greeting, $firstName' : greeting,
          style: TextStyle(
            fontFamily: kPrimaryFontFamily,
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.white.withValues(alpha: 0.70),
            letterSpacing: -0.1,
          ),
        ),
        const SizedBox(height: 10),
        // Balance + eye toggle on same row
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              child: AnimatedOpacity(
                key: ValueKey(hidden ? 'h' : amount),
                duration: const Duration(milliseconds: 180),
                opacity: dimForRefresh ? 0.7 : 1,
                child: Text(
                  hidden ? '••••••' : amount,
                  style: const TextStyle(
                    fontFamily: kPrimaryFontFamily,
                    fontSize: 40,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -1.4,
                    height: 1.02,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: onToggle,
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Icon(
                  hidden
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: 18,
                  color: Colors.white.withValues(alpha: 0.70),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        // Compact wallet pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
                color: Colors.white.withValues(alpha: 0.18), width: 0.7),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.account_balance_wallet_outlined,
                  size: 12, color: Colors.white.withValues(alpha: 0.85)),
              const SizedBox(width: 5),
              Text(
                'USD Wallet',
                style: TextStyle(
                  fontFamily: kPrimaryFontFamily,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.9),
                  letterSpacing: -0.1,
                ),
              ),
              if (hasHold) ...[
                Container(
                  width: 1,
                  height: 12,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  color: Colors.white.withValues(alpha: 0.3),
                ),
                Icon(Icons.lock_outline_rounded,
                    size: 11, color: Colors.white.withValues(alpha: 0.85)),
                const SizedBox(width: 3),
                Text(
                  '$reserved held',
                  style: TextStyle(
                    fontFamily: kPrimaryFontFamily,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ],
          ),
        ),
        if (dash.error != null && dash.error!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            dash.error!,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: kPrimaryFontFamily,
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ],
      ],
    );
  }
}

// ── 4 action chips (dark frosted style) ─────────────────────────────

class _ActionRow extends StatelessWidget {
  final VoidCallback onAdd;
  final VoidCallback onSend;
  final VoidCallback onWithdraw;
  final VoidCallback onCards;

  const _ActionRow({
    required this.onAdd,
    required this.onSend,
    required this.onWithdraw,
    required this.onCards,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _ActionChip(icon: Icons.add_rounded, label: 'Add', onTap: onAdd),
        _ActionChip(
            icon: Icons.arrow_upward_rounded, label: 'Send', onTap: onSend),
        _ActionChip(
            icon: Icons.arrow_downward_rounded,
            label: 'Withdraw',
            onTap: onWithdraw),
        _ActionChip(
            icon: Icons.credit_card_rounded, label: 'Cards', onTap: onCards),
      ],
    );
  }
}

class _ActionChip extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ActionChip(
      {required this.icon, required this.label, required this.onTap});

  @override
  State<_ActionChip> createState() => _ActionChipState();
}

class _ActionChipState extends State<_ActionChip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _s;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 110));
    _s = Tween<double>(begin: 1.0, end: 0.93)
        .animate(CurvedAnimation(parent: _c, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _c.forward(),
      onTapUp: (_) {
        _c.reverse();
        widget.onTap();
      },
      onTapCancel: () => _c.reverse(),
      child: ScaleTransition(
        scale: _s,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(
                    color: Colors.white.withValues(alpha: 0.20), width: 0.7),
              ),
              child: Icon(widget.icon, color: Colors.white, size: 21),
            ),
            const SizedBox(height: 7),
            Text(
              widget.label,
              style: TextStyle(
                fontFamily: kPrimaryFontFamily,
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.88),
                letterSpacing: -0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// ============================================================
// SKELETON
// ============================================================

class _HomeSkeleton extends StatelessWidget {
  final double pad;
  const _HomeSkeleton({required this.pad});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // top bar
        Padding(
          padding: EdgeInsets.fromLTRB(pad, 10, pad, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              _P(w: 40, h: 40, r: 20),
              _P(w: 40, h: 40, r: 20),
            ],
          ),
        ),
        const SizedBox(height: 48),
        // balance block (centered)
        Column(
          children: const [
            _P(w: 140, h: 13, r: 8),
            SizedBox(height: 14),
            _P(w: 200, h: 40, r: 12),
            SizedBox(height: 14),
            _P(w: 120, h: 28, r: 999),
          ],
        ),
        const SizedBox(height: 52),
        // action chips
        Padding(
          padding: EdgeInsets.symmetric(horizontal: pad),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(
              4,
              (_) => Column(children: const [
                _P(w: 50, h: 50, r: 25),
                SizedBox(height: 7),
                _P(w: 38, h: 10, r: 6),
              ]),
            ),
          ),
        ),
        const SizedBox(height: 28),
        // expanding white panel
        Expanded(
          child: ClipRRect(
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(28)),
            child: Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: const [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _PLight(w: 120, h: 14, r: 8),
                      _PLight(w: 50, h: 12, r: 8),
                    ],
                  ),
                  SizedBox(height: 14),
                  TransactionsListSkeleton(itemCount: 4),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PLight extends StatelessWidget {
  final double w;
  final double h;
  final double r;
  const _PLight({required this.w, required this.h, required this.r});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: OpeiBrand.surfaceMuted,
        borderRadius: BorderRadius.circular(r),
      ),
    );
  }
}

// Pulse skeleton cell
class _P extends StatefulWidget {
  final double w;
  final double h;
  final double r;
  const _P({required this.w, required this.h, required this.r});

  @override
  State<_P> createState() => _PState();
}

class _PState extends State<_P> with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _a;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1500))
      ..repeat(reverse: true);
    _a = CurvedAnimation(parent: _c, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _a,
      builder: (context, child) => Container(
        width: widget.w,
        height: widget.h,
        decoration: BoxDecoration(
          color:
              Colors.white.withValues(alpha: 0.10 + 0.12 * _a.value),
          borderRadius: BorderRadius.circular(widget.r),
        ),
      ),
    );
  }
}

// ============================================================
// 5-TAB BOTTOM NAV (dark theme, matching the dark scaffold)
// ============================================================

class _BottomNav extends StatelessWidget {
  final int selectedIndex;
  final void Function(int) onTap;

  const _BottomNav({required this.selectedIndex, required this.onTap});

  static const _items = [
    _NavDef(Icons.home_outlined, Icons.home_rounded, 'Home'),
    _NavDef(Icons.credit_card_outlined, Icons.credit_card_rounded, 'Cards'),
    _NavDef(Icons.receipt_long_outlined, Icons.receipt_long_rounded, 'Activity'),
    _NavDef(Icons.person_outline_rounded, Icons.person_rounded, 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: OpeiBrand.hairline,
            width: 0.8,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: OpeiBrand.ink.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 56,
          child: Row(
            children: List.generate(_items.length, (i) {
              final item = _items[i];
              final active = selectedIndex == i;
              return Expanded(
                child: _NavTile(
                  item: item,
                  active: active,
                  onTap: () => onTap(i),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavDef {
  final IconData outline;
  final IconData filled;
  final String label;
  const _NavDef(this.outline, this.filled, this.label);
}

class _NavTile extends StatefulWidget {
  final _NavDef item;
  final bool active;
  final VoidCallback onTap;

  const _NavTile(
      {required this.item, required this.active, required this.onTap});

  @override
  State<_NavTile> createState() => _NavTileState();
}

class _NavTileState extends State<_NavTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _s;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 90));
    _s = Tween<double>(begin: 1.0, end: 0.88)
        .animate(CurvedAnimation(parent: _c, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const activeColor = OpeiBrand.primary;
    const inactiveColor = Color(0xFFB0B8CC); // muted grey

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _c.forward(),
      onTapUp: (_) {
        _c.reverse();
        widget.onTap();
      },
      onTapCancel: () => _c.reverse(),
      child: ScaleTransition(
        scale: _s,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Active dot indicator above icon
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: widget.active ? 20 : 0,
              height: 3,
              decoration: BoxDecoration(
                color: widget.active ? activeColor : Colors.transparent,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(height: 5),
            AnimatedScale(
              scale: widget.active ? 1.08 : 1.0,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              child: Icon(
                widget.active ? widget.item.filled : widget.item.outline,
                size: 22,
                color: widget.active ? activeColor : inactiveColor,
              ),
            ),
            const SizedBox(height: 3),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontFamily: kPrimaryFontFamily,
                fontSize: 9.5,
                fontWeight:
                    widget.active ? FontWeight.w700 : FontWeight.w500,
                color: widget.active ? activeColor : inactiveColor,
                letterSpacing: -0.1,
              ),
              child: Text(widget.item.label),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// Legacy nav kept for any remaining external references
// ============================================================

/// @deprecated — use [_BottomNav] via [DashboardScreen]
class WalletBottomNav extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;
  const WalletBottomNav(
      {super.key, required this.selectedIndex, required this.onItemTapped});

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

/// @deprecated — use [_NavTile] via [_BottomNav]
class NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const NavItem({
    super.key,
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
