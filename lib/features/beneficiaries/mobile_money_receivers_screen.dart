import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opei/core/navigation/opei_page_transitions.dart';
import 'package:opei/data/models/beneficiary.dart';
import 'package:opei/features/beneficiaries/beneficiaries_controller.dart';
import 'package:opei/features/beneficiaries/mobile_money_beneficiaries_sheet.dart'
    show MobileMoneyAddReceiverSheet;
import 'package:opei/features/beneficiaries/send/send_amount_screen.dart';
import 'package:opei/l10n/app_localizations.dart';
import 'package:opei/theme.dart';
import 'package:opei/widgets/opei_premium/opei_app_bar.dart';

class MobileMoneyReceiversScreen extends ConsumerStatefulWidget {
  final String country;
  final String countryName;
  final String flag;

  const MobileMoneyReceiversScreen({
    super.key,
    required this.country,
    required this.countryName,
    required this.flag,
  });

  @override
  ConsumerState<MobileMoneyReceiversScreen> createState() =>
      _MobileMoneyReceiversScreenState();
}

class _MobileMoneyReceiversScreenState
    extends ConsumerState<MobileMoneyReceiversScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref
          .read(beneficiariesControllerProvider(widget.country).notifier)
          .load();
    });
  }

  Future<void> _openAddReceiverSheet() async {
    final added = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MobileMoneyAddReceiverSheet(
        country: widget.country,
        countryName: widget.countryName,
        flag: widget.flag,
      ),
    );
    if (added == true && mounted) {
      ref
          .read(beneficiariesControllerProvider(widget.country).notifier)
          .load();
    }
  }

  void _onReceiverTap(Beneficiary b) {
    Navigator.of(context).push(
      OpeiPageRoute(
        builder: (_) => SendAmountScreen(
          beneficiary: b,
          countryName: widget.countryName,
          flag: widget.flag,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(beneficiariesControllerProvider(widget.country));
    final controller =
        ref.read(beneficiariesControllerProvider(widget.country).notifier);

    return Scaffold(
      backgroundColor: OpeiBrand.surface,
      appBar: const OpeiAppBar(),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          color: OpeiBrand.primary,
          onRefresh: controller.load,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              // ── Header ─────────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets.fromLTRB(20, 6, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: OpeiBrand.surfaceMuted,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: OpeiBrand.hairline,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              widget.flag,
                              style: const TextStyle(fontSize: 22),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  widget.countryName,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: OpeiBrand.ink,
                                    letterSpacing: -0.5,
                                    height: 1.1,
                                  ),
                                ),
                                const SizedBox(height: 1),
                                Text(
                                  AppLocalizations.of(context)!
                                      .mobileMoneyReceiversSubtitle,
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w500,
                                    color: OpeiBrand.inkSecondary,
                                    letterSpacing: -0.1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (state.isLoading)
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 1.8,
                                color: OpeiBrand.primary,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Add receiver button
                      _AddReceiverButton(onTap: _openAddReceiverSheet),
                    ],
                  ),
                ),
              ),

              // ── Section label ──────────────────────────────────────────
              if (state.items.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                    child: Text(
                      AppLocalizations.of(context)!.savedReceiversLabel,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: OpeiBrand.inkTertiary,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ),

              // ── List / loading / empty / error ─────────────────────────
              if (state.isLoading && state.items.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: _LoadingBlock(),
                )
              else if (state.error != null)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _ErrorBlock(
                    message: state.error!,
                    onRetry: controller.load,
                  ),
                )
              else if (state.items.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: _EmptyBlock(),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                  sliver: SliverList.separated(
                    itemCount: state.items.length,
                    separatorBuilder: (context, i) => const Divider(
                      height: 1,
                      thickness: 0.5,
                      color: OpeiBrand.hairline,
                    ),
                    itemBuilder: (context, i) {
                      final b = state.items[i];
                      return _ReceiverRow(
                        beneficiary: b,
                        onTap: () => _onReceiverTap(b),
                        isFirst: i == 0,
                        isLast: i == state.items.length - 1,
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _AddReceiverButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AddReceiverButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: OpeiBrand.primaryTint,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        splashColor: OpeiBrand.primary.withValues(alpha: 0.06),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: OpeiBrand.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.add_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.addNewReceiverTitle,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: OpeiBrand.primary,
                        letterSpacing: -0.2,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      AppLocalizations.of(context)!
                          .mobileMoneyAddReceiverSubtitle,
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                        color: OpeiBrand.primary,
                        letterSpacing: -0.1,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: OpeiBrand.primary,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReceiverRow extends StatelessWidget {
  final Beneficiary beneficiary;
  final VoidCallback onTap;
  final bool isFirst;
  final bool isLast;

  const _ReceiverRow({
    required this.beneficiary,
    required this.onTap,
    this.isFirst = false,
    this.isLast = false,
  });

  String _initials(String? name) {
    if (name == null || name.trim().isEmpty) return '?';
    final parts = name.trim().split(RegExp(r'\s+'));
    final first = parts.first.characters.first;
    final last = parts.length > 1 ? parts.last.characters.first : '';
    return (first + last).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final name = beneficiary.accountName ?? 'Unnamed receiver';
    final masked = beneficiary.accountNumberMasked ?? '';

    final radius = BorderRadius.only(
      topLeft: Radius.circular(isFirst ? 14 : 0),
      topRight: Radius.circular(isFirst ? 14 : 0),
      bottomLeft: Radius.circular(isLast ? 14 : 0),
      bottomRight: Radius.circular(isLast ? 14 : 0),
    );

    return Material(
      color: OpeiBrand.surfaceMuted,
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        splashColor: OpeiBrand.primary.withValues(alpha: 0.04),
        highlightColor: OpeiBrand.hairline,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: OpeiBrand.primaryTint,
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Center(
                  child: Text(
                    _initials(beneficiary.accountName),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: OpeiBrand.primary,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: OpeiBrand.ink,
                        letterSpacing: -0.2,
                        height: 1.15,
                      ),
                    ),
                    if (masked.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        masked,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: OpeiBrand.inkSecondary,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: OpeiBrand.primary,
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  AppLocalizations.of(context)!.dashboardActionSend,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.1,
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

class _LoadingBlock extends StatelessWidget {
  const _LoadingBlock();
  @override
  Widget build(BuildContext context) => const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: OpeiBrand.primary,
        ),
      );
}

class _EmptyBlock extends StatelessWidget {
  const _EmptyBlock();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: OpeiBrand.primaryTint,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.people_alt_outlined,
              color: OpeiBrand.primary,
              size: 28,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.mobileMoneyNoReceiversTitle,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: OpeiBrand.ink,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            AppLocalizations.of(context)!.mobileMoneyNoReceiversHint,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: OpeiBrand.inkSecondary,
              letterSpacing: -0.1,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorBlock extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorBlock({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: OpeiBrand.danger.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(99),
            ),
            child: const Icon(
              Icons.error_outline_rounded,
              color: OpeiBrand.danger,
              size: 24,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            AppLocalizations.of(context)!.couldNotLoadReceivers,
            style: const TextStyle(
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
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: OpeiBrand.inkSecondary,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: onRetry,
            style: OutlinedButton.styleFrom(
              foregroundColor: OpeiBrand.primary,
              side: const BorderSide(color: OpeiBrand.primary, width: 1),
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(99)),
            ),
            child: Text(
              AppLocalizations.of(context)!.tryAgainCta,
              style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
