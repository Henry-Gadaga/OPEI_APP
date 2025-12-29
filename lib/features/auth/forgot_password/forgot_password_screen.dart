import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tt1/features/auth/forgot_password/forgot_password_controller.dart';
import 'package:tt1/responsive/responsive_tokens.dart';
import 'package:tt1/responsive/responsive_widgets.dart';
import 'package:tt1/theme.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _emailFocusNode = FocusNode();

  @override
  void dispose() {
    _emailController.dispose();
    _emailFocusNode.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    FocusScope.of(context).unfocus();

    final success = await ref
        .read(forgotPasswordControllerProvider.notifier)
        .requestPasswordReset();

    if (success && mounted) {
      final email = ref.read(forgotPasswordControllerProvider).email;
      context.push('/reset-password?email=${Uri.encodeComponent(email)}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(forgotPasswordControllerProvider);
    final spacing = context.responsiveSpacingUnit;
    final tokens = context.responsiveTokens;

    return ResponsiveScaffold(
      backgroundColor: OpeiColors.pureWhite,
      appBar: AppBar(
        backgroundColor: OpeiColors.pureWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: spacing * 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: spacing * 2.5),
            Text(
              'Forgot Password?',
              style: Theme.of(context).textTheme.displayLarge,
            ),
            SizedBox(height: spacing),
            Text(
              'Enter your email address and we\'ll send you a verification code to reset your password.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: OpeiColors.grey600,
                    height: 1.5,
                  ),
            ),
            SizedBox(height: spacing * 6),
            if (state.errorMessage != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: OpeiColors.errorRed.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: OpeiColors.errorRed,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        state.errorMessage!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: OpeiColors.errorRed,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: spacing * 3),
            ],
            if (state.successMessage != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: OpeiColors.successGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle_outline,
                      color: OpeiColors.successGreen,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        state.successMessage!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: OpeiColors.successGreen,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: spacing * 3),
            ],
            Text(
              'Email',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: OpeiColors.pureBlack,
                  ),
            ),
            SizedBox(height: spacing),
            TextField(
              controller: _emailController,
              focusNode: _emailFocusNode,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              onChanged: (value) {
                ref
                    .read(forgotPasswordControllerProvider.notifier)
                    .updateEmail(value);
              },
              onSubmitted: (_) => _handleSubmit(),
              decoration: InputDecoration(
                hintText: 'Enter your email',
                prefixIcon: const Icon(Icons.email_outlined),
                errorText: state.emailError,
                errorMaxLines: 2,
              ),
            ),
            SizedBox(height: spacing * 4),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: state.isLoading ? null : _handleSubmit,
                style: ElevatedButton.styleFrom(
                  minimumSize: Size.fromHeight(tokens.buttonHeight),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                ),
                child: state.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: OpeiColors.pureWhite,
                        ),
                      )
                    : const Text('Send Code'),
              ),
            ),
            SizedBox(height: spacing * 3),
          ],
        ),
      ),
    );
  }
}
