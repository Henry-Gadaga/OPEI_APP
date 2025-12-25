import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tt1/core/navigation/opei_page_transitions.dart';
import 'package:tt1/core/utils/asset_preloader.dart';
import 'package:tt1/core/providers/providers.dart';
import 'package:tt1/core/services/session_lock_service.dart';
import 'package:tt1/features/address/address_screen.dart';
import 'package:tt1/features/auth/forgot_password/forgot_password_screen.dart';
import 'package:tt1/features/auth/login/login_screen.dart';
import 'package:tt1/features/auth/reset_password/reset_password_screen.dart';
import 'package:tt1/features/auth/signup/signup_screen.dart';
import 'package:tt1/features/auth/verify_email/verify_email_screen.dart';
import 'package:tt1/features/auth/quick_auth_setup/quick_auth_setup_screen.dart';
import 'package:tt1/features/auth/quick_auth/quick_auth_screen.dart';
import 'package:tt1/features/dashboard/dashboard_screen.dart';
import 'package:tt1/features/kyc/kyc_screen.dart';
import 'package:tt1/features/profile/profile_screen.dart';
import 'package:tt1/features/send_money/send_money_screen.dart';
import 'package:tt1/features/deposit/deposit_screen.dart';
import 'package:tt1/features/withdraw/withdraw_screen.dart';
import 'package:tt1/features/transactions/transactions_screen.dart';
import 'package:tt1/features/p2p/p2p_screen.dart';
import 'package:tt1/features/p2p/p2p_rating_screen.dart';
import 'package:tt1/data/models/p2p_trade.dart';
import 'package:tt1/data/models/p2p_ad.dart';
import 'package:tt1/theme.dart';
import 'package:tt1/widgets/keyboard_dismiss_on_tap.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: OpeiColors.pureWhite,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  
  runApp(const ProviderScope(child: OpeiApp()));
}

class OpeiApp extends ConsumerStatefulWidget {
  const OpeiApp({super.key});

  @override
  ConsumerState<OpeiApp> createState() => _OpeiAppState();
}

const Set<String> _publicPaths = {
  '/splash',
  '/login',
  '/signup',
  '/forgot-password',
  '/reset-password',
  '/verify-email',
  '/quick-auth',
  '/quick-auth-setup',
};

const Set<String> _onboardingPaths = {
  '/verify-email',
  '/address',
  '/kyc',
};

class _OpeiAppState extends ConsumerState<OpeiApp> with WidgetsBindingObserver {
  bool _wasBackgrounded = false;
  late final GoRouter _router;
  late final ValueNotifier<int> _routerRefreshNotifier;
  late final ProviderSubscription<AuthSession> _sessionSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _routerRefreshNotifier = ValueNotifier<int>(0);
    _sessionSubscription = ref.listenManual<AuthSession>(
      authSessionProvider,
      (previous, next) {
        _routerRefreshNotifier.value++;
      },
    );
    _router = _createRouter();

    // Warm up frequently used SVG icons to avoid first-use delay on web.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Keep this list small and targeted to high-traffic screens.
      const svgAssets = <String>[
        // Success icon used across multiple success screens
        'assets/images/checkmark2.svg',
        'assets/images/btc.svg',
        'assets/images/exchange.svg',
        'assets/images/usdt-svgrepo-com.svg',
        'assets/images/usdc1.svg',
        'assets/images/eth.svg',
        'assets/images/binance.svg',
        'assets/images/tron.svg',
        'assets/images/polygon.svg',
      ];
      AssetPreloader.warmUpSvgList(context, svgAssets);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _sessionSubscription.close();
    _routerRefreshNotifier.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    final sessionLockService = ref.read(sessionLockServiceProvider);

    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _wasBackgrounded = true;
      sessionLockService.handleAppPaused();
    } else if (state == AppLifecycleState.resumed && _wasBackgrounded) {
      _wasBackgrounded = false;
      Future.microtask(() async {
        try {
          final outcome = await sessionLockService.handleAppResumed();
          if (!mounted) return;

          switch (outcome) {
            case SessionLockOutcome.quickAuth:
              _navigateToQuickAuth();
              break;
            case SessionLockOutcome.forceLogout:
              _handleForcedLogout();
              break;
            case SessionLockOutcome.none:
              break;
          }
        } catch (e, stackTrace) {
          debugPrint('❌ Session lock resume error: $e\n$stackTrace');
        }
      });
    }
  }

  void _navigateToQuickAuth() {
    final currentRoute = GoRouterState.of(context).uri.path;
    if (currentRoute != '/login' &&
        currentRoute != '/quick-auth' &&
        currentRoute != '/splash' &&
        !currentRoute.contains('auth')) {
      context.go('/quick-auth');
    }
  }

  void _handleForcedLogout() {
    ref.read(authSessionProvider.notifier).clearSession();

    final currentRoute = GoRouterState.of(context).uri.path;
    if (currentRoute != '/login') {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Opei',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.light,
      builder: (context, child) => KeyboardDismissOnTap(
        child: child ?? const SizedBox.shrink(),
      ),
      routerConfig: _router,
    );
  }

  GoRouter _createRouter() => GoRouter(
        initialLocation: '/splash',
        refreshListenable: _routerRefreshNotifier,
        routes: _buildRoutes(),
        redirect: _guardRedirect,
      );

  List<RouteBase> _buildRoutes() => [
        GoRoute(
          path: '/splash',
          name: 'splash',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const _SplashScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: CurveTween(curve: Curves.easeOut).animate(animation),
                child: child,
              );
            },
          ),
        ),
        GoRoute(
          path: '/login',
          name: 'login',
          pageBuilder: (context, state) => buildOpeiTransitionPage(
            state: state,
            child: const LoginScreen(),
          ),
        ),
        GoRoute(
          path: '/signup',
          name: 'signup',
          pageBuilder: (context, state) => buildOpeiTransitionPage(
            state: state,
            child: const SignupScreen(),
          ),
        ),
        GoRoute(
          path: '/verify-email',
          name: 'verify-email',
          pageBuilder: (context, state) {
            final autoSend = state.uri.queryParameters['autoSend'] == 'true';
            return buildOpeiTransitionPage(
              state: state,
              child: VerifyEmailScreen(autoSendCode: autoSend),
            );
          },
        ),
        GoRoute(
          path: '/forgot-password',
          name: 'forgot-password',
          pageBuilder: (context, state) => buildOpeiTransitionPage(
            state: state,
            child: const ForgotPasswordScreen(),
          ),
        ),
        GoRoute(
          path: '/reset-password',
          name: 'reset-password',
          pageBuilder: (context, state) {
            final email = state.uri.queryParameters['email'] ?? '';
            return buildOpeiTransitionPage(
              state: state,
              child: ResetPasswordScreen(email: email),
            );
          },
        ),
        GoRoute(
          path: '/address',
          name: 'address',
          pageBuilder: (context, state) {
            final isFromProfile = state.uri.queryParameters['source'] == 'profile';
            return buildOpeiTransitionPage(
              state: state,
              child: AddressScreen(isFromProfile: isFromProfile),
            );
          },
        ),
        GoRoute(
          path: '/kyc',
          name: 'kyc',
          pageBuilder: (context, state) => buildOpeiTransitionPage(
            state: state,
            child: const KycScreen(),
          ),
        ),
        GoRoute(
          path: '/quick-auth-setup',
          name: 'quick-auth-setup',
          pageBuilder: (context, state) => buildOpeiTransitionPage(
            state: state,
            child: QuickAuthSetupScreen(
              popOnComplete: state.extra is bool ? state.extra as bool : false,
            ),
          ),
        ),
        GoRoute(
          path: '/quick-auth',
          name: 'quick-auth',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const QuickAuthScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: CurveTween(curve: Curves.easeOut).animate(animation),
                child: child,
              );
            },
          ),
        ),
        GoRoute(
          path: '/dashboard',
          name: 'dashboard',
          pageBuilder: (context, state) => buildOpeiTransitionPage(
            state: state,
            child: const DashboardScreen(),
          ),
        ),
        GoRoute(
          path: '/transactions',
          name: 'transactions',
          pageBuilder: (context, state) => buildOpeiTransitionPage(
            state: state,
            child: const TransactionsScreen(),
          ),
        ),
        GoRoute(
          path: '/profile',
          name: 'profile',
          pageBuilder: (context, state) => buildOpeiTransitionPage(
            state: state,
            child: const ProfileScreen(),
          ),
        ),
        GoRoute(
          path: '/send-money',
          name: 'send-money',
          pageBuilder: (context, state) => buildOpeiTransitionPage(
            state: state,
            child: const SendMoneyScreen(),
          ),
        ),
        GoRoute(
          path: '/p2p',
          name: 'p2p',
          pageBuilder: (context, state) {
            final intentRaw = state.uri.queryParameters['intent'];
            final intentParam = intentRaw?.toLowerCase().trim();
            P2PAdType? initialType;
            if (intentParam == 'sell') {
              initialType = P2PAdType.sell;
            } else if (intentParam == 'buy') {
              initialType = P2PAdType.buy;
            }

            return buildOpeiTransitionPage(
              state: state,
              child: P2PExchangeScreen(initialType: initialType),
            );
          },
        ),
        GoRoute(
          path: '/p2p/rate-trade',
          name: 'p2p-rate-trade',
          pageBuilder: (context, state) {
            final trade = state.extra as P2PTrade;
            return buildOpeiTransitionPage(
              state: state,
              child: P2PRatingScreen(trade: trade),
            );
          },
        ),
        GoRoute(
          path: '/deposit/crypto-currency',
          name: 'deposit-crypto-currency',
          pageBuilder: (context, state) => buildOpeiTransitionPage(
            state: state,
            child: const CryptoCurrencySelectionScreen(),
          ),
        ),
        GoRoute(
          path: '/deposit/crypto-network',
          name: 'deposit-crypto-network',
          pageBuilder: (context, state) {
            final currency = state.extra as String;
            return buildOpeiTransitionPage(
              state: state,
              child: CryptoNetworkSelectionScreen(currency: currency),
            );
          },
        ),
        GoRoute(
          path: '/deposit/crypto-address',
          name: 'deposit-crypto-address',
          pageBuilder: (context, state) {
            final params = state.extra as Map<String, String>;
            return buildOpeiTransitionPage(
              state: state,
              child: CryptoAddressDisplayScreen(
                currency: params['currency']!,
                network: params['network']!,
              ),
            );
          },
        ),
        GoRoute(
          path: '/withdraw/crypto-currency',
          name: 'withdraw-crypto-currency',
          pageBuilder: (context, state) => buildOpeiTransitionPage(
            state: state,
            child: const WithdrawCurrencySelectionScreen(),
          ),
        ),
        GoRoute(
          path: '/withdraw/crypto-network',
          name: 'withdraw-crypto-network',
          pageBuilder: (context, state) {
            final currency = state.extra as String;
            return buildOpeiTransitionPage(
              state: state,
              child: WithdrawNetworkSelectionScreen(currency: currency),
            );
          },
        ),
        GoRoute(
          path: '/withdraw/crypto-form',
          name: 'withdraw-crypto-form',
          pageBuilder: (context, state) {
            final params = state.extra as Map<String, String>;
            return buildOpeiTransitionPage(
              state: state,
              child: CryptoWithdrawFormScreen(
                currency: params['currency']!,
                network: params['network']!,
              ),
            );
          },
        ),
        GoRoute(
          path: '/withdraw/crypto-success',
          name: 'withdraw-crypto-success',
          pageBuilder: (context, state) {
            final params = state.extra as Map<String, String>;
            return buildOpeiTransitionPage(
              state: state,
              child: CryptoWithdrawSuccessScreen(
                currency: params['currency']!,
                network: params['network']!,
              ),
            );
          },
        ),
      ];

  String? _guardRedirect(BuildContext context, GoRouterState state) {
    final location = state.uri.path;
    final session = ref.read(authSessionProvider);

    if (location == '/splash') {
      if (!session.isAuthenticated) {
        return null;
      }
      final stage = session.userStage;
      if (stage == null) {
        return null;
      }
      final stageRoute = _stageRouteFor(stage);
      if (stageRoute != null) {
        return stageRoute;
      }
      return '/dashboard';
    }

    if (!session.isAuthenticated) {
      if (_isPublicPath(location)) {
        return null;
      }
      return '/login';
    }

    if (location == '/quick-auth' || location == '/quick-auth-setup') {
      return null;
    }

    final stage = session.userStage;
    if (stage == null) {
      return '/splash';
    }

    final stageRoute = _stageRouteFor(stage);
    if (stageRoute != null) {
      final requiredPath = _basePath(stageRoute);
      if (location != requiredPath) {
        return stageRoute;
      }
      return null;
    }

    if (_isOnboardingPath(location) || location == '/login' || location == '/signup') {
      return '/dashboard';
    }

    return null;
  }

  bool _isPublicPath(String path) {
    if (path.startsWith('/reset-password')) {
      return true;
    }
    return _publicPaths.contains(path);
  }

  bool _isOnboardingPath(String path) => _onboardingPaths.contains(path);

  String? _stageRouteFor(String stage) {
    switch (stage.toUpperCase()) {
      case 'PENDING_EMAIL':
        return '/verify-email?autoSend=true';
      case 'PENDING_ADDRESS':
        return '/address';
      case 'PENDING_KYC':
        return '/kyc';
      case 'VERIFIED':
        return null;
      default:
        return '/kyc';
    }
  }

  String _basePath(String route) {
    final questionMarkIndex = route.indexOf('?');
    if (questionMarkIndex == -1) {
      return route;
    }
    return route.substring(0, questionMarkIndex);
  }
}

class _SplashScreen extends ConsumerStatefulWidget {
  const _SplashScreen();

  @override
  ConsumerState<_SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<_SplashScreen> {
  @override
  void initState() {
    super.initState();
    _determineInitialRoute();
  }

  Future<void> _determineInitialRoute() async {
    final quickAuthService = ref.read(quickAuthServiceProvider);
    final storage = ref.read(secureStorageServiceProvider);
    final userRepo = ref.read(userRepositoryProvider);
    final authRepo = ref.read(authRepositoryProvider);

    final refreshToken = await storage.getRefreshToken();

    if (refreshToken == null) {
      if (mounted) context.go('/login');
      return;
    }

    final accessToken = await storage.getToken();
    final storedUser = await storage.getUser();
    var userIdentifier = storedUser?.id;
    userIdentifier ??= await quickAuthService.getRegisteredUserId();

    final hasPinSetup = userIdentifier != null
        ? await quickAuthService.hasPinSetup(userIdentifier)
        : false;

    if (hasPinSetup) {
      if (mounted) context.go('/quick-auth');
      return;
    }

    try {
      if (accessToken != null) {
        final user = await userRepo.getCurrentUser();
        await storage.saveUser(user);
        ref.read(authSessionProvider.notifier).setSession(
          userId: user.id,
          accessToken: accessToken,
          userStage: user.userStage,
        );
        if (mounted) context.go('/dashboard');
        return;
      }
    } catch (e) {
      debugPrint('⚠️ Access token validation failed, attempting refresh: $e');
    }

    try {
      final response = await authRepo.refreshAccessToken(refreshToken);
      await storage.saveUser(response.user);
      ref.read(authSessionProvider.notifier).setSession(
        userId: response.user.id,
        accessToken: response.accessToken,
        userStage: response.user.userStage,
      );
      if (mounted) context.go('/dashboard');
      return;
    } catch (e) {
      debugPrint('❌ Unable to refresh session at launch: $e');
      final registeredUserId = await quickAuthService.getRegisteredUserId();
      await storage.clearSessionPreserveQuickAuth(removeStoredUser: true);
      if (registeredUserId != null) {
        await storage.clearSessionLockTimestamp(registeredUserId);
        await storage.clearCurrentQuickAuthUserId();
        await quickAuthService.clearUserData(registeredUserId, removeSetupFlag: true);
      }
      if (mounted) context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) => const Scaffold(
        backgroundColor: OpeiColors.pureWhite,
        body: Center(
          child: CircularProgressIndicator(color: OpeiColors.pureBlack),
        ),
      );
}
