enum AppEnvironment {
  dev,
  staging,
  prod,
}

class Environment {
  Environment._();

  static final AppEnvironment current = _parseEnvironment(
    const String.fromEnvironment('APP_ENV', defaultValue: 'prod'),
  );

  static final _configByEnv = <AppEnvironment, _EnvironmentConfig>{
    AppEnvironment.dev: _EnvironmentConfig(
    name: 'Development',
    apiBaseUrl: 'https://opei-gateway-production.up.railway.app',
      apiVersion: 'v1',
      sentryDsn: '',
    ),
    AppEnvironment.staging: _EnvironmentConfig(
      name: 'Staging',
    apiBaseUrl: 'https://opei-gateway-production.up.railway.app',
      apiVersion: 'v1',
      sentryDsn: '',
    ),
    AppEnvironment.prod: _EnvironmentConfig(
      name: 'Production',
      apiBaseUrl: 'https://opei-gateway-production.up.railway.app',
      apiVersion: 'v1',
      sentryDsn: 'https://4fadee834f3f650265108cfd2a0c3064@o4510534698598400.ingest.us.sentry.io/4510622379868160',
    ),
  };

  static _EnvironmentConfig get _activeConfig => _configByEnv[current]!;

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
