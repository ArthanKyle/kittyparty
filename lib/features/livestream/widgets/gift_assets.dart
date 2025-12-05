import 'dart:convert';
import 'dart:developer';
import 'package:flutter/services.dart' show rootBundle;

/// Auto-scan SVGA assets and map via normalized keys
class GiftAssets {
  static const String giftPath = "assets/image/gift/";
  static final Map<String, String> fileMap = {};
  static bool _initialized = false;

  static Future<void> load() async {
    if (_initialized) return;

    final manifestJson = await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> manifest = jsonDecode(manifestJson);

    for (final path in manifest.keys) {
      if (path.startsWith(giftPath) && path.endsWith(".svga")) {
        final filename = path.split("/").last.replaceAll(".svga", "");
        final normalized = _normalize(filename);
        fileMap[normalized] = path;

        log("[GIFT SCAN] Registered: $filename");
      }
    }

    log("✔ Auto Gift Mapping Ready — ${fileMap.length} items bound");
    _initialized = true;
  }

  /// Normalize for matching
  static String _normalize(String s) =>
      s.trim().toLowerCase().replaceAll("_", " ");

  /// Access SVGA path by name (supports fuzzy + alias)
  static String svga(String giftName) {
    final key = _normalize(giftName);

    if (fileMap.containsKey(key)) return fileMap[key]!; // exact

    // fuzzy / contains
    for (final k in fileMap.keys) {
      if (k.contains(key) || key.contains(k)) return fileMap[k]!;
    }

    log("🚫 No mapping found for $giftName");
    return "";
  }

  /// PNG path for grid icon preview
  static String png(String giftName) =>
      "$giftPath${giftName.trim()}.png";
}
