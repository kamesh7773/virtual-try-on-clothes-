import 'dart:convert';

import 'package:flutter/services.dart' show AssetBundle, rootBundle;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/models/api_response.dart';
import '../models/garment_model.dart';

part 'catalog_repository.g.dart';

/// The bundle assets are read through.
///
/// Injected rather than reaching for `rootBundle` directly so tests can supply
/// their own: real asset I/O never completes under a widget test's fake clock,
/// which leaves the catalog stuck loading forever.
@Riverpod(keepAlive: true)
AssetBundle assetBundle(Ref ref) => rootBundle;

@riverpod
CatalogRepository catalogRepository(Ref ref) =>
    CatalogRepository(ref.watch(assetBundleProvider));

/// Path of the bundled catalog. Declared in `pubspec.yaml` under assets.
const String _catalogAsset = 'assets/data/catalog.json';

/// Parsed inline rather than on an isolate: the catalog is a handful of
/// entries, so spawning an isolate costs more than the parse it avoids.
List<GarmentModel> _parseCatalog(String raw) {
  final decoded = jsonDecode(raw) as Map<String, dynamic>;
  final garments = decoded['garments'] as List<dynamic>;
  return garments
      .whereType<Map<String, dynamic>>()
      .map(GarmentModel.fromJson)
      .toList(growable: false);
}

/// Source of the garment catalog.
///
/// Backed by a bundled JSON asset so the app works with no network and no
/// Decart credentials. The return type is [ApiResponse] on purpose: swapping
/// this for an HTTP call later only changes [fetchGarments]'s body, not the
/// view model above it.
class CatalogRepository {
  final AssetBundle _bundle;

  const CatalogRepository(this._bundle);

  Future<ApiResponse<List<GarmentModel>>> fetchGarments() async {
    try {
      final raw = await _bundle.loadString(_catalogAsset);
      final garments = _parseCatalog(raw);

      if (garments.isEmpty) {
        return ApiResponse.failure('Catalog is empty');
      }
      return ApiResponse.success(garments);
    } catch (e) {
      return ApiResponse.failure('Could not load the garment catalog: $e');
    }
  }
}
