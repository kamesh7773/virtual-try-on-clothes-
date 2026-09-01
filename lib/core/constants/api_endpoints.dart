import '../config/env.dart';

class ApiEndpoints {
  ApiEndpoints._();

  static String get baseUrl => Env.apiBaseUrl;

  // Auth (Platzi Fake Store API)
  static const String login = '/auth/login';
  static const String refreshToken = '/auth/refresh-token';
  static const String profile = '/auth/profile';
  static const String register = '/users';

  // Products
  static const String products = '/products';
  static String productById(int id) => '/products/$id';
  static const String categories = '/categories';
}
