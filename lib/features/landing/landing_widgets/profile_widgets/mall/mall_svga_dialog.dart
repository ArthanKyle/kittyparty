import 'package:flutter/material.dart';
import 'package:flutter_svga/flutter_svga.dart';
import 'mall_assets.dart';

class MallSvgaDialog extends StatefulWidget {
  final String assetKey;
  final String folder;

  const MallSvgaDialog({
    super.key,
    required this.assetKey,
    required this.folder,
  });

  @override
  State<MallSvgaDialog> createState() => _MallSvgaDialogState();
}

class _MallSvgaDialogState extends State<MallSvgaDialog>
    with SingleTickerProviderStateMixin {
  late final SVGAAnimationController _controller;
  final SVGAParser _parser = SVGAParser();

  @override
  void initState() {
    super.initState();
    _controller = SVGAAnimationController(vsync: this);
    _load();
  }

  Future<void> _load() async {
    final path = MallSvgaAssets.path(widget.assetKey);
    if (path == null) {
      Navigator.of(context).pop();
      return;
    }

    final video = await _parser.decodeFromAssets(path);
    if (!mounted) return;

    _controller.videoItem = video;
    _controller.repeat();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.65),
      body: Stack(
        children: [
          /// TAP ANYWHERE TO CLOSE
          GestureDetector(
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

          /// CLOSE ICON
          Positioned(
            top: 50,
            right: 24,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 28),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
