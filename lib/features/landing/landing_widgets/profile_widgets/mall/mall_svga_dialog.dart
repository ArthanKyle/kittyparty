import 'package:flutter/material.dart';
import 'package:flutter_svga/flutter_svga.dart';
import 'mall_assets.dart';

class MallSvgaDialog extends StatefulWidget {
  final String assetKey;

  const MallSvgaDialog({
    super.key,
    required this.assetKey,
  });

  @override
  State<MallSvgaDialog> createState() => _MallSvgaDialogState();
}

class _MallSvgaDialogState extends State<MallSvgaDialog>
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
    final path = MallSvgaAssets.path(widget.assetKey);

    if (path == null) {
      debugPrint("🚫 No SVGA mapped for ${widget.assetKey}");
      if (mounted) Navigator.of(context).pop();
      return;
    }

    debugPrint("🎬 Playing SVGA => $path");

    try {
      _controller.stop();
      _controller.videoItem = null;

      final video = await _parser.decodeFromAssets(path);
      if (!mounted) return;

      setState(() {
        _controller.videoItem = video;
        _controller.reset();
        _controller.repeat();
      });
    } catch (e) {
      debugPrint("❌ SVGA load failed: $e");
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
              child: _controller.videoItem == null
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
