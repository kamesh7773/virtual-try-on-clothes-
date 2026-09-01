import 'dart:convert';

import 'package:flutter/services.dart';

/// Serves assets from memory so widget tests never touch real asset I/O,
/// which does not complete under the fake clock `testWidgets` runs on.
class FakeAssetBundle extends CachingAssetBundle {
  final Map<String, String> contents;

  FakeAssetBundle(this.contents);

  @override
  Future<ByteData> load(String key) async {
    final value = contents[key];
    if (value == null) {
      throw StateError('FakeAssetBundle has no entry for "$key"');
    }
    return ByteData.sublistView(Uint8List.fromList(utf8.encode(value)));
  }
}

/// A catalog with two garments — enough to exercise selection and the
/// "n / total" counter without restating the real eight.
const String kTestCatalogJson = '''
{
  "version": 1,
  "garments": [
    {
      "id": "t1",
      "name": "Test Polo",
      "type": "polo",
      "description": "First test garment",
      "prompt": "Substitute the current top with a test polo",
      "image": "assets/garments/polo-green-textured.jpg"
    },
    {
      "id": "t2",
      "name": "Test Shirt",
      "type": "shirt",
      "description": "Second test garment",
      "prompt": "Substitute the current top with a test shirt",
      "image": "assets/garments/shirt-sky-blue.jpg"
    }
  ]
}
''';
