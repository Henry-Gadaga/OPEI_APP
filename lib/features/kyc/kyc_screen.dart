import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tt1/core/config/api_config.dart';
import 'package:tt1/core/providers/providers.dart';
import 'package:tt1/features/kyc/kyc_state.dart';
import 'package:tt1/theme.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'package:url_launcher/url_launcher.dart';

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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Identity Verification'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _handleBackToSignup,
        ),
      ),
      body: _buildBody(state),
    );
  }

  Future<void> _handleBackToSignup() async {
    ref.read(kycControllerProvider.notifier).reset();

    final logoutFuture = ref.read(authRepositoryProvider).logout();
    ref.read(authSessionProvider.notifier).clearSession();

    if (!mounted) {
      return;
    }

    context.go('/signup');

    try {
      await logoutFuture;
    } catch (e, stackTrace) {
      debugPrint('⚠️ Failed to logout before returning to signup: $e');
      debugPrint('$stackTrace');
    }
  }

  Future<List<String>> _handleAndroidFileSelection(FileSelectorParams params) async {
    try {
      final config = _resolveFilePickerConfig(params.acceptTypes);
      final allowMultiple = params.mode == FileSelectorMode.openMultiple;
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: allowMultiple,
        type: config.fileType,
        allowedExtensions: config.allowedExtensions,
        withData: false,
      );

      if (result == null || result.files.isEmpty) {
        return [];
      }

      final uriStrings = <String>[];
      for (final file in result.files) {
        String? path = file.path;
        if (path == null && file.bytes != null) {
          final tempDir = await getTemporaryDirectory();
          final extension = file.extension?.isNotEmpty == true ? '.${file.extension}' : '';
          final tempFile = File('${tempDir.path}/didit_upload_${DateTime.now().millisecondsSinceEpoch}$extension');
          await tempFile.writeAsBytes(file.bytes!);
          path = tempFile.path;
        }
        if (path != null) {
          uriStrings.add(Uri.file(path).toString());
        }
      }

      return uriStrings;
    } catch (e, stackTrace) {
      debugPrint('❌ File picker error: $e');
      debugPrint('$stackTrace');
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
        if (extension.isNotEmpty) {
          extensions.add(extension);
        }
      } else if (type.contains('/')) {
        final subtype = type.split('/').last;
        if (subtype != '*' && subtype.isNotEmpty) {
          extensions.add(subtype);
        }
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
    final normalizedUrl = url.toLowerCase();
    final normalizedTarget = ApiConfig.kycCallbackUrl.toLowerCase();
    return normalizedUrl.startsWith(normalizedTarget);
  }

  void _handleCallbackRedirect() {
    if (_handledCallbackNavigation || !mounted) return;
    _handledCallbackNavigation = true;
    ref.read(kycControllerProvider.notifier).reset();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.go('/kyc/result');
      }
    });
  }

  Widget _buildBody(KycState state) {
    return switch (state) {
      KycInitial() => _buildInitialView(),
      KycLoading() => _buildLoadingView(),
      KycWebViewReady(:final sessionUrl) => _buildWebView(sessionUrl),
      KycError(:final message, :final errorType) => _buildErrorView(message, errorType),
      KycCompleted() => _buildCompletedView(),
    };
  }

  Widget _buildInitialView() {
    return Center(
      child: Padding(
        padding: AppSpacing.horizontalLg,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: OpeiColors.pureBlack.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.verified_user_outlined,
                size: 64,
                color: OpeiColors.pureBlack,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Identity Verification',
              style: Theme.of(context).textTheme.displayMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'We need to verify your identity to complete your account setup. This process is secure and typically takes 2-3 minutes.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: OpeiColors.grey600,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _handleStartVerification,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Start Identity Verification'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleStartVerification() async {
    debugPrint('🔘 Start verification button pressed');
    if (!kIsWeb) {
      final granted = await _ensureKycPermissions();
      if (!granted) {
        return;
      }
    }
    if (!mounted) return;
    ref.read(kycControllerProvider.notifier).initializeKycSession();
  }

  Future<bool> _ensureKycPermissions() async {
    final platform = defaultTargetPlatform;
    if (platform != TargetPlatform.android && platform != TargetPlatform.iOS) {
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
    final allGranted = results.values.every((status) => status.isGranted || status.isLimited);

    if (allGranted) {
      return true;
    }

    final permanentlyDenied = results.entries.any((entry) => entry.value.isPermanentlyDenied);

    if (permanentlyDenied && mounted) {
      await _showPermissionDialog();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Camera and microphone access are required to continue.'),
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
          title: const Text('Allow Access'),
          content: const Text(
            'Camera, microphone, and media permissions are needed to capture your verification selfie. '
            'Please enable them in Settings to continue.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Not now'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await openAppSettings();
              },
              child: const Text('Open Settings'),
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
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Preparing verification...'),
        ],
      ),
    );
  }

  Widget _buildWebView(String sessionUrl) {
    if (_webViewController == null) {
      _setupWebView(sessionUrl);
    }

    return Stack(
      children: [
        if (_webViewController != null)
          WebViewWidget(controller: _webViewController!),
        if (_isWebViewLoading)
          Container(
            color: Colors.white,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }

  void _setupWebView(String sessionUrl) {
    debugPrint('🌐 Setting up WebView for: $sessionUrl');

    if (kIsWeb) {
      // On web, open the verification session in a new tab for best UX
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final uri = Uri.parse(sessionUrl);
        final launched = await launchUrl(uri, mode: LaunchMode.platformDefault);
        if (!launched && mounted) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Could not open verification tab. Copying link...')),
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
          onPageStarted: (url) {
            debugPrint('🌐 Page started loading: $url');
          },
          onPageFinished: (url) {
            debugPrint('✅ Page finished loading: $url');
            if (mounted) {
              setState(() => _isWebViewLoading = false);
            }
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
      debugPrint('📸 Permission requested: ${request.types}');
      request.grant();
    });

    if (platformController is AndroidWebViewController) {
      debugPrint('🤖 Configuring Android-specific settings');
      platformController.setGeolocationPermissionsPromptCallbacks(
        onShowPrompt: (params) async {
          debugPrint('📍 Geolocation permission requested');
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
    String actionText;
    VoidCallback? onAction;

    switch (errorType) {
      case KycErrorType.alreadyApproved:
        icon = Icons.check_circle_outline;
        iconColor = Colors.green;
        actionText = 'Go to Dashboard';
        onAction = () => context.go('/dashboard');
        break;

      case KycErrorType.underReview:
        icon = Icons.pending_outlined;
        iconColor = Colors.orange;
        actionText = 'Back to Home';
        onAction = () => context.pop();
        break;

      case KycErrorType.wrongStage:
        icon = Icons.info_outline;
        iconColor = Colors.blue;
        actionText = 'Complete Address';
        onAction = () => context.go('/address');
        break;

      case KycErrorType.inactiveUser:
        icon = Icons.block;
        iconColor = Colors.red;
        actionText = 'Back';
        onAction = () => context.pop();
        break;

      case KycErrorType.unauthorized:
      case KycErrorType.notFound:
        icon = Icons.lock_outline;
        iconColor = Colors.red;
        actionText = 'Login Again';
        onAction = () => context.go('/signup');
        break;

      case KycErrorType.serviceUnavailable:
      case KycErrorType.general:
        icon = Icons.error_outline;
        iconColor = Colors.red;
        actionText = 'Try Again';
        onAction = () => ref.read(kycControllerProvider.notifier).initializeKycSession();
        break;
    }

    return Center(
      child: Padding(
        padding: AppSpacing.horizontalLg,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: iconColor),
            const SizedBox(height: 24),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(actionText),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletedView() {
    return Center(
      child: Padding(
        padding: AppSpacing.horizontalLg,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle,
              size: 80,
              color: Colors.green,
            ),
            const SizedBox(height: 24),
            Text(
              'Verification Complete!',
              style: Theme.of(context).textTheme.displayMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Your identity has been verified successfully.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: OpeiColors.grey600,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.go('/dashboard'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Continue to Dashboard'),
              ),
            ),
          ],
        ),
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
