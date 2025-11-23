import 'dart:convert';
import 'package:flutter/services.dart';

class AutoGift {
  final String baseName;
  final String pngPath;
  final String svgaPath;

  AutoGift({
    required this.baseName,
    required this.pngPath,
    required this.svgaPath,
  });
}

class GiftRegistry {
  static List<AutoGift> allGifts = [];

  static Future<void> load() async {
    final String manifestContent =
    await rootBundle.loadString('AssetManifest.json');

    final Map<String, dynamic> manifestMap = json.decode(manifestContent);

    final pngFiles = manifestMap.keys
        .where((p) => p.startsWith("assets/image/gift/") && p.endsWith(".png"))
        .toList();

    final svgaFiles = manifestMap.keys
        .where((p) => p.startsWith("assets/image/gift/") && p.endsWith(".svga"))
        .toList();

    allGifts = [];

    for (final png in pngFiles) {
      final base = png
          .replaceAll("assets/image/gift/", "")
          .replaceAll(".png", "");

      final svgaCandidate = "assets/image/gift/$base.svga";

      final hasSvga = svgaFiles.contains(svgaCandidate);

      if (!hasSvga) {
        print("[GIFT SCAN] SVGA missing for: $base");
        continue;
      }

      print("[GIFT SCAN] Registered pair: $base");
      allGifts.add(AutoGift(
        baseName: base,
        pngPath: png,
        svgaPath: svgaCandidate,
      ));
    }

    print("✔ Auto Gift Loader Completed — Found ${allGifts.length} gifts");
  }
}
