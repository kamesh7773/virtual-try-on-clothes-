import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/constants/api_endpoints.dart';
import '../../../core/models/api_response.dart';
import '../../../core/services/base_api_service.dart';
import '../models/product_model.dart';

part 'home_repository.g.dart';

@riverpod
HomeRepository homeRepository(Ref ref) => HomeRepository(ref);

List<ProductModel> _parseProducts(List<dynamic> raw) => raw
    .whereType<Map<String, dynamic>>()
    .map(ProductModel.fromJson)
    .toList(growable: false);

ProductModel _parseProduct(Map<String, dynamic> json) =>
    ProductModel.fromJson(json);

class HomeRepository extends BaseApiService {
  HomeRepository(super.ref);

  /// GET /products — paginated list.
  Future<ApiResponse<List<ProductModel>>> fetchProducts({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await get(
        ApiEndpoints.products,
        queryParameters: {'limit': limit, 'offset': offset},
      );

      final raw = response.data as List<dynamic>;
      final data = await compute<List<dynamic>, List<ProductModel>>(
        _parseProducts,
        raw,
      );
      return ApiResponse.success(data, statusCode: response.statusCode);
    } on DioException catch (e) {
      return ApiResponse.failure(
        e.message ?? getDioErrorType(e).message,
        statusCode: e.response?.statusCode,
      );
    }
  }

  /// GET /products/{id} — single product.
  Future<ApiResponse<ProductModel>> fetchProductById(int id) async {
    try {
      final response = await get(ApiEndpoints.productById(id));
      final product = await compute<Map<String, dynamic>, ProductModel>(
        _parseProduct,
        response.data as Map<String, dynamic>,
      );
      return ApiResponse.success(product, statusCode: response.statusCode);
    } on DioException catch (e) {
      return ApiResponse.failure(
        e.message ?? getDioErrorType(e).message,
        statusCode: e.response?.statusCode,
      );
    }
  }

  /// POST /products — create a product. Requires auth.
  Future<ApiResponse<ProductModel>> createProduct({
    required String title,
    required num price,
    required String description,
    int categoryId = 1,
    List<String>? images,
  }) async {
    try {
      final response = await post(
        ApiEndpoints.products,
        data: {
          'title': title,
          'price': price,
          'description': description,
          'categoryId': categoryId,
          'images': images ?? const ['https://placehold.co/600x400'],
        },
      );
      final product = await compute<Map<String, dynamic>, ProductModel>(
        _parseProduct,
        response.data as Map<String, dynamic>,
      );
      return ApiResponse.success(product, statusCode: response.statusCode);
    } on DioException catch (e) {
      return ApiResponse.failure(
        e.message ?? getDioErrorType(e).message,
        statusCode: e.response?.statusCode,
      );
    }
  }

  /// PUT /products/{id} — partial or full update. Requires auth.
  Future<ApiResponse<ProductModel>> updateProduct({
    required int id,
    String? title,
    num? price,
    String? description,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (title != null) body['title'] = title;
      if (price != null) body['price'] = price;
      if (description != null) body['description'] = description;

      final response = await put(ApiEndpoints.productById(id), data: body);
      final product = await compute<Map<String, dynamic>, ProductModel>(
        _parseProduct,
        response.data as Map<String, dynamic>,
      );
      return ApiResponse.success(product, statusCode: response.statusCode);
    } on DioException catch (e) {
      return ApiResponse.failure(
        e.message ?? getDioErrorType(e).message,
        statusCode: e.response?.statusCode,
      );
    }
  }

  /// DELETE /products/{id} — Platzi returns `true` on success. Requires auth.
  Future<ApiResponse<int>> deleteProduct(int id) async {
    try {
      final response = await delete(ApiEndpoints.productById(id));
      return ApiResponse.success(id, statusCode: response.statusCode);
    } on DioException catch (e) {
      return ApiResponse.failure(
        e.message ?? getDioErrorType(e).message,
        statusCode: e.response?.statusCode,
      );
    }
  }
}
