import 'dart:convert';
import 'package:flutter/services.dart';

class AssetCatalog {
  AssetCatalog._();

  static Future<List<String>> listAssetsInFolder(
      String folder, {
        List<String> exts = const ['.png', '.jpg', '.jpeg', '.webp'],
      }) async {
    // folder example: "assets/image/avatar/"
    final manifestJson = await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> manifest = json.decode(manifestJson) as Map<String, dynamic>;

    final keys = manifest.keys
        .where((k) => k.startsWith(folder))
        .where((k) => exts.any((e) => k.toLowerCase().endsWith(e)))
        .toList();

    keys.sort((a, b) => a.compareTo(b));
    return keys;
  }

  static Future<Map<String, List<String>>> listByFolder({
    required List<String> folders,
    List<String> exts = const ['.png', '.jpg', '.jpeg', '.webp'],
  }) async {
    final manifestJson = await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> manifest = json.decode(manifestJson) as Map<String, dynamic>;

    final Map<String, List<String>> out = {};
    for (final folder in folders) {
      final list = manifest.keys
          .where((k) => k.startsWith(folder))
          .where((k) => exts.any((e) => k.toLowerCase().endsWith(e)))
          .toList()
        ..sort();
      out[folder] = list;
    }
    return out;
  }
}
