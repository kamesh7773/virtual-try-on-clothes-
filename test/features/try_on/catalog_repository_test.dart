import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_test/flutter_test.dart';
import 'package:virtual_try_on/features/try_on/repositories/catalog_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Deliberately the real bundle: this is the check that the catalog asset is
  // actually shipped and parses. Widget tests use a fake bundle instead.
  final repository = CatalogRepository(rootBundle);

  test('loads every garment from the bundled catalog', () async {
    final response = await repository.fetchGarments();

    expect(response.isSuccess, isTrue, reason: response.error);
    expect(response.data, hasLength(8));
  });

  test('every garment carries the fields the try-on session needs', () async {
    final garments = (await repository.fetchGarments()).data!;

    for (final garment in garments) {
      expect(garment.id, isNotEmpty);
      expect(garment.name, isNotEmpty);
      // The prompt and image are what actually reach Decart — an empty one
      // would fail silently at try-on time rather than here.
      expect(garment.prompt, isNotEmpty, reason: '${garment.id} has no prompt');
      expect(
        garment.image,
        startsWith('assets/garments/'),
        reason: '${garment.id} has an unexpected image path',
      );
    }
  });

  test('garment ids are unique', () async {
    final garments = (await repository.fetchGarments()).data!;
    final ids = garments.map((g) => g.id).toSet();

    expect(ids, hasLength(garments.length));
  });
}
