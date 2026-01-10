import 'package:flutter_test/flutter_test.dart';
import 'package:opei/core/config/environment.dart';

void main() {
  setUp(Environment.debugReset);
  tearDown(Environment.debugReset);

  test('debugOverride forces environment and config values', () {
    Environment.debugOverride(
      environment: AppEnvironment.dev,
      apiBaseUrl: 'https://api.dev',
      apiVersion: 'v2',
      sentryDsn: 'dsn-dev',
      name: 'Dev Env',
    );

    expect(Environment.current, AppEnvironment.dev);
    expect(Environment.apiBaseUrl, 'https://api.dev');
    expect(Environment.apiVersion, 'v2');
    expect(Environment.sentryDsn, 'dsn-dev');
    expect(Environment.name, 'Dev Env');
  });

  test('debugOverride with only environment uses default config for that env', () {
    Environment.debugOverride(environment: AppEnvironment.staging);

    expect(Environment.current, AppEnvironment.staging);
    expect(Environment.apiVersion, 'v1');
    expect(Environment.apiBaseUrl, 'https://api.opeiapi.com');
  });

  test('debugReset restores default production config', () {
    Environment.debugOverride(environment: AppEnvironment.dev, apiBaseUrl: 'https://api.dev');
    Environment.debugReset();

    expect(Environment.current, AppEnvironment.prod);
    expect(Environment.name, 'Production');
  });
}
