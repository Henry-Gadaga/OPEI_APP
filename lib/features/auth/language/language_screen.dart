import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:opei/core/locale/app_locale_controller.dart';
import 'package:opei/l10n/app_localizations.dart';
import 'package:opei/theme.dart';
import 'package:opei/widgets/opei_premium/opei_premium.dart';

class LanguageScreen extends ConsumerStatefulWidget {
  const LanguageScreen({super.key});

  @override
  ConsumerState<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends ConsumerState<LanguageScreen>
    with SingleTickerProviderStateMixin {
  late String _selectedLanguage;
  bool _submitting = false;

  late final AnimationController _anim;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _selectedLanguage = ref.read(appLocaleControllerProvider).languageCode;

    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _fade = CurvedAnimation(parent: _anim, curve: Curves.easeIn);
    _anim.forward();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bottomInset = MediaQuery.of(context).viewPadding.bottom;

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
          child: FadeTransition(
            opacity: _fade,
            child: Padding(
              padding: EdgeInsets.fromLTRB(24, 12, 24, 18 + bottomInset),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Headline ───────────────────────────────────
                  Text(
                    l10n.languageChooseTitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: kPrimaryFontFamily,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: OpeiBrand.ink,
                      letterSpacing: -0.7,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l10n.languageChooseSubtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: kPrimaryFontFamily,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: OpeiBrand.inkSecondary,
                      letterSpacing: -0.1,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Language tiles ─────────────────────────────
                  _LanguageOptionTile(
                    title: l10n.languageEnglishTitle,
                    subtitle: l10n.languageEnglishSubtitle,
                    selected: _selectedLanguage == kLanguageEnglish,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _selectedLanguage = kLanguageEnglish);
                    },
                  ),
                  const SizedBox(height: 8),
                  _LanguageOptionTile(
                    title: l10n.languagePortugueseTitle,
                    subtitle: l10n.languagePortugueseSubtitle,
                    selected: _selectedLanguage == kLanguagePortuguese,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _selectedLanguage = kLanguagePortuguese);
                    },
                  ),

                  const Spacer(flex: 3),

                  // ── CTA ────────────────────────────────────────
                  OpeiPrimaryButton(
                    label: l10n.continueCta,
                    loading: _submitting,
                    onPressed: _submitting ? null : _continue,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _continue() async {
    setState(() => _submitting = true);
    try {
      await ref
          .read(appLocaleControllerProvider.notifier)
          .setLocalLanguage(_selectedLanguage);
      if (!mounted) return;
      context.go('/welcome');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }
}

class _LanguageOptionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _LanguageOptionTile({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? OpeiBrand.primaryTint : OpeiBrand.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? OpeiBrand.primary : OpeiBrand.hairlineStrong,
            width: selected ? 1.6 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: OpeiBrand.primary.withValues(alpha: 0.10),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: kPrimaryFontFamily,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: selected ? OpeiBrand.primary : OpeiBrand.ink,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontFamily: kPrimaryFontFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: OpeiBrand.inkTertiary,
                      letterSpacing: -0.1,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: selected ? OpeiBrand.primary : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected
                      ? OpeiBrand.primary
                      : OpeiBrand.hairlineStrong,
                  width: 1.5,
                ),
              ),
              child: selected
                  ? const Icon(
                      Icons.check_rounded,
                      size: 13,
                      color: Colors.white,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
