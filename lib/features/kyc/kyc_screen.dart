import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:opei/core/config/api_config.dart';
import 'package:opei/core/providers/providers.dart';
import 'package:opei/features/kyc/kyc_state.dart';
import 'package:opei/theme.dart';
import 'package:opei/widgets/opei_premium/opei_premium.dart';

class KycScreen extends ConsumerStatefulWidget {
  const KycScreen({super.key});

  @override
  ConsumerState<KycScreen> createState() => _KycScreenState();
}

class _KycScreenState extends ConsumerState<KycScreen> {
  WebViewController? _webViewController;
  bool _isWebViewLoading = true;
  bool _handledCallbackNavigation = false;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(kycControllerProvider);
    final isWebView = state is KycWebViewReady;

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
        appBar: OpeiAppBar(
          backgroundColor: OpeiBrand.surface,
          showBack: !isWebView,
          onBack: _handleBackNavigation,
        ),
        body: _buildBody(state),
      ),
    );
  }

  Future<void> _handleBackNavigation() async {
    ref.read(kycControllerProvider.notifier).reset();
    final router = GoRouter.of(context);

    if (router.canPop()) {
      context.pop();
      return;
    }

    final logoutFuture = ref.read(authRepositoryProvider).logout();
    ref.read(authSessionProvider.notifier).clearSession();

    if (!mounted) return;
    context.go('/welcome');

    try {
      await logoutFuture;
    } catch (e) {
      debugPrint('⚠️ Failed to logout before returning to welcome: $e');
    }
  }

  Future<List<String>> _handleAndroidFileSelection(
      FileSelectorParams params) async {
    try {
      final config = _resolveFilePickerConfig(params.acceptTypes);
      final allowMultiple = params.mode == FileSelectorMode.openMultiple;
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: allowMultiple,
        type: config.fileType,
        allowedExtensions: config.allowedExtensions,
        withData: false,
      );

      if (result == null || result.files.isEmpty) return [];

      final uriStrings = <String>[];
      for (final file in result.files) {
        String? path = file.path;
        if (path == null && file.bytes != null) {
          final tempDir = await getTemporaryDirectory();
          final extension =
              file.extension?.isNotEmpty == true ? '.${file.extension}' : '';
          final tempFile = File(
              '${tempDir.path}/didit_upload_${DateTime.now().millisecondsSinceEpoch}$extension');
          await tempFile.writeAsBytes(file.bytes!);
          path = tempFile.path;
        }
        if (path != null) uriStrings.add(Uri.file(path).toString());
      }
      return uriStrings;
    } catch (e) {
      debugPrint('❌ File picker error: $e');
      return [];
    }
  }

  _FilePickerConfig _resolveFilePickerConfig(List<String> acceptTypes) {
    if (acceptTypes.isEmpty) {
      return const _FilePickerConfig(fileType: FileType.any);
    }
    final normalized = acceptTypes
        .map((type) => type.toLowerCase().trim())
        .where((type) => type.isNotEmpty)
        .toList();

    if (normalized.any((type) => type.contains('image'))) {
      return const _FilePickerConfig(fileType: FileType.image);
    }
    if (normalized.any((type) => type.contains('video'))) {
      return const _FilePickerConfig(fileType: FileType.video);
    }
    if (normalized.any((type) => type.contains('audio'))) {
      return const _FilePickerConfig(fileType: FileType.audio);
    }

    final extensions = <String>[];
    for (final type in normalized) {
      if (type.startsWith('.')) {
        final extension = type.substring(1);
        if (extension.isNotEmpty) extensions.add(extension);
      } else if (type.contains('/')) {
        final subtype = type.split('/').last;
        if (subtype != '*' && subtype.isNotEmpty) extensions.add(subtype);
      }
    }

    if (extensions.isNotEmpty) {
      return _FilePickerConfig(
        fileType: FileType.custom,
        allowedExtensions: extensions,
      );
    }
    return const _FilePickerConfig(fileType: FileType.any);
  }

  bool _isKycCallbackUrl(String? url) {
    if (url == null || url.isEmpty) return false;
    return url.toLowerCase().startsWith(ApiConfig.kycCallbackUrl.toLowerCase());
  }

  void _handleCallbackRedirect() {
    if (_handledCallbackNavigation || !mounted) return;
    _handledCallbackNavigation = true;
    ref.read(kycControllerProvider.notifier).reset();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.go('/kyc/result');
    });
  }

  Widget _buildBody(KycState state) {
    return switch (state) {
      KycInitial() => _buildInitialView(),
      KycLoading() => _buildLoadingView(),
      KycWebViewReady(:final sessionUrl) => _buildWebView(sessionUrl),
      KycError(:final message, :final errorType) =>
        _buildErrorView(message, errorType),
      KycCompleted() => _buildCompletedView(),
    };
  }

  Widget _buildInitialView() {
    final bottomPad = MediaQuery.of(context).viewPadding.bottom;
    return SafeArea(
      top: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Progress bar — step 4 of 4 (complete)
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 2, 24, 0),
            child: Row(
              children: List.generate(4, (i) {
                return Expanded(
                  child: AnimatedContainer(
                    duration: OpeiBrand.motion,
                    curve: OpeiBrand.motionCurve,
                    height: 3,
                    margin: EdgeInsets.only(right: i < 3 ? 5 : 0),
                    decoration: BoxDecoration(
                      color: OpeiBrand.primary,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                );
              }),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
              physics: const ClampingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Verify your\nidentity',
                    style: TextStyle(
                      fontFamily: kPrimaryFontFamily,
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1.0,
                      color: OpeiBrand.ink,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "One last step — a quick ID check and selfie. Takes about 2 minutes.",
                    style: TextStyle(
                      fontFamily: kPrimaryFontFamily,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w400,
                      color: OpeiBrand.inkSecondary,
                      letterSpacing: -0.1,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Container(
                    decoration: BoxDecoration(
                      color: OpeiBrand.surfaceMuted,
                      borderRadius:
                          BorderRadius.circular(OpeiBrand.radiusCard),
                    ),
                    child: Column(
                      children: [
                        _ChecklistRow(
                          icon: Icons.badge_rounded,
                          label: 'Government-issued ID',
                          subLabel:
                              "Passport, driver's licence or national ID",
                        ),
                        _Divider(),
                        _ChecklistRow(
                          icon: Icons.face_rounded,
                          label: 'A quick selfie',
                          subLabel: 'Matched against your ID photo',
                        ),
                        _Divider(),
                        _ChecklistRow(
                          icon: Icons.timer_outlined,
                          label: 'About 2 minutes',
                          subLabel: 'Most checks complete instantly',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(
                        Icons.lock_rounded,
                        size: 14,
                        color: OpeiBrand.inkTertiary,
                      ),
                      const SizedBox(width: 6),
                      const Expanded(
                        child: Text(
                          'Your data is encrypted and never shared. We verify with a trusted partner.',
                          style: TextStyle(
                            fontFamily: kPrimaryFontFamily,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                            color: OpeiBrand.inkTertiary,
                            letterSpacing: -0.1,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(24, 16, 24, 20 + bottomPad),
            child: OpeiPrimaryButton(
              label: 'Start verification',
              onPressed: _handleStartVerification,
              trailingIcon: Icons.arrow_forward_rounded,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleStartVerification() async {
    debugPrint('🔘 Start verification button pressed');
    if (!kIsWeb) {
      final granted = await _ensureKycPermissions();
      if (!granted) return;
    }
    if (!mounted) return;
    ref.read(kycControllerProvider.notifier).initializeKycSession();
  }

  Future<bool> _ensureKycPermissions() async {
    final platform = defaultTargetPlatform;
    if (platform != TargetPlatform.android &&
        platform != TargetPlatform.iOS) {
      return true;
    }

    final permissions = <Permission>{
      Permission.camera,
      Permission.microphone,
    };
    if (platform == TargetPlatform.iOS) {
      permissions.add(Permission.photos);
    }

    final results = await permissions.toList().request();
    final allGranted = results.values
        .every((status) => status.isGranted || status.isLimited);
    if (allGranted) return true;

    final permanentlyDenied =
        results.entries.any((entry) => entry.value.isPermanentlyDenied);
    if (permanentlyDenied && mounted) {
      await _showPermissionDialog();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Camera and microphone access are required to continue.',
          ),
          backgroundColor: OpeiBrand.danger,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(OpeiBrand.radiusCard),
          ),
        ),
      );
    }
    return false;
  }

  Future<void> _showPermissionDialog() async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: OpeiBrand.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(OpeiBrand.radiusCard),
          ),
          title: const Text('Allow access',
              style: TextStyle(
                  fontFamily: kPrimaryFontFamily,
                  fontWeight: FontWeight.w700)),
          content: const Text(
            'Camera, microphone and media permissions are needed to capture your verification selfie. '
            'Please enable them in Settings to continue.',
            style: TextStyle(
                fontFamily: kPrimaryFontFamily,
                color: OpeiBrand.inkSecondary,
                height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Not now',
                  style: TextStyle(color: OpeiBrand.inkSecondary)),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await openAppSettings();
              },
              child: const Text('Open Settings',
                  style: TextStyle(
                      color: OpeiBrand.primary,
                      fontWeight: FontWeight.w600)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLoadingView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              strokeWidth: 2.4,
              color: OpeiBrand.primary,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Preparing verification…',
            style: TextStyle(
              fontFamily: kPrimaryFontFamily,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: OpeiBrand.inkSecondary,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebView(String sessionUrl) {
    if (_webViewController == null) _setupWebView(sessionUrl);

    return Stack(
      children: [
        if (_webViewController != null)
          WebViewWidget(controller: _webViewController!),
        if (_isWebViewLoading)
          Container(
            color: OpeiBrand.surface,
            child: const Center(
              child: SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  color: OpeiBrand.primary,
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _setupWebView(String sessionUrl) {
    debugPrint('🌐 Setting up WebView for: $sessionUrl');

    if (kIsWeb) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final uri = Uri.parse(sessionUrl);
        final launched =
            await launchUrl(uri, mode: LaunchMode.platformDefault);
        if (!launched && mounted) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content:
                      Text('Could not open verification tab. Copying link…')),
            );
          }
        }
      });
      return;
    }

    final params = WebViewPlatform.instance is WebKitWebViewPlatform
        ? WebKitWebViewControllerCreationParams(
            allowsInlineMediaPlayback: true,
            mediaTypesRequiringUserAction: const {},
          )
        : const PlatformWebViewControllerCreationParams();

    _webViewController = WebViewController.fromPlatformCreationParams(params)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent(
        'Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36',
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (url) {
            if (mounted) setState(() => _isWebViewLoading = false);
          },
          onWebResourceError: (error) {
            debugPrint('❌ WebView error: ${error.description}');
          },
          onNavigationRequest: (request) {
            final targetUrl = request.url;
            if (!_handledCallbackNavigation && _isKycCallbackUrl(targetUrl)) {
              debugPrint('🔁 Detected KYC callback navigation: $targetUrl');
              _handleCallbackRedirect();
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(sessionUrl));

    final platformController = _webViewController!.platform;
    platformController.setOnPlatformPermissionRequest((request) {
      request.grant();
    });

    if (platformController is AndroidWebViewController) {
      platformController.setGeolocationPermissionsPromptCallbacks(
        onShowPrompt: (params) async {
          return const GeolocationPermissionsResponse(
            allow: true,
            retain: true,
          );
        },
        onHidePrompt: () {},
      );
      platformController.setMediaPlaybackRequiresUserGesture(false);
      platformController.setOnShowFileSelector(_handleAndroidFileSelection);
    }
  }

  Widget _buildErrorView(String message, KycErrorType errorType) {
    IconData icon;
    Color iconColor;
    Color tintColor;
    String actionText;
    VoidCallback? onAction;
    String title;

    switch (errorType) {
      case KycErrorType.alreadyApproved:
        icon = Icons.check_circle_rounded;
        iconColor = OpeiBrand.success;
        tintColor = const Color(0xFFE7F8EE);
        title = 'Already verified';
        actionText = 'Go to dashboard';
        onAction = () => context.go('/dashboard');
        break;
      case KycErrorType.underReview:
        icon = Icons.hourglass_top_rounded;
        iconColor = OpeiBrand.warning;
        tintColor = const Color(0xFFFFF7E6);
        title = 'Under review';
        actionText = 'Back';
        onAction = () => context.pop();
        break;
      case KycErrorType.wrongStage:
        icon = Icons.info_rounded;
        iconColor = OpeiBrand.primary;
        tintColor = OpeiBrand.primaryTint;
        title = 'Address required';
        actionText = 'Complete address';
        onAction = () => context.go('/address');
        break;
      case KycErrorType.inactiveUser:
        icon = Icons.block_rounded;
        iconColor = OpeiBrand.danger;
        tintColor = const Color(0xFFFDEBEE);
        title = 'Account inactive';
        actionText = 'Back';
        onAction = () => context.pop();
        break;
      case KycErrorType.unauthorized:
      case KycErrorType.notFound:
        icon = Icons.lock_rounded;
        iconColor = OpeiBrand.danger;
        tintColor = const Color(0xFFFDEBEE);
        title = 'Sign in again';
        actionText = 'Go to sign in';
        onAction = () => context.go('/login');
        break;
      case KycErrorType.serviceUnavailable:
      case KycErrorType.general:
        icon = Icons.error_rounded;
        iconColor = OpeiBrand.danger;
        tintColor = const Color(0xFFFDEBEE);
        title = 'Something went wrong';
        actionText = 'Try again';
        onAction = () =>
            ref.read(kycControllerProvider.notifier).initializeKycSession();
        break;
    }

    return SafeArea(
      top: false,
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: tintColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(icon, size: 30, color: iconColor),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      title,
                      style: const TextStyle(
                        fontFamily: kPrimaryFontFamily,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: OpeiBrand.ink,
                        letterSpacing: -0.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      message,
                      style: const TextStyle(
                        fontFamily: kPrimaryFontFamily,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: OpeiBrand.inkSecondary,
                        letterSpacing: -0.2,
                        height: 1.45,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
          _BottomBar(primaryLabel: actionText, onPrimary: onAction),
        ],
      ),
    );
  }

  Widget _buildCompletedView() {
    return SafeArea(
      top: false,
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE7F8EE),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        size: 36,
                        color: OpeiBrand.success,
                      ),
                    ),
                    const SizedBox(height: 22),
                    const Text(
                      'You\'re all set!',
                      style: TextStyle(
                        fontFamily: kPrimaryFontFamily,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: OpeiBrand.ink,
                        letterSpacing: -0.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Your identity has been verified. Welcome to Opei.',
                      style: TextStyle(
                        fontFamily: kPrimaryFontFamily,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: OpeiBrand.inkSecondary,
                        letterSpacing: -0.2,
                        height: 1.45,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
          _BottomBar(
            primaryLabel: 'Continue to dashboard',
            onPrimary: () => context.go('/dashboard'),
          ),
        ],
      ),
    );
  }
}

class _ChecklistRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subLabel;

  const _ChecklistRow({
    required this.icon,
    required this.label,
    required this.subLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: OpeiBrand.primaryTint,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 18, color: OpeiBrand.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontFamily: kPrimaryFontFamily,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: OpeiBrand.ink,
                    letterSpacing: -0.2,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subLabel,
                  style: const TextStyle(
                    fontFamily: kPrimaryFontFamily,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w400,
                    color: OpeiBrand.inkSecondary,
                    letterSpacing: -0.1,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Divider(
        height: 1,
        thickness: 1,
        color: OpeiBrand.hairline,
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final String primaryLabel;
  final VoidCallback? onPrimary;

  const _BottomBar({required this.primaryLabel, required this.onPrimary});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: OpeiBrand.surface,
        border: Border(top: BorderSide(color: OpeiBrand.hairline, width: 1)),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        14,
        24,
        14 + MediaQuery.of(context).viewPadding.bottom,
      ),
      child: OpeiPrimaryButton(
        label: primaryLabel,
        onPressed: onPrimary,
        trailingIcon: Icons.arrow_forward_rounded,
      ),
    );
  }
}

class _FilePickerConfig {
  final FileType fileType;
  final List<String>? allowedExtensions;
  const _FilePickerConfig({
    required this.fileType,
    this.allowedExtensions,
  });
}
