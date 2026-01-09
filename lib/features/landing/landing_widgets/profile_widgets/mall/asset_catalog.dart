// lib/features/landing/landing_widgets/profile_widgets/mall/asset_catalog.dart
import 'dart:convert';
import 'package:flutter/services.dart';

class AssetCatalog {
  AssetCatalog._();

  /// List assets in a single folder (PNG/JPG/WEBP only)
  static Future<List<String>> listAssetsInFolder(
      String folder, {
        List<String> exts = const ['.png', '.jpg', '.jpeg', '.webp'],
      }) async {
    final manifestJson = await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> manifest =
    json.decode(manifestJson) as Map<String, dynamic>;

    final keys = manifest.keys
        .where((k) => k.startsWith(folder))
        .where((k) => exts.any((e) => k.toLowerCase().endsWith(e)))
        .toList()
      ..sort();

    return keys;
  }

  /// List assets grouped by folder (PNG/JPG/WEBP only)
  static Future<Map<String, List<String>>> listByFolder({
    required List<String> folders,
    List<String> exts = const ['.png', '.jpg', '.jpeg', '.webp'],
  }) async {
    final manifestJson = await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> manifest =
    json.decode(manifestJson) as Map<String, dynamic>;

    final Map<String, List<String>> out = {};

    for (final folder in folders) {
      out[folder] = manifest.keys
          .where((k) => k.startsWith(folder))
          .where((k) => exts.any((e) => k.toLowerCase().endsWith(e)))
          .toList()
        ..sort();
    }

    return out;
  }
}
