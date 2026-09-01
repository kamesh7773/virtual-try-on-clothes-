import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'internet_service.g.dart';

@Riverpod(keepAlive: true)
class InternetService extends _$InternetService {
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  final Connectivity _connectivity = Connectivity();

  @override
  bool build() {
    ref.onDispose(() => _subscription?.cancel());
    _init();
    return true;
  }

  Future<void> _init() async {
    try {
      final result = await _connectivity.checkConnectivity();
      state = _isConnected(result);
    } catch (e) {
      if (kDebugMode) debugPrint('InternetService init error: $e');
      state = false;
    }

    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      state = _isConnected(results);
    });
  }

  bool _isConnected(List<ConnectivityResult> results) =>
      results.isNotEmpty && !results.contains(ConnectivityResult.none);

  Future<bool> checkConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      final connected = _isConnected(result);
      state = connected;
      return connected;
    } catch (_) {
      state = false;
      return false;
    }
  }
}
