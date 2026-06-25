import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opei/core/network/api_error.dart';
import 'package:opei/core/providers/providers.dart';
import 'package:opei/data/repositories/referral_repository.dart';
import 'package:opei/theme.dart';

class ReferralHubScreen extends ConsumerStatefulWidget {
  const ReferralHubScreen({super.key});

  @override
  ConsumerState<ReferralHubScreen> createState() => _ReferralHubScreenState();
}

class _ReferralHubScreenState extends ConsumerState<ReferralHubScreen> {
  MyReferralSummary? _summary;
  String? _error;
  bool _isLoading = true;
  bool _copied = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final s = await ref.read(referralRepositoryProvider).getMyReferral();
      if (!mounted) return;
      setState(() {
        _summary = s;
        _isLoading = false;
      });
    } on ApiError catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Could not load referral details. Try again.';
        _isLoading = false;
      });
    }
  }

  Future<void> _copyCode(String code) async {
    await Clipboard.setData(ClipboardData(text: code));
    if (!mounted) return;
    setState(() => _copied = true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Code copied to clipboard'),
        backgroundColor: OpeiBrand.ink,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(OpeiBrand.radiusCard),
        ),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      ),
    );
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _copied = false);
  }

  String _usd(int cents) => '\$${(cents / 100).toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).viewPadding.top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: OpeiBrand.surface,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: OpeiBrand.surface,
        body: RefreshIndicator(
          onRefresh: _load,
          color: OpeiBrand.primary,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              // ── Gradient header ──────────────────────────────────
              SliverToBoxAdapter(
                child: _Header(topPad: topPad),
              ),
              // ── Body ─────────────────────────────────────────────
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
                sliver: SliverList(
                  delegate: SliverChildListDelegate(
                    _buildBody(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildBody() {
    if (_isLoading) {
      return [
        const SizedBox(height: 80),
        const Center(
          child: CircularProgressIndicator(color: OpeiBrand.primary),
        ),
      ];
    }

    if (_error != null) {
      return [
        const SizedBox(height: 40),
        _ErrorState(message: _error!, onRetry: _load),
      ];
    }

    final s = _summary!;

    return [
      // ── Code card ─────────────────────────────────────────────
      _CodeCard(
        code: s.referralCode,
        copied: _copied,
        onCopy: () => _copyCode(s.referralCode),
      ),
      const SizedBox(height: 12),
      // ── Helper text ───────────────────────────────────────────
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 4),
        child: Text(
          'Share your code with friends. They enter it during signup.',
          style: TextStyle(
            fontFamily: kPrimaryFontFamily,
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: OpeiBrand.inkTertiary,
            height: 1.4,
          ),
        ),
      ),
      const SizedBox(height: 28),
      // ── Stats ─────────────────────────────────────────────────
      const Text(
        'YOUR STATS',
        style: TextStyle(
          fontFamily: kPrimaryFontFamily,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: OpeiBrand.inkTertiary,
          letterSpacing: 0.8,
        ),
      ),
      const SizedBox(height: 12),
      Row(
        children: [
          Expanded(
            child: _StatTile(
              icon: Icons.group_outlined,
              label: 'Invited',
              value: '${s.totalReferrals}',
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _StatTile(
              icon: Icons.check_circle_outline_rounded,
              label: 'Successful',
              value: '${s.successfulReferrals}',
            ),
          ),
        ],
      ),
      const SizedBox(height: 10),
      _StatTile(
        icon: Icons.attach_money_rounded,
        label: 'Total earned',
        value: _usd(s.totalEarnedCents),
        fullWidth: true,
      ),
    ];
  }
}

// ── Gradient header ───────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final double topPad;
  const _Header({required this.topPad});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180 + topPad,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E55D8), Color(0xFF3D7BFF), Color(0xFF6E9DFF)],
        ),
      ),
      child: Stack(
        children: [
          // decorative circles
          Positioned(
            top: -50,
            right: -40,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.07),
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            left: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),
          // content
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.arrow_back_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Refer & Earn',
                    style: TextStyle(
                      fontFamily: kPrimaryFontFamily,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.6,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Invite friends and earn rewards.',
                    style: TextStyle(
                      fontFamily: kPrimaryFontFamily,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withValues(alpha: 0.80),
                      letterSpacing: -0.1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Code card ─────────────────────────────────────────────────────────────────

class _CodeCard extends StatelessWidget {
  final String code;
  final bool copied;
  final VoidCallback onCopy;

  const _CodeCard({
    required this.code,
    required this.copied,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: OpeiBrand.primaryTint,
        borderRadius: BorderRadius.circular(OpeiBrand.radiusCard),
        border: Border.all(color: OpeiBrand.primaryTintStrong),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.confirmation_number_outlined,
            size: 16,
            color: OpeiBrand.primary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'YOUR CODE',
                  style: TextStyle(
                    fontFamily: kPrimaryFontFamily,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: OpeiBrand.primary,
                    letterSpacing: 0.7,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  code,
                  style: const TextStyle(
                    fontFamily: kPrimaryFontFamily,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: OpeiBrand.ink,
                    letterSpacing: 3,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: onCopy,
            child: AnimatedContainer(
              duration: OpeiBrand.motionFast,
              curve: OpeiBrand.motionCurve,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: copied ? OpeiBrand.success : OpeiBrand.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    copied ? Icons.check_rounded : Icons.copy_rounded,
                    color: Colors.white,
                    size: 13,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    copied ? 'Copied' : 'Copy',
                    style: const TextStyle(
                      fontFamily: kPrimaryFontFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Stat tile ─────────────────────────────────────────────────────────────────

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool fullWidth;

  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: OpeiBrand.surface,
        borderRadius: BorderRadius.circular(OpeiBrand.radiusCard),
        border: Border.all(color: OpeiBrand.hairline),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: OpeiBrand.surfaceMuted,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: OpeiBrand.inkSecondary),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontFamily: kPrimaryFontFamily,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: OpeiBrand.inkTertiary,
                  letterSpacing: -0.1,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontFamily: kPrimaryFontFamily,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: OpeiBrand.ink,
                  letterSpacing: -0.4,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Error state ───────────────────────────────────────────────────────────────

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: OpeiBrand.surfaceMuted,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.wifi_off_rounded,
            size: 24,
            color: OpeiBrand.inkSecondary,
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          'Couldn\'t load referral details',
          style: TextStyle(
            fontFamily: kPrimaryFontFamily,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: OpeiBrand.ink,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: kPrimaryFontFamily,
            fontSize: 13,
            color: OpeiBrand.inkSecondary,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: onRetry,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
              ),
            ),
          ),
        ),
      ],
    );
  }
}
