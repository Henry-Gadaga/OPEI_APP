import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:opei/core/providers/providers.dart';
import 'package:opei/features/auth/login/login_controller.dart';
import 'package:opei/responsive/responsive_tokens.dart';
import 'package:opei/responsive/responsive_widgets.dart';
import 'package:opei/theme.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(loginControllerProvider);
      _emailController.clear();
      _passwordController.clear();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    FocusScope.of(context).unfocus();

    final result = await ref.read(loginControllerProvider.notifier).login();

    if (!mounted) return;

    if (result == null) {
      final loginState = ref.read(loginControllerProvider);
      if (loginState.errorMessage ==
          'Invalid email or password. Please try again.') {
        _passwordController.clear();
        ref.read(loginControllerProvider.notifier).resetPasswordField();
        _passwordFocusNode.requestFocus();
      }
      return;
    }

    if (result['success'] == true) {
      final userStage = result['userStage'] as String?;

      switch (userStage) {
        case 'PENDING_EMAIL':
          context.go('/verify-email?autoSend=true');
          return;
        case 'PENDING_ADDRESS':
          context.go('/address');
          return;
        case 'PENDING_KYC':
          context.go('/kyc');
          return;
        case 'VERIFIED':
          await _handleVerifiedUserNavigation();
          return;
        default:
          context.go('/verify-email?autoSend=true');
          return;
      }
    }
  }

  Future<void> _handleVerifiedUserNavigation() async {
    final quickAuthService = ref.read(quickAuthServiceProvider);
    final storage = ref.read(secureStorageServiceProvider);
    final quickAuthStatusNotifier = ref.read(quickAuthStatusProvider.notifier);

    final user = await storage.getUser();
    var userIdentifier = user?.id;
    userIdentifier ??= await quickAuthService.getRegisteredUserId();

    if (userIdentifier == null) {
      debugPrint('⚠️ No user identifier found for quick auth setup check');
      if (!mounted) return;
      context.go('/dashboard');
      return;
    }

    debugPrint('🔍 Checking quick auth setup for user: $userIdentifier');

    final setupCompleted =
        await quickAuthService.isSetupCompleted(userIdentifier);

    debugPrint('🔍 Setup completed? $setupCompleted');

    debugPrint('➡️ Navigating to quick-auth-setup');
    quickAuthStatusNotifier.setStatus(QuickAuthStatus.requiresSetup);
    if (!mounted) return;
    context.go('/quick-auth-setup');
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(loginControllerProvider);
    final spacing = context.responsiveSpacingUnit;
    final tokens = context.responsiveTokens;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final sectionSpacing = spacing * 3;
    final fieldSpacing = spacing * 2;

    return ResponsiveScaffold(
      backgroundColor: OpeiColors.pureWhite,
      resizeToAvoidBottomInset: false,
      body: AnimatedPadding(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: EdgeInsets.only(bottom: bottomInset),
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.only(
            top: spacing * 4,
            bottom: spacing * 4,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: spacing * 2.5),
              Text(
                'Sign in',
                style: Theme.of(context).textTheme.displayMedium,
              ),
              SizedBox(height: spacing),
              Text(
                'Sign in to your account',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: OpeiColors.grey600,
                    ),
              ),
              SizedBox(height: sectionSpacing),
              if (state.errorMessage != null) ...[
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: OpeiColors.errorRed.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline,
                          color: OpeiColors.errorRed, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          state.errorMessage!,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: OpeiColors.errorRed,
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: sectionSpacing),
              ],
              _EmailField(
                controller: _emailController,
                focusNode: _emailFocusNode,
                errorText: state.emailError,
                onChanged: (value) {
                  ref.read(loginControllerProvider.notifier).updateEmail(value);
                },
                onSubmitted: (_) => _passwordFocusNode.requestFocus(),
              ),
              SizedBox(height: fieldSpacing),
              _PasswordField(
                controller: _passwordController,
                focusNode: _passwordFocusNode,
                obscureText: _obscurePassword,
                errorText: state.passwordError,
                onChanged: (value) {
                  ref
                      .read(loginControllerProvider.notifier)
                      .updatePassword(value);
                },
                onToggleVisibility: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
                onSubmitted: (_) => _handleLogin(),
              ),
              SizedBox(height: spacing * 1.5),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => context.push('/forgot-password'),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Forgot Password?',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: OpeiColors.pureBlack,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ),
              ),
              SizedBox(height: sectionSpacing),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: state.isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size.fromHeight(tokens.buttonHeight),
                  ),
                  child: state.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Sign in'),
                ),
              ),
              SizedBox(height: sectionSpacing),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account? ",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: OpeiColors.grey600,
                        ),
                  ),
                  TextButton(
                    onPressed: () => context.go('/signup'),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Sign Up',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: OpeiColors.pureBlack,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: spacing * 2),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmailField extends StatelessWidget {
  const _EmailField({
    required this.controller,
    required this.focusNode,
    this.errorText,
    required this.onChanged,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String? errorText;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) {
    final spacing = context.responsiveSpacingUnit;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Email',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: OpeiColors.grey700,
              ),
        ),
        SizedBox(height: spacing * 0.5),
        TextField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          decoration: InputDecoration(
            hintText: 'Enter your email',
            isDense: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            prefixIcon: const Icon(
              Icons.email_outlined,
              size: 20,
            ),
            prefixIconConstraints: const BoxConstraints(minWidth: 44),
            errorText: errorText,
            errorMaxLines: 2,
          ),
        ),
      ],
    );
  }
}

class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.controller,
    required this.focusNode,
    required this.obscureText,
    this.errorText,
    required this.onChanged,
    required this.onToggleVisibility,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool obscureText;
  final String? errorText;
  final ValueChanged<String> onChanged;
  final VoidCallback onToggleVisibility;
  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) {
    final spacing = context.responsiveSpacingUnit;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Password',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: OpeiColors.grey700,
              ),
        ),
        SizedBox(height: spacing * 0.5),
        TextField(
          controller: controller,
          focusNode: focusNode,
          obscureText: obscureText,
          textInputAction: TextInputAction.done,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          decoration: InputDecoration(
            hintText: 'Enter your password',
            isDense: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            prefixIcon: const Icon(
              Icons.lock_outline,
              size: 20,
            ),
            prefixIconConstraints: const BoxConstraints(minWidth: 44),
            suffixIcon: IconButton(
              icon: Icon(
                obscureText
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
              onPressed: onToggleVisibility,
            ),
            errorText: errorText,
            errorMaxLines: 2,
          ),
        ),
      ],
    );
  }
}
