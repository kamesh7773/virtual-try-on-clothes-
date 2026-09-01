---
description: Guidelines for implementing services in the Indikosh app
globs: lib/**/services/*.dart
alwaysApply: false
---
 # Services Implementation

## Core Services

- Use @Riverpod(keepAlive: true) for global services
- Implement as singletons
- Clear responsibility
- Handle cleanup
- Example:

```dart
@Riverpod(keepAlive: true)
class NavigationService extends _$NavigationService {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void build() {}

  GlobalKey<NavigatorState> get navigatorKey => _navigatorKey;

  BuildContext? get context => _navigatorKey.currentContext;

  Future<dynamic> navigateTo(String routeName, {Object? arguments}) {
    return _navigatorKey.currentState!.pushNamed(
      routeName,
      arguments: arguments,
    );
  }

  Future<dynamic> navigateToAndRemoveUntil(
    String routeName, {
    Object? arguments,
  }) {
    return _navigatorKey.currentState!.pushNamedAndRemoveUntil(
      routeName,
      (Route<dynamic> route) => false,
      arguments: arguments,
    );
  }

  void goBack() {
    if (_navigatorKey.currentState!.canPop()) {
      _navigatorKey.currentState!.pop();
    }
  }
}

@Riverpod(keepAlive: true)
class SecureStorage extends _$SecureStorage {
  late final FlutterSecureStorage _storage;
  
  @override
  void build() {
    _storage = const FlutterSecureStorage(
      aOptions: AndroidOptions(
        encryptedSharedPreferences: true,
      ),
    );
  }

  Future<void> saveToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: 'auth_token');
  }

  Future<void> deleteAll() async {
    await _storage.deleteAll();
  }
}
```

## API Client

- Configure Dio with interceptors
- Handle authentication
- Set up base URL and headers
- Handle request/response logging
- Example:

```dart
@Riverpod(keepAlive: true)
ApiClient apiClient(ApiClientRef ref) {
  final secureStorage = ref.watch(secureStorageProvider.notifier);
  return ApiClient._(secureStorage);
}

class ApiClient {
  final Dio dio;
  final SecureStorage _secureStorage;

  ApiClient._(this._secureStorage) : dio = Dio() {
    _configureClient();
  }

  void _configureClient() {
    dio.options = BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    // Add interceptors
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add auth token to requests if available
          final token = await _secureStorage.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          return handler.next(response);
        },
        onError: (DioException e, handler) async {
          // Handle token refresh on 401 errors
          if (e.response?.statusCode == 401) {
            try {
              // Try to refresh token
              final refreshed = await _refreshToken();
              if (refreshed) {
                // Retry the original request
                return handler.resolve(await _retryRequest(e.requestOptions));
              }
            } catch (_) {
              // If refresh fails, proceed with error
            }
          }
          return handler.next(e);
        },
      ),
    );

    // Add logging in debug mode
    if (kDebugMode) {
      dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
      ));
    }
  }

  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _secureStorage.getRefreshToken();
      if (refreshToken == null) return false;

      final response = await Dio().post(
        '${ApiConfig.baseUrl}/auth/refresh',
        data: {'refresh_token': refreshToken},
      );

      if (response.statusCode == 200) {
        final newToken = response.data['access_token'] as String;
        await _secureStorage.saveToken(newToken);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<Response<dynamic>> _retryRequest(RequestOptions requestOptions) async {
    final token = await _secureStorage.getToken();
    final options = Options(
      method: requestOptions.method,
      headers: {
        ...requestOptions.headers,
        'Authorization': 'Bearer $token',
      },
    );

    return dio.request<dynamic>(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }
}
```

## Custom Hooks

- Create reusable hooks for common patterns
- Handle screen lifecycle events
- Manage form state
- Example:

```dart
void useInitialLoad(WidgetRef ref, {required VoidCallback onLoad}) {
  useEffect(() {
    onLoad();
    return null;
  }, const []);
}

FocusNode useScreenFocus(
  WidgetRef ref, {
  required ValueNotifier<bool> isRefreshing,
  required VoidCallback onFocusGained,
}) {
  final focusNode = useFocusNode();

  useEffect(() {
    void onFocusChange() {
      if (focusNode.hasFocus && !isRefreshing.value) {
        isRefreshing.value = true;
        onFocusGained();
        isRefreshing.value = false;
      }
    }

    focusNode.addListener(onFocusChange);
    return () => focusNode.removeListener(onFocusChange);
  }, [focusNode]);

  return focusNode;
}

void useAppLifecycle(
  WidgetRef ref, {
  required ValueNotifier<bool> isRefreshing,
  required VoidCallback onResumeFromBackground,
}) {
  final appLifecycleState = useAppLifecycleState();
  final previousState = useRef<AppLifecycleState?>(null);

  useEffect(() {
    if (previousState.value == AppLifecycleState.paused &&
        appLifecycleState == AppLifecycleState.resumed &&
        !isRefreshing.value) {
      isRefreshing.value = true;
      onResumeFromBackground();
      isRefreshing.value = false;
    }
    previousState.value = appLifecycleState;
    return null;
  }, [appLifecycleState]);
}
```