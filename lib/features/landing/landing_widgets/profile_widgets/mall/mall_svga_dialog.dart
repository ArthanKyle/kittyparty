import 'package:flutter/material.dart';
import 'package:flutter_svga/flutter_svga.dart';

class MallSvgaDialog extends StatefulWidget {
  /// FULL SVGA URL (already prefixed with MEDIA_BASE_URL)
  final String svgaUrl;

  const MallSvgaDialog({
    super.key,
    required this.svgaUrl,
  });

  @override
  State<MallSvgaDialog> createState() => _MallSvgaDialogState();
}

class _MallSvgaDialogState extends State<MallSvgaDialog>
    with SingleTickerProviderStateMixin {
  late final SVGAAnimationController _controller;
  late final SVGAParser _parser;

  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _parser = SVGAParser();
    _controller = SVGAAnimationController(vsync: this);
    _load();
  }

  Future<void> _load() async {
    debugPrint("🎬 Playing SVGA (network) => ${widget.svgaUrl}");

    try {
      _controller.stop();
      _controller.videoItem = null;

      final video = await _parser.decodeFromURL(widget.svgaUrl);
      if (!mounted) return;

      setState(() {
        _controller.videoItem = video;
        _controller.reset();
        _controller.repeat();
        _loaded = true;
      });
    } catch (e, s) {
      debugPrint("❌ SVGA load failed");
      debugPrint("❌ Error: $e");
      debugPrint("❌ Stack: $s");

      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.black.withOpacity(0.65),
      insetPadding: EdgeInsets.zero,
      child: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Center(
          child: Transform.scale(
            scale: 1.8,
            child: SizedBox(
              width: 320,
              height: 320,
              child: !_loaded
                  ? const SizedBox.shrink()
                  : SVGAImage(
                _controller,
                fit: BoxFit.contain,
              ),
            ),
          ),
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
