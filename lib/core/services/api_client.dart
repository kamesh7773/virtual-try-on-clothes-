import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../config/env.dart';
import '../constants/api_endpoints.dart';
import '../constants/app_constants.dart';
import 'secure_storage_service.dart';

part 'api_client.g.dart';

/// Function-style provider — returns a fully configured Dio instance.
/// Consumers read `ref.watch(apiClientProvider)` to get the Dio directly.
@Riverpod(keepAlive: true)
Dio apiClient(Ref ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiEndpoints.baseUrl,
      connectTimeout: AppConstants.connectionTimeout,
      receiveTimeout: AppConstants.receiveTimeout,
      sendTimeout: AppConstants.sendTimeout,
      headers: const {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ),
  );

  dio.interceptors.add(_authInterceptor(dio, ref));

  if (Env.enableLogs && kDebugMode) {
    dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: false,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        compact: true,
        maxWidth: 90,
      ),
    );
  }

  return dio;
}

bool _isAuthFreeEndpoint(String path) =>
    path.endsWith(ApiEndpoints.login) ||
    path.endsWith(ApiEndpoints.refreshToken);

Interceptor _authInterceptor(Dio dio, Ref ref) {
  return InterceptorsWrapper(
    onRequest: (options, handler) async {
      final apiToken = Env.apiToken;
      if (apiToken != null && apiToken.isNotEmpty) {
        options.headers['Api-Token'] = apiToken;
      }

      if (!_isAuthFreeEndpoint(options.path)) {
        final storage = ref.read(secureStorageServiceProvider.notifier);
        final token = await storage.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
      }

      return handler.next(options);
    },
    onError: (error, handler) async {
      final storage = ref.read(secureStorageServiceProvider.notifier);

      final canRefresh = error.response?.statusCode == 401 &&
          !_isAuthFreeEndpoint(error.requestOptions.path);

      if (canRefresh) {
        final tokens = await _refreshTokens(dio, storage);
        if (tokens != null) {
          final retry = error.requestOptions;
          retry.headers['Authorization'] = 'Bearer ${tokens.$1}';
          try {
            final response = await dio.fetch(retry);
            return handler.resolve(response);
          } catch (_) {
            // fall through to error mapping below
          }
        } else {
          // Refresh failed (or no refresh token) — clear stored creds so the
          // auth gate flips back to the login screen on next bootstrap.
          await storage.deleteTokens();
        }
      }

      String message = 'Something went wrong';
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.sendTimeout ||
          error.type == DioExceptionType.connectionError) {
        message = 'No internet connection, please check your connection';
      } else if (error.response?.data is Map<String, dynamic>) {
        final data = error.response!.data as Map<String, dynamic>;
        if (data['message'] != null) {
          message = data['message'].toString();
        } else if (data['error'] != null) {
          message = data['error'].toString();
        }
      }

      return handler.next(
        DioException(
          requestOptions: error.requestOptions,
          error: message,
          type: error.type,
          message: message,
          response: error.response,
        ),
      );
    },
  );
}

/// Calls the Platzi refresh endpoint and stores the new tokens.
/// Returns `(accessToken, refreshToken)` on success, otherwise `null`.
Future<(String, String)?> _refreshTokens(
  Dio dio,
  SecureStorageService storage,
) async {
  try {
    final refresh = await storage.getRefreshToken();
    if (refresh == null) return null;

    final response = await dio.post(
      ApiEndpoints.refreshToken,
      data: {'refreshToken': refresh},
    );

    if (response.data is! Map<String, dynamic>) return null;
    final data = response.data as Map<String, dynamic>;
    final access = data['access_token'] as String?;
    final newRefresh = data['refresh_token'] as String?;
    if (access == null || newRefresh == null) return null;

    await storage.saveToken(access);
    await storage.saveRefreshToken(newRefresh);
    return (access, newRefresh);
  } catch (_) {
    return null;
  }
}
