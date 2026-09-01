import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

enum Environment {
  development,
  staging,
  production,
}

class Env {
  static late Environment _environment;
  static Environment get environment => _environment;

  Env._();

  static Future<void> init(Environment environment) async {
    _environment = environment;
    String fileName;

    switch (environment) {
      case Environment.development:
        fileName = '.env.development';
        break;
      case Environment.staging:
        fileName = '.env.staging';
        break;
      case Environment.production:
        fileName = '.env.production';
        break;
    }

    await dotenv.load(fileName: fileName);
    _logConfiguration(fileName);
  }

  static void _logConfiguration(String fileName) {
    if (kReleaseMode && !enableLogs) return;

    final flavor = _environment.name.toUpperCase();
    final banner = '''
╔══════════════════════════════════════════════════════════╗
║  🚀 App launched — flavor: $flavor
╠══════════════════════════════════════════════════════════╣
║  env file        : $fileName
║  API_BASE_URL    : $apiBaseUrl
║  API_VERSION     : $apiVersion
║  MODEL           : $realtimeModel
║  DECART_API_KEY  : ${hasDecartApiKey ? 'set' : 'not set'}
║  TOKEN_ENDPOINT  : ${tokenEndpoint ?? 'not set'}
║  ENABLE_LOGS     : $enableLogs
║  ENABLE_ANALYTICS: $enableAnalytics
║  ENABLE_CRASH    : $enableCrashReporting
╚══════════════════════════════════════════════════════════╝''';

    debugPrint(banner);
  }

  static String get apiBaseUrl => dotenv.env['API_BASE_URL'] ?? '';
  static String get apiWsBaseUrl => dotenv.env['API_WS_BASE_URL'] ?? '';
  static String get apiVersion => dotenv.env['API_VERSION'] ?? 'v1';

  /// Realtime model the try-on session connects with.
  static String get realtimeModel =>
      dotenv.env['DECART_REALTIME_MODEL'] ?? 'lucy-vton-latest';

  /// Backend that mints ephemeral client tokens. When set, it is preferred
  /// over [decartApiKey] — the app never handles the long-lived key.
  static String? get tokenEndpoint {
    final url = dotenv.env['TOKEN_ENDPOINT'];
    return (url == null || url.isEmpty) ? null : url;
  }

  static bool get hasTokenEndpoint => tokenEndpoint != null;

  /// Build-time, long-lived Decart API key.
  ///
  /// Only populated in development/staging — it can mint client tokens, so
  /// shipping it in a release binary would let anyone extract it. Release
  /// builds leave it blank and go through [tokenEndpoint] instead. A
  /// user-supplied key in `SecureStorageService` takes precedence over both.
  static String? get decartApiKey {
    final key = dotenv.env['DECART_API_KEY'];
    return (key == null || key.isEmpty) ? null : key;
  }

  static bool get hasDecartApiKey => decartApiKey != null;

  static bool get enableLogs => dotenv.env['ENABLE_LOGS'] == 'true';
  static bool get enableAnalytics => dotenv.env['ENABLE_ANALYTICS'] == 'true';
  static bool get enableCrashReporting =>
      dotenv.env['ENABLE_CRASH_REPORTING'] == 'true';

  static bool get isDevelopment => _environment == Environment.development;
  static bool get isStaging => _environment == Environment.staging;
  static bool get isProduction => _environment == Environment.production;
}
