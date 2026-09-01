import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'storage_service.g.dart';

/// Modern async-init pattern: `build()` returns a `Future` so the provider
/// state is `AsyncValue<SharedPreferences>`. Consumers can either:
///
///   - `await ref.read(storageServiceProvider.future)` to use the instance,
///   - or `ref.watch(storageServiceProvider).when(...)` to react to it.
///
/// Inside the notifier, methods read `future` to get the resolved
/// `SharedPreferences`.
@Riverpod(keepAlive: true)
class StorageService extends _$StorageService {
  @override
  Future<SharedPreferences> build() async {
    return SharedPreferences.getInstance();
  }

  // String
  Future<void> setString(String key, String value) async {
    final prefs = await future;
    await prefs.setString(key, value);
  }

  Future<String?> getString(String key) async {
    final prefs = await future;
    return prefs.getString(key);
  }

  // Bool
  Future<void> setBool(String key, bool value) async {
    final prefs = await future;
    await prefs.setBool(key, value);
  }

  Future<bool?> getBool(String key) async {
    final prefs = await future;
    return prefs.getBool(key);
  }

  // Int
  Future<void> setInt(String key, int value) async {
    final prefs = await future;
    await prefs.setInt(key, value);
  }

  Future<int?> getInt(String key) async {
    final prefs = await future;
    return prefs.getInt(key);
  }

  // Double
  Future<void> setDouble(String key, double value) async {
    final prefs = await future;
    await prefs.setDouble(key, value);
  }

  Future<double?> getDouble(String key) async {
    final prefs = await future;
    return prefs.getDouble(key);
  }

  // JSON
  Future<void> setJson(String key, Map<String, dynamic> value) async {
    final prefs = await future;
    await prefs.setString(key, jsonEncode(value));
  }

  Future<Map<String, dynamic>?> getJson(String key) async {
    final prefs = await future;
    final raw = prefs.getString(key);
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('StorageService.getJson decode error: $e');
      return null;
    }
  }

  Future<void> remove(String key) async {
    final prefs = await future;
    await prefs.remove(key);
  }

  Future<void> clearAll() async {
    final prefs = await future;
    await prefs.clear();
  }
}
