import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'secure_storage_service.g.dart';

/// Secure key-value storage backed by Keychain (iOS) / EncryptedSharedPrefs
/// migration target (Android v10+). Exposed as a Riverpod service so it can
/// be injected like any other dependency:
///
/// ```dart
/// final key = await ref.read(secureStorageServiceProvider.notifier).getApiKey();
/// ```
@Riverpod(keepAlive: true)
class SecureStorageService extends _$SecureStorageService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  // Keys
  static const String _apiKeyKey = 'decart_api_key';
  static const String _firstLaunchKey = 'first_launch';

  @override
  void build() {}

  // Decart API key — user-supplied via the in-app settings sheet. Takes
  // precedence over the build-time key in `.env.*`.
  Future<void> saveApiKey(String apiKey) =>
      _storage.write(key: _apiKeyKey, value: apiKey);

  Future<String?> getApiKey() => _storage.read(key: _apiKeyKey);

  Future<void> deleteApiKey() => _storage.delete(key: _apiKeyKey);

  // First-launch flag
  Future<bool> isFirstLaunch() async {
    final value = await _storage.read(key: _firstLaunchKey);
    return value == null;
  }

  Future<void> markFirstLaunchComplete() =>
      _storage.write(key: _firstLaunchKey, value: 'done');

  // Generic read/write/delete
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  Future<String?> read(String key) => _storage.read(key: key);

  Future<void> delete(String key) => _storage.delete(key: key);

  Future<bool> containsKey(String key) => _storage.containsKey(key: key);

  Future<void> deleteAll() => _storage.deleteAll();
}
