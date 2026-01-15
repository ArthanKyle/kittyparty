import 'dart:convert';
import 'dart:developer';
import 'package:flutter/services.dart' show rootBundle;

/// Auto-scan SVGA assets and map via normalized keys
class GiftAssets {
  // ================= PATHS =================
  static const String giftPath   = "assets/image/gift/";
  static const String ridesPath  = "assets/image/rides_mall/";
  static const String avatarPath = "assets/image/avatar_mall/";

  /// normalizedName -> full asset path (.svga)
  static final Map<String, String> fileMap = {};
  static bool _initialized = false;

  // ================= INIT =================
  static Future<void> load() async {
    if (_initialized) return;

    final manifestJson = await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> manifest = jsonDecode(manifestJson);

    for (final path in manifest.keys) {
      if (_isSupportedSvga(path)) {
        final filename = path.split("/").last.replaceAll(".svga", "");
        final normalized = _normalize(filename);
        fileMap[normalized] = path;

        log("[ASSET SCAN] Registered: $filename → $path");
      }
    }

    log("✔ Auto Asset Mapping Ready — ${fileMap.length} items bound");
    _initialized = true;
  }

  // ================= HELPERS =================
  static bool _isSupportedSvga(String path) {
    return path.endsWith(".svga") &&
        (path.startsWith(giftPath) ||
            path.startsWith(ridesPath) ||
            path.startsWith(avatarPath));
  }

  static String _normalize(String s) =>
      s.trim().toLowerCase().replaceAll("_", " ");

  // ================= SVGA =================
  /// Access SVGA path by name (supports fuzzy + alias)
  static String svga(String name) {
    final key = _normalize(name);

    // exact
    if (fileMap.containsKey(key)) return fileMap[key]!;

    // fuzzy
    for (final k in fileMap.keys) {
      if (k.contains(key) || key.contains(k)) {
        return fileMap[k]!;
      }
    }

    log("🚫 No SVGA mapping found for $name");
    return "";
  }

  // ================= PNG =================
  /// Default gift PNG
  static String png(String name) =>
      "$giftPath${name.trim()}.png";

  /// Ride PNG
  static String ridePng(String name) =>
      "$ridesPath${name.trim()}.png";

  /// Avatar frame PNG
  static String avatarPng(String name) =>
      "$avatarPath${name.trim()}.png";
}
