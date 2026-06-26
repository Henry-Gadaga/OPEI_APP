import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:opei/l10n/app_localizations.dart';
import 'package:opei/theme.dart';
import 'package:opei/widgets/opei_premium/opei_premium.dart';

/// Welcome / Get started — the first screen new users see.
/// Apple-quality banking aesthetic: pure white scaffold, prominent HQ logo
/// well-balanced in the upper-third, hero headline + soft subhead, and a
/// quiet bottom region with the primary CTA, sign-in shortcut, and legal text.
class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<double> _logoScale;
  late final Animation<Offset> _copySlide;
  late final Animation<Offset> _ctaSlide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 760),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _logoScale = Tween<double>(
      begin: 0.94,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _copySlide = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.15, 1.0, curve: Curves.easeOutCubic),
          ),
        );
    _ctaSlide = Tween<Offset>(begin: const Offset(0, 0.10), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.25, 1.0, curve: Curves.easeOutCubic),
          ),
        );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final media = MediaQuery.of(context);
    final bottomPad = media.viewPadding.bottom;
    // Wide lockup (mark + "Opei" wordmark, ~3.1:1). Sized by height; capped
    // so it never crowds the headline on small screens or feels heavy on big.
    final logoHeight = (media.size.height * 0.058).clamp(48.0, 64.0);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: OpeiBrand.surface,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: OpeiBrand.surface,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(24, 8, 24, 16 + bottomPad * 0),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: (constraints.maxHeight - 24).clamp(
                      0.0,
                      double.infinity,
                    ),
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // ── Brand block ──────────────────────────────────────────
                        const Spacer(flex: 6),
                        FadeTransition(
                          opacity: _fade,
                          child: SlideTransition(
                            position: _copySlide,
                            child: ScaleTransition(
                              scale: _logoScale,
                              child: Center(
                                child: Hero(
                                  tag: 'opei-logo',
                                  child: Image.asset(
                                    'assets/icons/second.png',
                                    height: logoHeight,
                                    fit: BoxFit.contain,
                                    filterQuality: FilterQuality.high,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const Spacer(flex: 6),

                        // ── Bottom CTA block ─────────────────────────────────────
                        FadeTransition(
                          opacity: _fade,
                          child: SlideTransition(
                            position: _ctaSlide,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                OpeiPrimaryButton(
                                  label: l10n.welcomeCreateAccount,
                                  trailingIcon: Icons.arrow_forward_rounded,
                                  onPressed: () => context.go('/signup'),
                                ),
                                const SizedBox(height: 14),
                                Wrap(
                                  alignment: WrapAlignment.center,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  spacing: 4,
                                  children: [
                                    Text(
                                      l10n.welcomeAlreadyHaveAccount,
                                      style: TextStyle(
                                        fontFamily: kPrimaryFontFamily,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                        color: OpeiBrand.inkSecondary,
                                        letterSpacing: -0.1,
                                      ),
                                    ),
                                    GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      onTap: () => context.go('/login'),
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 4,
                                        ),
                                        child: Text(
                                          l10n.welcomeSignIn,
                                          style: TextStyle(
                                            fontFamily: kPrimaryFontFamily,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: OpeiBrand.primary,
                                            letterSpacing: -0.1,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                _LegalText(
                                  onTerms: () => context.push('/terms'),
                                  onPrivacy: () => context.push('/privacy'),
                                  l10n: l10n,
                                ),
                              ],
                            ),
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
      ),
    );
  }
}

class _LegalText extends StatelessWidget {
  final VoidCallback onTerms;
  final VoidCallback onPrivacy;
  final AppLocalizations l10n;

  const _LegalText({
    required this.onTerms,
    required this.onPrivacy,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    const baseStyle = TextStyle(
      fontFamily: kPrimaryFontFamily,
      fontSize: 11.5,
      fontWeight: FontWeight.w400,
      color: OpeiBrand.inkTertiary,
      letterSpacing: -0.1,
      height: 1.4,
    );
    final linkStyle = baseStyle.copyWith(
      color: OpeiBrand.primary,
      fontWeight: FontWeight.w600,
    );

    return Center(
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: baseStyle,
          children: [
            TextSpan(text: l10n.welcomeLegalPrefix),
            WidgetSpan(
              alignment: PlaceholderAlignment.baseline,
              baseline: TextBaseline.alphabetic,
              child: GestureDetector(
                onTap: onTerms,
                child: Text(l10n.welcomeLegalTerms, style: linkStyle),
              ),
            ),
            TextSpan(text: l10n.welcomeLegalAnd),
            WidgetSpan(
              alignment: PlaceholderAlignment.baseline,
              baseline: TextBaseline.alphabetic,
              child: GestureDetector(
                onTap: onPrivacy,
                child: Text(l10n.welcomeLegalPrivacy, style: linkStyle),
              ),
            ),
            const TextSpan(text: '.'),
          ],
        ),
      ),
    );
  }
}
