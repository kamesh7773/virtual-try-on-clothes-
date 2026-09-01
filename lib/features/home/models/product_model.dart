import 'package:flutter/foundation.dart';

@immutable
class ProductModel {
  final int? id;
  final String? title;
  final num? price;
  final String? description;
  final int? categoryId;
  final String? categoryName;
  final List<String> images;

  const ProductModel({
    this.id,
    this.title,
    this.price,
    this.description,
    this.categoryId,
    this.categoryName,
    this.images = const [],
  });

  String? get primaryImage => images.isEmpty ? null : images.first;

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final rawCategory = json['category'];
    int? categoryId;
    String? categoryName;
    if (rawCategory is Map<String, dynamic>) {
      categoryId = rawCategory['id'] as int?;
      categoryName = rawCategory['name'] as String?;
    } else if (rawCategory is String) {
      categoryName = rawCategory;
    }

    final rawImages = json['images'];
    List<String> images = const [];
    if (rawImages is List) {
      images = rawImages
          .map((e) => e?.toString() ?? '')
          .where((e) => e.isNotEmpty)
          .toList(growable: false);
    } else if (rawImages is String && rawImages.isNotEmpty) {
      images = [rawImages];
    }

    return ProductModel(
      id: json['id'] as int?,
      title: json['title'] as String?,
      price: json['price'] as num?,
      description: json['description'] as String?,
      categoryId: categoryId,
      categoryName: categoryName,
      images: images,
    );
  }

  ProductModel copyWith({
    int? id,
    String? title,
    num? price,
    String? description,
    int? categoryId,
    String? categoryName,
    List<String>? images,
  }) =>
      ProductModel(
        id: id ?? this.id,
        title: title ?? this.title,
        price: price ?? this.price,
        description: description ?? this.description,
        categoryId: categoryId ?? this.categoryId,
        categoryName: categoryName ?? this.categoryName,
        images: images ?? this.images,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductModel &&
          id == other.id &&
          title == other.title &&
          price == other.price &&
          description == other.description &&
          categoryId == other.categoryId &&
          categoryName == other.categoryName &&
          listEquals(images, other.images);

  @override
  int get hashCode => Object.hash(
        id,
        title,
        price,
        description,
        categoryId,
        categoryName,
        Object.hashAll(images),
      );
}
