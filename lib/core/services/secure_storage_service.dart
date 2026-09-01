import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'secure_storage_service.g.dart';

/// Secure key-value storage backed by Keychain (iOS) / EncryptedSharedPrefs
/// migration target (Android v10+). Exposed as a Riverpod service so it can
/// be injected like any other dependency:
///
/// ```dart
/// final token = await ref.read(secureStorageServiceProvider.notifier).getToken();
/// ```
@Riverpod(keepAlive: true)
class SecureStorageService extends _$SecureStorageService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  // Keys
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _firstLaunchKey = 'first_launch';
  static const String _userIdKey = 'user_id';

  @override
  void build() {}

  // Auth tokens
  Future<void> saveToken(String token) =>
      _storage.write(key: _tokenKey, value: token);

  Future<String?> getToken() => _storage.read(key: _tokenKey);

  Future<void> saveRefreshToken(String token) =>
      _storage.write(key: _refreshTokenKey, value: token);

  Future<String?> getRefreshToken() => _storage.read(key: _refreshTokenKey);

  Future<void> deleteTokens() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }

  // User ID
  Future<void> saveUserId(String id) =>
      _storage.write(key: _userIdKey, value: id);

  Future<String?> getUserId() => _storage.read(key: _userIdKey);

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
