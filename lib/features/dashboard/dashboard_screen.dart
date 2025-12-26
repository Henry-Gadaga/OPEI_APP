import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tt1/features/cards/cards_screen.dart';
import 'package:tt1/features/dashboard/dashboard_controller.dart';
import 'package:tt1/features/dashboard/dashboard_state.dart';
import 'package:tt1/features/dashboard/widgets/transaction_widgets.dart';
import 'package:tt1/features/dashboard/widgets/skeleton_pulse_scope.dart';
import 'package:tt1/features/deposit/deposit_screen.dart';
import 'package:tt1/features/profile/profile_screen.dart';
import 'package:tt1/features/transactions/widgets/transaction_detail_sheet.dart';
import 'package:tt1/features/withdraw/withdraw_screen.dart';
import 'package:tt1/theme.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      DashboardHomeScreen(
        onProfileTap: () => setState(() => _selectedIndex = 2),
        onCardsTap: () => setState(() => _selectedIndex = 1),
      ),
      const CardsScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: screens[_selectedIndex],
      bottomNavigationBar: WalletBottomNav(
        selectedIndex: _selectedIndex,
        onItemTapped: (index) => setState(() => _selectedIndex = index),
      ),
    );
  }
}

class DashboardHomeScreen extends ConsumerWidget {
  final VoidCallback onProfileTap;
  final VoidCallback onCardsTap;

  const DashboardHomeScreen({super.key, required this.onProfileTap, required this.onCardsTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardState = ref.watch(dashboardControllerProvider);
    final controller = ref.read(dashboardControllerProvider.notifier);
    final platform = Theme.of(context).platform;
    final isCupertino = platform == TargetPlatform.iOS || platform == TargetPlatform.macOS;
    final scrollPhysics = AlwaysScrollableScrollPhysics(
      parent: isCupertino ? const BouncingScrollPhysics() : const ClampingScrollPhysics(),
    );
    final isSkeleton = dashboardState.showSkeleton;

    if (!dashboardState.hasAttemptedInitialLoad) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.ensureBalanceLoaded();
      });
    }

    final Widget content = isSkeleton
        ? const DashboardHomeSkeleton()
        : Column(
            children: [
              const SizedBox(height: 12),
              WalletHeader(onProfileTap: onProfileTap),
              const SizedBox(height: 60),
              BalanceCard(state: dashboardState),
              const SizedBox(height: 28),
              QuickActions(onCardsTap: onCardsTap),
              const SizedBox(height: 28),
              TransactionsList(
                state: dashboardState,
                onViewAll: () {
                  context.push('/transactions');
                },
                onRetry: () {
                  controller.refreshBalance(showSpinner: false);
                },
              ),
              const SizedBox(height: 24),
            ],
          );

    return SafeArea(
      child: RefreshIndicator(
        color: OpeiColors.pureBlack,
        backgroundColor: OpeiColors.pureWhite,
        displacement: 25,
        triggerMode: RefreshIndicatorTriggerMode.onEdge,
        onRefresh: () => controller.refreshBalance(),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: SingleChildScrollView(
            key: ValueKey(isSkeleton ? 'dashboard-skeleton' : 'dashboard-content'),
            physics: scrollPhysics,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: content,
            ),
          ),
        ),
      ),
    );
  }
}

class WalletHeader extends StatelessWidget {
  final VoidCallback onProfileTap;

  const WalletHeader({super.key, required this.onProfileTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Opei',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.3,
              ),
        ),
        GestureDetector(
          onTap: onProfileTap,
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: OpeiColors.grey200,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person_outline, color: OpeiColors.pureBlack, size: 18),
          ),
        ),
      ],
    );
  }
}

class BalanceCard extends StatelessWidget {
  final DashboardState state;

  const BalanceCard({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final wallet = state.wallet;
    final displayText = wallet?.formattedAvailableBalance ?? r'$0.00';
    final showSkeleton = state.showSkeleton;
    final dimForRefresh = state.isRefreshing && wallet != null;

    Widget valueWidget;

    if (showSkeleton) {
      valueWidget = Container(
        key: const ValueKey('balance-skeleton'),
        width: 160,
        height: 48,
        decoration: BoxDecoration(
          color: OpeiColors.iosSurfaceMuted,
          borderRadius: BorderRadius.circular(16),
        ),
      );
    } else {
      valueWidget = AnimatedOpacity(
        key: ValueKey(displayText),
        duration: const Duration(milliseconds: 200),
        opacity: dimForRefresh ? 0.65 : 1,
        child: Text(
          displayText,
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontSize: 40,
                fontWeight: FontWeight.w600,
                letterSpacing: -1.0,
              ),
        ),
      );
    }

    return Column(
      children: [
        Text(
          'Available Balance',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: 13,
                color: OpeiColors.iosLabelSecondary,
              ),
        ),
        const SizedBox(height: 6),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          child: valueWidget,
        ),
        if (state.error != null && state.error!.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            state.error!,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 12,
                  color: OpeiColors.errorRed,
                ),
          ),
        ],
      ],
    );
  }
}

class QuickActions extends StatelessWidget {
  final VoidCallback onCardsTap;

  const QuickActions({super.key, required this.onCardsTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ActionButton(
          icon: Icons.add,
          label: 'Add Money',
          onTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => const DepositOptionsSheet(),
            );
          },
        ),
        ActionButton(icon: Icons.arrow_upward, label: 'Send', onTap: () => context.push('/send-money')),
        ActionButton(
          icon: Icons.arrow_downward,
          label: 'Withdraw',
          onTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => const WithdrawOptionsSheet(),
            );
          },
        ),
        ActionButton(icon: Icons.credit_card, label: 'Cards', onTap: onCardsTap),
      ],
    );
  }
}

class ActionButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const ActionButton({super.key, required this.icon, required this.label, required this.onTap});

  @override
  State<ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<ActionButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.90).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
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
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: OpeiColors.iosSurfaceMuted,
                shape: BoxShape.circle,
              ),
              child: Icon(widget.icon, color: OpeiColors.pureBlack, size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              widget.label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontSize: 11,
                    color: OpeiColors.iosLabelSecondary,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class TransactionsList extends StatelessWidget {
  final DashboardState state;
  final VoidCallback onViewAll;
  final VoidCallback onRetry;

  const TransactionsList({super.key, required this.state, required this.onViewAll, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final transactions = state.recentTransactions;
    final showSkeleton = state.showTransactionsSkeleton;
    final subtitleStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
          fontSize: 12,
          color: OpeiColors.iosLabelSecondary,
        );

    Widget content;

    if (showSkeleton) {
      content = const TransactionsListSkeleton(itemCount: 5);
    } else if (transactions.isEmpty) {
      if (state.transactionsError != null) {
        content = Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              Text(
                state.transactionsError!,
                textAlign: TextAlign.center,
                style: subtitleStyle?.copyWith(color: OpeiColors.errorRed, fontSize: 13),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: onRetry,
                child: const Text('Try again'),
              ),
            ],
          ),
        );
      } else {
        content = Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            children: [
              Icon(Icons.receipt_long, size: 28, color: OpeiColors.iosLabelTertiary),
              const SizedBox(height: 12),
              Text(
                'No transactions yet',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(fontSize: 15, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 4),
              Text(
                'Activity will appear here as soon as it happens.',
                textAlign: TextAlign.center,
                style: subtitleStyle,
              ),
            ],
          ),
        );
      }
    } else {
      content = Column(
        children: transactions.asMap().entries.map((entry) {
          final isLast = entry.key == transactions.length - 1;
          final transaction = entry.value;
          return WalletTransactionTile(
            transaction: transaction,
            showDivider: !isLast,
            onTap: () => showTransactionDetailSheet(context, transaction),
          );
        }).toList(),
      );
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Transactions',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
            ),
            TextButton(
              onPressed: onViewAll,
              style: TextButton.styleFrom(
                foregroundColor: OpeiColors.iosLabelSecondary,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
              ),
              child: const Text('View all'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: OpeiColors.pureWhite,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: OpeiColors.pureBlack.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 180),
            opacity: state.isRefreshingTransactions ? 0.65 : 1,
            child: content,
          ),
        ),
      ],
    );
  }
}

class DashboardHomeSkeleton extends StatelessWidget {
  const DashboardHomeSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            _SkeletonBox(width: 72, height: 22),
            _SkeletonCircle(size: 32),
          ],
        ),
        const SizedBox(height: 40),
        const _BalanceCardSkeleton(),
        const SizedBox(height: 28),
        const _QuickActionsSkeleton(),
        const SizedBox(height: 28),
        Container(
          decoration: BoxDecoration(
            color: OpeiColors.pureWhite,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: OpeiColors.pureBlack.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
          child: const TransactionsListSkeleton(itemCount: 5),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _QuickActionsSkeleton extends StatelessWidget {
  const _QuickActionsSkeleton();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(
        4,
        (_) => Column(
          children: const [
            _SkeletonCircle(size: 56),
            SizedBox(height: 8),
            _SkeletonBox(width: 44, height: 10),
          ],
        ),
      ),
    );
  }
}

class _BalanceCardSkeleton extends StatelessWidget {
  const _BalanceCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        _SkeletonBox(width: 110, height: 14),
        SizedBox(height: 12),
        _SkeletonBox(width: 180, height: 48, radius: 18),
      ],
    );
  }
}

class _SkeletonBox extends StatefulWidget {
  final double width;
  final double height;
  final double radius;

  const _SkeletonBox({
    required this.width,
    required this.height,
    this.radius = 12,
  });

  @override
  State<_SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<_SkeletonBox> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
    _pulse = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const baseColor = OpeiColors.iosSurfaceMuted;
    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, child) {
        final opacity = 0.35 + (0.25 * _pulse.value);
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: baseColor.withOpacity(opacity),
            borderRadius: BorderRadius.circular(widget.radius),
          ),
        );
      },
    );
  }
}

class _SkeletonCircle extends StatefulWidget {
  final double size;

  const _SkeletonCircle({required this.size});

  @override
  State<_SkeletonCircle> createState() => _SkeletonCircleState();
}

class _SkeletonCircleState extends State<_SkeletonCircle> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
    _pulse = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const baseColor = OpeiColors.iosSurfaceMuted;
    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, child) {
        final opacity = 0.35 + (0.25 * _pulse.value);
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: baseColor.withOpacity(opacity),
            borderRadius: BorderRadius.circular(widget.size / 2),
          ),
        );
      },
    );
  }
}

class WalletBottomNav extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const WalletBottomNav({super.key, required this.selectedIndex, required this.onItemTapped});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: OpeiColors.pureWhite,
        border: Border(
          top: BorderSide(
            color: OpeiColors.iosSeparator.withValues(alpha: 0.3),
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              NavItem(
                icon: Icons.home_outlined,
                activeIcon: Icons.home,
                label: 'Home',
                isActive: selectedIndex == 0,
                onTap: () => onItemTapped(0),
              ),
              NavItem(
                icon: Icons.credit_card_outlined,
                activeIcon: Icons.credit_card,
                label: 'Cards',
                isActive: selectedIndex == 1,
                onTap: () => onItemTapped(1),
              ),
              NavItem(
                icon: Icons.person_outline,
                activeIcon: Icons.person,
                label: 'Profile',
                isActive: selectedIndex == 2,
                onTap: () => onItemTapped(2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NavItem extends StatefulWidget {
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
  State<NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<NavItem> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.6).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
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
      child: FadeTransition(
        opacity: _opacityAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  widget.isActive ? widget.activeIcon : widget.icon,
                  color: widget.isActive
                      ? OpeiColors.pureBlack
                      : OpeiColors.iosLabelSecondary,
                  size: 24,
                ),
                const SizedBox(height: 2),
                Text(
                  widget.label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontSize: 9,
                        color: widget.isActive
                            ? OpeiColors.pureBlack
                            : OpeiColors.iosLabelSecondary,
                        fontWeight: FontWeight.w500,
                        letterSpacing: -0.1,
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
