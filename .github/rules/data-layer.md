---
description: Guidelines for implementing data layer components in the Indikosh app
globs: lib/**/data/**/*.dart
alwaysApply: false
---
 # Data Layer Implementation

## Models

- Use @immutable annotation
- Implement fromJson/toJson
- Include copyWith methods
- Implement proper enum handling
- Example:

```dart
// Enum handling example
enum ProfileStatus {
  approved,
  pending,
  rejected,
  blocked;

  static ProfileStatus fromString(String status) {
    return ProfileStatus.values.firstWhere(
      (e) => e.name == status.toLowerCase(),
      orElse: () => ProfileStatus.pending,
    );
  }
}

@immutable
class UserModel {
  final String id;
  final String name;
  final ProfileStatus status;

  const UserModel({
    required this.id,
    required this.name,
    required this.status,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id'],
    name: json['name'],
    status: ProfileStatus.fromString(json['status']),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'status': status.name,
  };

  UserModel copyWith({
    String? id,
    String? name,
    ProfileStatus? status,
  }) => UserModel(
    id: id ?? this.id,
    name: name ?? this.name,
    status: status ?? this.status,
  );
}
```

## Repositories

- Use ApiClient for API requests
- Return ApiResponse objects
- Handle exceptions properly
- Format data consistently
- Example:

```dart
@Riverpod(keepAlive: true)
UserRepository userRepository(Ref ref) {
  final apiClient = ref.watch(apiClientProvider);
  return UserRepository._(apiClient);
}

class UserRepository {
  final ApiClient _apiClient;

  UserRepository._(this._apiClient);

  Future<ApiResponse<UserModel>> getUser(String id) async {
    try {
      final response = await _apiClient.dio.get(
        '${ApiEndpoints.users}/$id',
      );
      
      return ApiResponse.fromJson(
        response.data,
        (json) => UserModel.fromJson(json),
      );
    } on DioException catch (e) {
      return ApiResponse.error(e.message ?? 'Failed to get user');
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  Future<ApiResponse<List<UserModel>>> getUsers() async {
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.users);
      
      return ApiResponse.fromJson(
        response.data,
        (json) {
          final List<dynamic> items = json['items'] as List<dynamic>;
          return items
              .map((item) => UserModel.fromJson(item as Map<String, dynamic>))
              .toList();
        },
      );
    } on DioException catch (e) {
      return ApiResponse.error(e.message ?? 'Failed to get users');
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  Future<ApiResponse<void>> updateUser(String id, Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.dio.put(
        '${ApiEndpoints.users}/$id',
        data: data,
      );
      
      return ApiResponse.fromJson(response.data, null);
    } on DioException catch (e) {
      return ApiResponse.error(e.message ?? 'Failed to update user');
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }
}
```

## API Response Handling

- Use standardized ApiResponse model
- Handle different response types
- Provide type safety
- Example:

```dart
@immutable
class ApiResponse<T> {
  final bool isSuccess;
  final T? data;
  final String? message;
  final int? statusCode;

  const ApiResponse({
    required this.isSuccess,
    this.data,
    this.message,
    this.statusCode,
  });

  factory ApiResponse.success(T data, {String? message, int? statusCode}) =>
      ApiResponse(
        isSuccess: true,
        data: data,
        message: message,
        statusCode: statusCode,
      );

  factory ApiResponse.error(String error, {int? statusCode}) =>
      ApiResponse(isSuccess: false, message: error, statusCode: statusCode);

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic> json)? fromJsonT,
  ) {
    final bool success = json['success'] ?? false;
    final statusCode = json['status_code'] as int?;
    final message = json['message'] as String?;

    if (success) {
      final data = json['data'];
      if (data != null && fromJsonT != null) {
        if (data is List) {
          // Handle list response
          final List<dynamic> dataList = data;
          final typedList = dataList
              .map((item) => fromJsonT(item as Map<String, dynamic>))
              .toList() as T;
          return ApiResponse.success(
            typedList,
            message: message,
            statusCode: statusCode,
          );
        } else if (data is Map<String, dynamic>) {
          // Handle object response
          return ApiResponse.success(
            fromJsonT(data),
            message: message,
            statusCode: statusCode,
          );
        }
      }
      // Return raw data if no converter provided or data is null
      return ApiResponse.success(
        data as T,
        message: message,
        statusCode: statusCode,
      );
    } else {
      final error = json['error'] as String? ?? 'Unknown error';
      return ApiResponse.error(error, statusCode: statusCode);
    }
  }
}
```