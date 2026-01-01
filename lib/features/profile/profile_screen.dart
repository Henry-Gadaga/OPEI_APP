import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tt1/core/providers/providers.dart';
import 'package:tt1/responsive/responsive_tokens.dart';
import 'package:tt1/responsive/responsive_widgets.dart';
import 'package:tt1/theme.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileControllerProvider);
    final controller = ref.read(profileControllerProvider.notifier);
    final profile = state.profile;
    final platform = Theme.of(context).platform;
    final isCupertino =
        platform == TargetPlatform.iOS || platform == TargetPlatform.macOS;
    final scrollPhysics = AlwaysScrollableScrollPhysics(
      parent: isCupertino
          ? const BouncingScrollPhysics()
          : const ClampingScrollPhysics(),
      );

    final spacing = context.responsiveSpacingUnit;

    if (profile == null) {
      if (state.error != null) {
        return _buildErrorState(context, controller, state.error!);
      }
      return ResponsiveScaffold(
        appBar: AppBar(
          title: const Text('Profile'),
          automaticallyImplyLeading: false,
        ),
        body: const Center(
          child: CircularProgressIndicator(color: OpeiColors.pureBlack),
        ),
      );
    }

    final user = profile;

    return ResponsiveScaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        automaticallyImplyLeading: false,
      ),
      body: RefreshIndicator(
        onRefresh: () async => await controller.refreshProfile(),
        color: OpeiColors.pureBlack,
        backgroundColor: OpeiColors.pureWhite,
        displacement: 25,
        triggerMode: RefreshIndicatorTriggerMode.onEdge,
        child: ListView(
          physics: scrollPhysics,
          padding: EdgeInsets.only(
            top: spacing * 3,
            bottom: spacing * 4,
          ),
          children: [
            ProfileHeader(
              displayName: user.displayName,
              email: user.email,
            ),
            SizedBox(height: spacing * 4),

            // Show KYC prompt if identity is missing
            if (user.identity == null) ...[
              _buildKycPromptCard(context),
              SizedBox(height: spacing * 3),
            ],

            ProfileSection(
              title: 'Account Information',
              children: [
                ProfileInfoItem(
                  icon: Icons.email_outlined,
                  label: 'Email',
                  value: user.email,
                ),
                ProfileInfoItem(
                  icon: Icons.phone_outlined,
                  label: 'Phone',
                  value: user.phone,
                ),
                ProfileInfoItem(
                  icon: Icons.check_circle_outline,
                  label: 'Verification Stage',
                  value: _formatUserStage(user.userStage),
                ),
              ],
            ),

            // Show personal information if identity exists
            if (user.identity != null) ...[
              SizedBox(height: spacing * 3),
              ProfileSection(
                title: 'Personal Information',
                children: [
                  ProfileInfoItem(
                    icon: Icons.person_outline,
                    label: 'Full Name',
                    value: user.displayName,
                  ),
                  ProfileInfoItem(
                    icon: Icons.cake_outlined,
                    label: 'Date of Birth',
                    value: _formatDate(user.identity!.dateOfBirth),
                  ),
                  ProfileInfoItem(
                    icon: Icons.wc_outlined,
                    label: 'Gender',
                    value: user.identity!.gender,
                  ),
                  ProfileInfoItem(
                    icon: Icons.flag_outlined,
                    label: 'Nationality',
                    value: user.identity!.nationality,
                  ),
                  ProfileInfoItem(
                    icon: Icons.badge_outlined,
                    label: 'ID Type',
                    value: user.identity!.idType,
                  ),
                  ProfileInfoItem(
                    icon: Icons.numbers_outlined,
                    label: 'ID Number',
                    value: user.identity!.idNumber,
                  ),
                ],
              ),
            ],

            SizedBox(height: spacing * 3),
            ProfileSection(
              title: 'Address',
              children: [
                if (user.address != null) ...[
                  if (user.address!.country != null)
                    ProfileInfoItem(
                      icon: Icons.public_outlined,
                      label: 'Country',
                      value: user.address!.country!,
                    ),
                  if (user.address!.state != null)
                    ProfileInfoItem(
                      icon: Icons.location_city_outlined,
                      label: 'State',
                      value: user.address!.state!,
                    ),
                  if (user.address!.city != null)
                    ProfileInfoItem(
                      icon: Icons.apartment_outlined,
                      label: 'City',
                      value: user.address!.city!,
                    ),
                  if (user.address!.houseNumber != null &&
                      user.address!.addressLine != null)
                    ProfileInfoItem(
                      icon: Icons.home_outlined,
                      label: 'Address',
                      value:
                          '${user.address!.houseNumber} ${user.address!.addressLine}',
                    ),
                  if (user.address!.zipCode != null)
                    ProfileInfoItem(
                      icon: Icons.markunread_mailbox_outlined,
                      label: 'Zip Code',
                      value: user.address!.zipCode!,
                    ),
                  ProfileActionItem(
                    icon: Icons.edit_outlined,
                    label: 'Update Address',
                    onTap: () => context.push('/address?source=profile'),
                  ),
                ] else
                  ProfileActionItem(
                    icon: Icons.add_location_outlined,
                    label: 'Add Address',
                    subtitle: 'No address added yet',
                    onTap: () => context.push('/address?source=profile'),
                  ),
              ],
            ),

            // Show verification badge if documents are verified
                if (user.identity != null &&
                    (user.identity!.selfieUrl != null ||
                        user.identity!.frontImage != null)) ...[
              SizedBox(height: spacing * 3),
              ProfileSection(
                title: 'Verification Status',
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    child: Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color:
                                const Color(0xFF34C759).withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.verified_user,
                            color: Color(0xFF34C759),
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Identity Verified',
                                style: context.textStyles.titleMedium?.copyWith(
                                  color: OpeiColors.pureBlack,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Your identity has been successfully verified',
                                style: context.textStyles.bodySmall?.copyWith(
                                  color: OpeiColors.grey600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],

            SizedBox(height: spacing * 3),
            QuickAuthSettingsSection(userId: user.userId),
            SizedBox(height: spacing * 3),
            ProfileSection(
              title: 'Account Actions',
              children: [
                ProfileActionItem(
                  icon: Icons.logout,
                  label: 'Log Out',
                  isDestructive: true,
                  isLoading: state.isLoggingOut,
                  onTap: () => _handleLogout(context, controller),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    ProfileController controller,
    String errorMessage,
  ) {
    final spacing = context.responsiveSpacingUnit;
    final tokens = context.responsiveTokens;

    return ResponsiveScaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: tokens.horizontalPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: OpeiColors.grey400),
              SizedBox(height: spacing * 2),
              Text(
                'Unable to load profile',
                style: context.textStyles.titleLarge?.copyWith(
                  color: OpeiColors.pureBlack,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: spacing),
              Text(
                errorMessage,
                style: context.textStyles.bodyMedium?.copyWith(
                  color: OpeiColors.grey600,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: spacing * 4),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => controller.refreshProfile(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: OpeiColors.pureBlack,
                    foregroundColor: OpeiColors.pureWhite,
                    padding: EdgeInsets.symmetric(vertical: spacing * 1.75),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(tokens.buttonRadius),
                    ),
                  ),
                  child: const Text('Retry'),
                ),
              ),
              SizedBox(height: spacing * 1.5),
              TextButton(
                onPressed: () => _handleLogout(context, controller),
                child: const Text(
                  'Log Out',
                  style: TextStyle(color: OpeiColors.errorRed),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKycPromptCard(BuildContext context) {
    final spacing = context.responsiveSpacingUnit;

    return Container(
      padding: EdgeInsets.all(spacing * 2.5),
      decoration: BoxDecoration(
        color: OpeiColors.pureWhite,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: OpeiColors.grey900.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: OpeiColors.pureBlack.withValues(alpha: 0.06),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.shield_outlined,
                color: OpeiColors.pureBlack, size: 24),
          ),
          SizedBox(width: spacing * 2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Complete Your Profile',
                  style: context.textStyles.titleMedium,
                ),
                SizedBox(height: spacing * 0.5),
                Text(
                  'Verify your identity to unlock all features',
                  style: context.textStyles.bodySmall
                      ?.copyWith(color: OpeiColors.grey600),
                ),
              ],
            ),
          ),
          SizedBox(width: spacing),
          const Icon(Icons.arrow_forward_ios,
              color: OpeiColors.grey400, size: 16),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatUserStage(String stage) {
    if (stage.isEmpty) return 'N/A';
    return stage.replaceAll('_', ' ').split(' ').map((word) {
      if (word.isEmpty) return '';
      return word[0] + word.substring(1).toLowerCase();
    }).join(' ');
  }

  Future<T?> _presentResponsiveSheet<T>({
    required WidgetBuilder builder,
    bool enableDrag = true,
  }) {
    return showResponsiveBottomSheet<T>(
      context: context,
      builder: builder,
      enableDrag: enableDrag,
      barrierColor: Colors.black.withValues(alpha: 0.35),
    );
  }

  Future<void> _handleLogout(BuildContext context, controller) async {
    final success = await _presentResponsiveSheet<bool>(
      builder: (_) => _LogoutConfirmationSheet(controller: controller),
      enableDrag: false,
    );

    if (success == true && mounted) {
                  context.go('/login');
    }
  }
}

class _LogoutConfirmationSheet extends StatefulWidget {
  final ProfileController controller;

  const _LogoutConfirmationSheet({required this.controller});

  @override
  State<_LogoutConfirmationSheet> createState() =>
      _LogoutConfirmationSheetState();
}

class _LogoutConfirmationSheetState extends State<_LogoutConfirmationSheet> {
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = context.responsiveSpacingUnit;
    final tokens = context.responsiveTokens;
    final bottomInset = MediaQuery.of(context).viewPadding.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset + spacing * 2),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: OpeiColors.pureWhite,
          borderRadius: BorderRadius.circular(tokens.dialogRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 30,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            spacing * 2.5,
            spacing * 2.25,
            spacing * 2.5,
            spacing * 2,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: OpeiColors.grey300,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              SizedBox(height: spacing * 2),
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: OpeiColors.pureBlack.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  size: 32,
                  color: OpeiColors.pureBlack,
                ),
              ),
              SizedBox(height: spacing * 2),
              Text(
                'Sign out of Opei?',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  letterSpacing: -0.2,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: spacing),
              Text(
                'You’ll need to enter your email and PIN again next time.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: OpeiColors.iosLabelSecondary,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: spacing * 3),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isProcessing
                          ? null
                          : () => Navigator.of(context).pop(false),
                      style: OutlinedButton.styleFrom(
                        padding:
                            EdgeInsets.symmetric(vertical: spacing * 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(tokens.buttonRadius),
                        ),
                        side: BorderSide(
                          color: OpeiColors.pureBlack.withValues(alpha: 0.15),
                        ),
                      ),
                      child: Text(
                        'Stay signed in',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: spacing * 1.5),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isProcessing ? null : _confirmLogout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: OpeiColors.pureBlack,
                        foregroundColor: OpeiColors.pureWhite,
                        padding:
                            EdgeInsets.symmetric(vertical: spacing * 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(tokens.buttonRadius),
                        ),
                        elevation: 0,
                      ),
                      child: _isProcessing
                          ? SizedBox(
                              height: spacing * 2.25,
                              width: spacing * 2.25,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                color: OpeiColors.pureWhite,
                              ),
                            )
                          : Text(
                              'Log out',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: OpeiColors.pureWhite,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmLogout() async {
    setState(() => _isProcessing = true);
    final success = await widget.controller.logout();
    if (!mounted) return;
    Navigator.of(context).pop(success);
  }
}

class ProfileHeader extends StatelessWidget {
  final String displayName;
  final String email;

  const ProfileHeader(
      {super.key, required this.displayName, required this.email});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(
            color: OpeiColors.grey100,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.person, color: OpeiColors.grey600, size: 36),
        ),
        const SizedBox(height: 12),
        Text(
          displayName,
          style: context.textStyles.headlineMedium,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          email,
          style: context.textStyles.bodyMedium
              ?.copyWith(color: OpeiColors.grey600),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class ProfileSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const ProfileSection(
      {super.key, required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final separatedChildren = <Widget>[];

    for (var i = 0; i < children.length; i++) {
      separatedChildren.add(children[i]);
      if (i != children.length - 1) {
        separatedChildren.add(const Divider(
          height: 1,
          thickness: 1,
          color: OpeiColors.iosSeparator,
          indent: 32,
          endIndent: 0,
        ));
      }
    }

    final spacing = context.responsiveSpacingUnit;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: spacing * 1.5),
          child: Text(
            title.toUpperCase(),
            style: context.textStyles.labelMedium?.copyWith(
              color: OpeiColors.grey500,
              fontSize: 11,
              letterSpacing: 0.8,
            ),
          ),
        ),
        SizedBox(height: spacing * 1.25),
        Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: separatedChildren),
      ],
    );
  }
}

class ProfileInfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const ProfileInfoItem({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: OpeiColors.grey600, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: context.textStyles.bodySmall
                        ?.copyWith(color: OpeiColors.grey600)),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: context.textStyles.bodyLarge
                      ?.copyWith(fontWeight: FontWeight.w500),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileActionItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final bool isDestructive;
  final bool isLoading;
  final VoidCallback? onTap;

  const ProfileActionItem({
    super.key,
    required this.icon,
    required this.label,
    this.subtitle,
    this.isDestructive = false,
    this.isLoading = false,
    this.onTap,
  });

  @override
  State<ProfileActionItem> createState() => _ProfileActionItemState();
}

class _ProfileActionItemState extends State<ProfileActionItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100));
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color =
        widget.isDestructive ? OpeiColors.errorRed : OpeiColors.pureBlack;
    final iconColor =
        widget.isDestructive ? OpeiColors.errorRed : OpeiColors.grey600;
    final isInteractive = widget.onTap != null && !widget.isLoading;

    Widget buildContent() => Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Icon(widget.icon, color: iconColor, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.label,
                      style: context.textStyles.bodyLarge?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (widget.subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        widget.subtitle!,
                        style: context.textStyles.bodySmall
                            ?.copyWith(color: OpeiColors.grey600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              if (widget.isLoading)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: OpeiColors.pureBlack,
                    strokeWidth: 2,
                  ),
                )
              else if (!widget.isDestructive && isInteractive)
                const Icon(Icons.chevron_right,
                    color: OpeiColors.grey400, size: 18),
            ],
          ),
        );

    final content = buildContent();

    if (!isInteractive) {
      return content;
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        if (!widget.isLoading) widget.onTap?.call();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: content,
      ),
    );
  }
}


class QuickAuthSettingsSection extends ConsumerStatefulWidget {
  final String userId;
  const QuickAuthSettingsSection({super.key, required this.userId});

  @override
  ConsumerState<QuickAuthSettingsSection> createState() =>
      _QuickAuthSettingsSectionState();
}

class _QuickAuthSettingsSectionState
    extends ConsumerState<QuickAuthSettingsSection> {
  bool _isLoadingPinStatus = true;
  bool _hasPinSetup = false;

  @override
  void initState() {
    super.initState();
    _loadQuickAuthStatus();
  }

  Future<void> _loadQuickAuthStatus() async {
    final quickAuthService = ref.read(quickAuthServiceProvider);
    
    setState(() {
      _isLoadingPinStatus = true;
    });

    final hasPin = await quickAuthService.hasPinSetup(widget.userId);

    setState(() {
      _hasPinSetup = hasPin;
      _isLoadingPinStatus = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ProfileSection(
      title: 'Security Settings',
      children: [
        ProfileActionItem(
          icon: Icons.pin_outlined,
          label: 'PIN Authentication',
          subtitle: _isLoadingPinStatus 
              ? 'Loading...' 
              : _hasPinSetup
                  ? 'Enabled'
                  : 'Disabled',
          onTap: null,
          ),
      ],
    );
  }
}
