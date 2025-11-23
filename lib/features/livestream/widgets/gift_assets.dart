// gift_assets.dart
import 'dart:developer' as dev;

class GiftAssets {
  static const String basePath = "assets/image/gift/";

  // ✔ Logs PNG lookup
  static String png(String baseName) {
    final path = "$basePath$baseName.png";
    dev.log("[GIFT PNG] Request: '$baseName' → $path");
    return path;
  }

  // ✔ Logs SVGA lookup
  static String svga(String baseName) {
    final path = "$basePath$baseName.svga";
    dev.log("[GIFT SVGA] Request: '$baseName' → $path");
    return path;
  }
}
