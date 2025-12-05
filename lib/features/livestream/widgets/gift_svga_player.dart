import 'package:flutter/material.dart';
import 'package:flutter_svga/flutter_svga.dart';
import 'gift_assets.dart';

class GiftSVGAPlayer extends StatefulWidget {
  final String giftName;
  const GiftSVGAPlayer({super.key, required this.giftName});

  @override
  State<GiftSVGAPlayer> createState() => _GiftSVGAPlayerState();
}

class _GiftSVGAPlayerState extends State<GiftSVGAPlayer>
    with SingleTickerProviderStateMixin {

  SVGAAnimationController? controller;
  final parser = SVGAParser();

  @override
  void initState() {
    super.initState();
    controller = SVGAAnimationController(vsync: this);
    _load();
  }

  Future<void> _load() async {
    final path = GiftAssets.svga(widget.giftName);

    if (path.isEmpty) {
      debugPrint("🚫 No mapping found for ${widget.giftName}");
      return;
    }

    try {
      final video = await parser.decodeFromAssets(path);
      controller!.videoItem = video;
      controller!.forward();
    } catch (e) {
      debugPrint("❌ SVGA load failed => $path | $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Transform.scale(
        scale: 1.8,
        child: SizedBox(
          width: 300,
          height: 300,
          child: SVGAImage(
            controller!,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }


  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
