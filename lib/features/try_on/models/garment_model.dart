import 'package:flutter/foundation.dart';

/// A single try-on garment.
///
/// [prompt] is the payload that actually drives the model — it is sent to
/// Decart verbatim alongside [image] as the reference garment. Everything
/// else is presentation.
@immutable
class GarmentModel {
  final String id;
  final String name;
  final String type;
  final String description;
  final String prompt;

  /// Asset key for the garment shot, e.g. `assets/garments/polo-cream-knit.jpg`.
  final String image;

  const GarmentModel({
    required this.id,
    required this.name,
    required this.type,
    required this.description,
    required this.prompt,
    required this.image,
  });

  factory GarmentModel.fromJson(Map<String, dynamic> json) => GarmentModel(
        id: json['id'] as String,
        name: json['name'] as String,
        type: json['type'] as String? ?? '',
        description: json['description'] as String? ?? '',
        prompt: json['prompt'] as String,
        image: json['image'] as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type,
        'description': description,
        'prompt': prompt,
        'image': image,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is GarmentModel && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'GarmentModel($id, $name)';
}
