import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/constants/api_endpoints.dart';
import '../../../core/models/api_response.dart';
import '../../../core/services/base_api_service.dart';
import '../models/auth_tokens.dart';
import '../models/user_model.dart';

part 'auth_repository.g.dart';

@riverpod
AuthRepository authRepository(Ref ref) => AuthRepository(ref);

class AuthRepository extends BaseApiService {
  AuthRepository(super.ref);

  /// POST /auth/login — exchanges credentials for an access/refresh pair.
  Future<ApiResponse<AuthTokens>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await post(
        ApiEndpoints.login,
        data: {'email': email, 'password': password},
      );
      final tokens = AuthTokens.fromJson(response.data as Map<String, dynamic>);
      return ApiResponse.success(tokens, statusCode: response.statusCode);
    } on DioException catch (e) {
      return ApiResponse.failure(
        e.message ?? getDioErrorType(e).message,
        statusCode: e.response?.statusCode,
      );
    }
  }

  /// GET /auth/profile — fetches the currently authenticated user.
  /// The Bearer token is attached by the global auth interceptor.
  Future<ApiResponse<UserModel>> fetchProfile() async {
    try {
      final response = await get(ApiEndpoints.profile);
      final user = UserModel.fromJson(response.data as Map<String, dynamic>);
      return ApiResponse.success(user, statusCode: response.statusCode);
    } on DioException catch (e) {
      return ApiResponse.failure(
        e.message ?? getDioErrorType(e).message,
        statusCode: e.response?.statusCode,
      );
    }
  }
}
