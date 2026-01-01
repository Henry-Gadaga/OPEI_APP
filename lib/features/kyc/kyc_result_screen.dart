import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tt1/core/providers/providers.dart';
import 'package:tt1/core/utils/error_helper.dart';
import 'package:tt1/theme.dart';

class KycResultScreen extends ConsumerStatefulWidget {
  const KycResultScreen({super.key});

  @override
  ConsumerState<KycResultScreen> createState() => _KycResultScreenState();
}

enum _KycOutcome {
  loading,
  approved,
  review,
  declined,
  error,
}

class _KycResultScreenState extends ConsumerState<KycResultScreen> {
  _KycOutcome _outcome = _KycOutcome.loading;
  String? _errorMessage;
  bool _isActionInFlight = false;

  @override
  void initState() {
    super.initState();
    _refreshStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Identity Verification'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _buildContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    switch (_outcome) {
      case _KycOutcome.loading:
        return const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Checking your verification status...'),
            ],
          ),
        );
      case _KycOutcome.error:
        return _buildErrorView();
      case _KycOutcome.approved:
        return _buildResultCard(
          icon: Icons.verified,
          iconColor: OpeiColors.successGreen,
          title: 'KYC approved',
          message: 'You’re fully verified. Set your PIN to finish onboarding.',
          buttonLabel: 'Continue',
          onPressed: _handleContinueToPinSetup,
        );
      case _KycOutcome.review:
        return _buildResultCard(
          icon: Icons.watch_later_outlined,
          iconColor: OpeiColors.warningYellow,
          title: 'Under review',
          message: 'We’ll email you within 24 hours once the review finishes.',
          buttonLabel: 'Done',
          onPressed: _handleReturnToLogin,
        );
      case _KycOutcome.declined:
        return _buildResultCard(
          icon: Icons.error_outline,
          iconColor: OpeiColors.errorRed,
          title: 'KYC declined',
          message:
              'Check your email for the reason and next steps, or contact support if you need help.',
          buttonLabel: 'Retry verification',
          onPressed: _handleRetryVerification,
        );
    }
  }

  Widget _buildErrorView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.wifi_off, size: 64, color: OpeiColors.errorRed),
        const SizedBox(height: 24),
        Text(
          _errorMessage ?? 'Unable to fetch your status. Please try again.',
          style: Theme.of(context).textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _refreshStatus,
            child: const Text('Try again'),
          ),
        ),
      ],
    );
  }

  Widget _buildResultCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String message,
    required String buttonLabel,
    required VoidCallback onPressed,
  }) {
    final theme = Theme.of(context);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 44, color: iconColor),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 13,
                    height: 1.4,
                    color: OpeiColors.grey700,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 260,
              child: ElevatedButton(
                onPressed: _isActionInFlight ? null : onPressed,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _isActionInFlight
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        buttonLabel,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _refreshStatus() async {
    setState(() {
      _outcome = _KycOutcome.loading;
      _errorMessage = null;
    });

    try {
      await Future.delayed(const Duration(seconds: 3));
      if (!mounted) return;

      final session = await ref.read(kycRepositoryProvider).getSessionStatus();
      final outcome = _mapStatusToOutcome(session.status);
      _syncSessionStage(outcome);

      if (!mounted) return;
      setState(() {
        _outcome = outcome;
      });
    } catch (e) {
      final message = ErrorHelper.getErrorMessage(e);
      if (!mounted) return;
      setState(() {
        _outcome = _KycOutcome.error;
        _errorMessage = message;
      });
    }
  }

  _KycOutcome _mapStatusToOutcome(String? status) {
    final normalized = status?.toUpperCase().trim();
    if (normalized == null) return _KycOutcome.review;

    const approvedStatuses = {
      'APPROVED',
      'VERIFIED',
      'KYC_APPROVED',
      'COMPLETED',
      'SUCCESS',
      'PASSED',
    };

    const reviewStatuses = {
      'PENDING',
      'PENDING_KYC',
      'IN_PROGRESS',
      'REVIEW',
      'UNDER_REVIEW',
      'PROCESSING',
      'WAITING_REVIEW',
    };

    const declinedStatuses = {
      'DECLINED',
      'FAILED',
      'REJECTED',
      'DENIED',
      'KYC_DECLINED',
      'KYC_FAILED',
    };

    if (approvedStatuses.contains(normalized)) {
      return _KycOutcome.approved;
    }
    if (declinedStatuses.contains(normalized)) {
      return _KycOutcome.declined;
    }
    if (reviewStatuses.contains(normalized)) {
      return _KycOutcome.review;
    }

    return _KycOutcome.review;
  }

  void _syncSessionStage(_KycOutcome outcome) {
    final notifier = ref.read(authSessionProvider.notifier);
    switch (outcome) {
      case _KycOutcome.approved:
        notifier.updateUserStage('VERIFIED');
        break;
      case _KycOutcome.review:
      case _KycOutcome.declined:
        notifier.updateUserStage('PENDING_KYC');
        break;
      case _KycOutcome.loading:
      case _KycOutcome.error:
        break;
    }
  }

  Future<void> _handleContinueToPinSetup() async {
    if (!mounted) return;
    context.go('/quick-auth-setup');
  }

  Future<void> _handleReturnToLogin() async {
    if (_isActionInFlight) return;
    setState(() => _isActionInFlight = true);
    try {
      await ref.read(authRepositoryProvider).logout();
    } catch (_) {
      // Ignore logout errors; we only need to clear the local session.
    }
    ref.read(authSessionProvider.notifier).clearSession();
    if (!mounted) return;
    setState(() => _isActionInFlight = false);
    context.go('/login');
  }

  void _handleRetryVerification() {
    if (_isActionInFlight) return;
    ref.read(kycControllerProvider.notifier).reset();
    context.go('/kyc');
  }
}

