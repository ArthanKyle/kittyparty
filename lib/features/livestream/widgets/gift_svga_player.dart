import 'package:flutter/material.dart';
import 'package:flutter_svga/flutter_svga.dart';

class SvgaGiftQueue {
  static final SvgaGiftQueue _instance = SvgaGiftQueue._internal();
  factory SvgaGiftQueue() => _instance;
  SvgaGiftQueue._internal();

  final List<String> _queue = [];
  bool _isPlaying = false;

  void add(BuildContext context, String assetPath) {
    _queue.add(assetPath);
    _playNext(context);
  }

  void _playNext(BuildContext context) {
    if (_isPlaying || _queue.isEmpty) return;

    _isPlaying = true;
    final path = _queue.removeAt(0);

    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (_) => SvgaGiftAnimation(
        assetPath: path,
        onFinished: () {
          entry.remove();
          _isPlaying = false;
          _playNext(context);
        },
      ),
    );

    Overlay.of(context).insert(entry);
  }
}

class SvgaGiftAnimation extends StatefulWidget {
  final String assetPath;
  final VoidCallback onFinished;

  const SvgaGiftAnimation({
    super.key,
    required this.assetPath,
    required this.onFinished,
  });

  @override
  State<SvgaGiftAnimation> createState() => _SvgaGiftAnimationState();
}

class _SvgaGiftAnimationState extends State<SvgaGiftAnimation>
    with SingleTickerProviderStateMixin {

  late SVGAAnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = SVGAAnimationController(vsync: this);
    _play();
  }

  Future<void> _play() async {
    final video = await SVGAParser.shared.decodeFromAssets(widget.assetPath);
    controller.videoItem = video;

    controller.addListener(() {
      if (controller.isCompleted) {
        widget.onFinished();
      }
    });

    controller.forward(from: 0.0);
  }

  @override
  void dispose() {
    controller.stop();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Center(
        child: SizedBox(
          width: 300,
          height: 300,
          child: SVGAImage(controller),
        ),
      ),
    );
  }
}
