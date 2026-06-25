import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:opei/core/network/api_error.dart';
import 'package:opei/core/providers/providers.dart';
import 'package:opei/theme.dart';
import 'package:opei/widgets/onboarding/onboarding_progress.dart';

class ApplyReferralScreen extends ConsumerStatefulWidget {
  const ApplyReferralScreen({super.key});

  @override
  ConsumerState<ApplyReferralScreen> createState() =>
      _ApplyReferralScreenState();
}

class _ApplyReferralScreenState extends ConsumerState<ApplyReferralScreen> {
  final TextEditingController _codeController = TextEditingController();
  bool _isApplying = false;
  bool _isCancelling = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _applyReferral() async {
    final rawCode = _codeController.text.trim();
    if (rawCode.isEmpty) {
      _showSnack('Enter a valid referral code', isError: true);
      return;
    }

    final stage = ref.read(authSessionProvider).userStage;
    if (stage?.toUpperCase() == 'VERIFIED') {
      _showSnack('Too late - already verified', isError: true);
      return;
    }

    setState(() => _isApplying = true);
    try {
      await ref.read(referralRepositoryProvider).applyReferralCode(rawCode);
      if (!mounted) return;
      _showSnack('Referral applied successfully.');
      context.go('/address');
    } on ApiError catch (error) {
      if (!mounted) return;
      _showSnack(_mapReferralError(error), isError: true);
    } catch (_) {
      if (!mounted) return;
      _showSnack('Try again later', isError: true);
    } finally {
      if (mounted) setState(() => _isApplying = false);
    }
  }

  void _skip() {
    context.go('/address');
  }

  Future<void> _cancelOnboarding() async {
    if (_isApplying || _isCancelling) return;

    final shouldCancel = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Cancel setup?'),
          content: const Text(
            'You will be signed out and returned to home. '
            'You can continue onboarding after logging in again.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Keep going'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Cancel setup'),
            ),
          ],
        );
      },
    );

    if (shouldCancel != true || !mounted) return;

    setState(() => _isCancelling = true);
    final authRepository = ref.read(authRepositoryProvider);
    final sessionNotifier = ref.read(authSessionProvider.notifier);

    try {
      await authRepository.logout();
    } catch (_) {
      // best-effort logout
    }

    sessionNotifier.clearSession();
    if (!mounted) return;
    context.go('/welcome');
  }

  String _mapReferralError(ApiError error) {
    final message = error.message.toLowerCase();
    if (error.statusCode == 400 && message.contains('invalid referral code')) {
      return 'Invalid code - check and try again';
    }
    if (error.statusCode == 400 &&
        message.contains('self-referral is not allowed')) {
      return 'You can\'t use your own code';
    }
    if (error.statusCode == 400) {
      return 'Enter a valid referral code';
    }
    if (error.statusCode == 403 && message.contains('before verification')) {
      return 'Too late - already verified';
    }
    if (error.statusCode == 409 && message.contains('already has a referrer')) {
      return 'You already have a referrer';
    }
    if (error.statusCode == 500) {
      return 'Try again later';
    }
    return error.message;
  }

  void _showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? OpeiBrand.danger : OpeiBrand.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final bottomPad = media.viewPadding.bottom;
    final isBusy = _isApplying || _isCancelling;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Apply referral'),
          actions: const [
            Padding(
              padding: EdgeInsets.only(right: 16),
              child: Center(
                child: OnboardingProgress(stage: OnboardingStage.address),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(24, 12, 24, 24 + bottomPad),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Got a referral code?',
                  style: TextStyle(
                    fontFamily: kPrimaryFontFamily,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: OpeiBrand.ink,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Optional step. You can only apply a referral before verification.',
                  style: TextStyle(
                    fontFamily: kPrimaryFontFamily,
                    fontSize: 14,
                    color: OpeiBrand.inkSecondary,
                  ),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _codeController,
                  textCapitalization: TextCapitalization.characters,
                  enabled: !_isApplying,
                  decoration: InputDecoration(
                    hintText: 'Paste code or https://opei.app/r/CODE',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        OpeiBrand.radiusField,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        OpeiBrand.radiusField,
                      ),
                      borderSide: const BorderSide(color: OpeiBrand.primary),
                    ),
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isBusy ? null : _applyReferral,
                    child: _isApplying
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Apply referral'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: isBusy ? null : _skip,
                    child: const Text('Skip for now'),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: TextButton(
                    onPressed: isBusy ? null : _cancelOnboarding,
                    child: const Text('Cancel setup'),
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
