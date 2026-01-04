enum AppEnvironment {
  dev,
  staging,
  prod,
}

class Environment {
  Environment._();

  static const String _defaultEnvString =
      String.fromEnvironment('APP_ENV', defaultValue: 'prod');

  static AppEnvironment? _overrideEnvironment;
  static _EnvironmentConfig? _overrideConfig;

  static final _configByEnv = <AppEnvironment, _EnvironmentConfig>{
    AppEnvironment.dev: _EnvironmentConfig(
      name: 'Development',
      apiBaseUrl: 'https://api.opeiapi.com',
      apiVersion: 'v1',
      sentryDsn: '',
    ),
    AppEnvironment.staging: _EnvironmentConfig(
      name: 'Staging',
      apiBaseUrl: 'https://api.opeiapi.com',
      apiVersion: 'v1',
      sentryDsn: '',
    ),
    AppEnvironment.prod: _EnvironmentConfig(
      name: 'Production',
      apiBaseUrl: 'https://api.opeiapi.com',
      apiVersion: 'v1',
      sentryDsn: 'https://4fadee834f3f650265108cfd2a0c3064@o4510534698598400.ingest.us.sentry.io/4510622379868160',
    ),
  };

  static AppEnvironment get current =>
      _overrideEnvironment ?? _parseEnvironment(_defaultEnvString);

  static _EnvironmentConfig get _activeConfig {
    if (_overrideConfig != null) {
      return _overrideConfig!;
    }
    final env = _overrideEnvironment ?? _parseEnvironment(_defaultEnvString);
    return _configByEnv[env]!;
  }

  static String get name => _activeConfig.name;

  static String get apiBaseUrl {
    const override = String.fromEnvironment('API_BASE_URL');
    if (override.isNotEmpty) {
      return override;
    }
    return _activeConfig.apiBaseUrl;
  }

  static String get apiVersion => _activeConfig.apiVersion;

  static String get sentryDsn {
    const override = String.fromEnvironment('SENTRY_DSN');
    if (override.isNotEmpty) {
      return override;
    }
    return _activeConfig.sentryDsn;
  }

  /// Allows tests to force environment/config values without impacting release builds.
  static void debugOverride({
    AppEnvironment? environment,
    String? apiBaseUrl,
    String? apiVersion,
    String? sentryDsn,
    String? name,
  }) {
    assert(() {
      _overrideEnvironment = environment;
      final shouldOverrideConfig =
          apiBaseUrl != null || apiVersion != null || sentryDsn != null || name != null;
      if (shouldOverrideConfig) {
        final baseEnv = environment ?? _parseEnvironment(_defaultEnvString);
        final fallback = _configByEnv[baseEnv]!;
        _overrideConfig = _EnvironmentConfig(
          name: name ?? fallback.name,
          apiBaseUrl: apiBaseUrl ?? fallback.apiBaseUrl,
          apiVersion: apiVersion ?? fallback.apiVersion,
          sentryDsn: sentryDsn ?? fallback.sentryDsn,
        );
      } else {
        _overrideConfig = null;
      }
      return true;
    }());
  }

  static void debugReset() {
    assert(() {
      _overrideEnvironment = null;
      _overrideConfig = null;
      return true;
    }());
  }

  static AppEnvironment _parseEnvironment(String value) {
    switch (value.toLowerCase()) {
      case 'dev':
      case 'development':
        return AppEnvironment.dev;
      case 'staging':
        return AppEnvironment.staging;
      case 'prod':
      case 'production':
      default:
        return AppEnvironment.prod;
    }
  }
}

class _EnvironmentConfig {
  const _EnvironmentConfig({
    required this.name,
    required this.apiBaseUrl,
    required this.apiVersion,
    required this.sentryDsn,
  });

  final String name;
  final String apiBaseUrl;
  final String apiVersion;
  final String sentryDsn;
}
