import 'package:flutter/material.dart';
import 'package:flutter_svga/flutter_svga.dart';

class GiftSVGAPlayer extends StatefulWidget {
  final String svgaUrl;

  const GiftSVGAPlayer({super.key, required this.svgaUrl});

  @override
  State<GiftSVGAPlayer> createState() => _GiftSVGAPlayerState();
}

class _GiftSVGAPlayerState extends State<GiftSVGAPlayer>
    with SingleTickerProviderStateMixin {
  late final SVGAAnimationController _controller;
  late final SVGAParser _parser;

  @override
  void initState() {
    super.initState();
    _parser = SVGAParser();
    _controller = SVGAAnimationController(vsync: this);
    _load();
  }

  Future<void> _load() async {
    try {
      debugPrint('🌐 SVGA LOAD => ${widget.svgaUrl}');
      final video = await _parser.decodeFromURL(widget.svgaUrl);
      if (!mounted) return;

      _controller.videoItem = video;
      _controller.reset();
      _controller.forward();
    } catch (e, s) {
      debugPrint('❌ Gift SVGA failed');
      debugPrint('$e');
      debugPrint('$s');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: 1.8,
      child: SizedBox(
        width: 320,
        height: 320,
        child: SVGAImage(
          _controller,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
