import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import 'package:opei/theme.dart';
import 'package:opei/widgets/opei_premium/opei_premium.dart';

/// Welcome / Get started — first screen new users see.
/// Premium banking aesthetic: pure white scaffold, real Opei logo, tight
/// single-line tagline, compact CTAs at the bottom.
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<double> _scale;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 720),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _scale = Tween<double>(begin: 0.96, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
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
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top spacer pushes the brand block to the visual center.
                const Spacer(flex: 4),
                FadeTransition(
                  opacity: _fade,
                  child: ScaleTransition(
                    scale: _scale,
                    child: Center(
                      child: Image.asset(
                        'assets/icons/second.png',
                        height: 80,
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.high,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                FadeTransition(
                  opacity: _fade,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      'Send, receive, save, and spend USD across 80+ countries.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: kPrimaryFontFamily,
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: OpeiBrand.inkSecondary,
                        letterSpacing: -0.2,
                        height: 1.4,
                      ),
                    ),
                  ),
                ),
                const Spacer(flex: 5),
                SlideTransition(
                  position: _slide,
                  child: FadeTransition(
                    opacity: _fade,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        OpeiPrimaryButton(
                          label: 'Create account',
                          trailingIcon: Icons.arrow_forward_rounded,
                          onPressed: () => context.go('/signup'),
                        ),
                        const SizedBox(height: 4),
                        Center(
                          child: OpeiSecondaryLink(
                            label: 'Already have an account?',
                            actionLabel: 'Sign in',
                            onTap: () => context.go('/login'),
                          ),
                        ),
                        const SizedBox(height: 6),
                        _LegalText(
                          onTerms: () => context.push('/terms'),
                          onPrivacy: () => context.push('/privacy'),
                        ),
                      ],
                    ),
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

class _LegalText extends StatelessWidget {
  final VoidCallback onTerms;
  final VoidCallback onPrivacy;

  const _LegalText({required this.onTerms, required this.onPrivacy});

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
            const TextSpan(text: 'By continuing you agree to our '),
            WidgetSpan(
              alignment: PlaceholderAlignment.baseline,
              baseline: TextBaseline.alphabetic,
              child: GestureDetector(
                onTap: onTerms,
                child: Text('Terms', style: linkStyle),
              ),
            ),
            const TextSpan(text: ' and '),
            WidgetSpan(
              alignment: PlaceholderAlignment.baseline,
              baseline: TextBaseline.alphabetic,
              child: GestureDetector(
                onTap: onPrivacy,
                child: Text('Privacy Policy', style: linkStyle),
              ),
            ),
            const TextSpan(text: '.'),
          ],
        ),
      ),
    );
  }
}
