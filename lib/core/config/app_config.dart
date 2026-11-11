import 'environment.dart';
import 'flavor.dart';

export 'environment.dart';
export 'flavor.dart';

class AppConfig {
  const AppConfig({
    required this.environment,
    required this.flavor,
    required this.baseUrl,
  });

  final Environment environment;
  final Flavor flavor;
  final String baseUrl;

  String get serverBaseUrl {
    final uri = Uri.parse(baseUrl);
    return '${uri.scheme}://${uri.host}${uri.hasPort ? ':${uri.port}' : ''}';
  }

  static const String _environment = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'development',
  );

  static const String _apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://allround.localbox.online/api/v1',
  );

  static AppConfig get current {
    final environment = Environment.fromString(_environment);

    return AppConfig(
      environment: environment,
      flavor: _flavorFromEnvironment(environment),
      baseUrl: _apiBaseUrl,
    );
  }

  static Flavor _flavorFromEnvironment(Environment environment) {
    switch (environment) {
      case Environment.development:
        return Flavor.development;
      case Environment.staging:
        return Flavor.staging;
      case Environment.production:
        return Flavor.production;
    }
  }

  bool get isDevelopment => environment == Environment.development;
  bool get isStaging => environment == Environment.staging;
  bool get isProduction => environment == Environment.production;

  static const String baseURL = _apiBaseUrl;
  static const String defaultLanguageKey = 'en';
}
