import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svga/flutter_svga.dart';
import '../viewmodel/live_audio_room_viewmodel.dart';

class GiftAnimationOverlay extends StatefulWidget {
  final LiveAudioRoomViewmodel viewModel;

  const GiftAnimationOverlay({super.key, required this.viewModel});

  @override
  State<GiftAnimationOverlay> createState() => _GiftAnimationOverlayState();
}

class _GiftAnimationOverlayState extends State<GiftAnimationOverlay>
    with SingleTickerProviderStateMixin {

  SVGAAnimationController? _controller;
  final SVGAParser _parser = SVGAParser();

  String? currentSvga;
  bool isPlaying = false;

  StreamSubscription<String>? _giftSub;

  @override
  void initState() {
    super.initState();

    _controller = SVGAAnimationController(vsync: this);

    _giftSub = widget.viewModel.giftStream.listen((svgaPath) {
      _playGiftAnimation(svgaPath);
    });
  }

  @override
  void dispose() {
    _giftSub?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _playGiftAnimation(String svgaPath) async {
    if (isPlaying || _controller == null) return;

    isPlaying = true;
    setState(() => currentSvga = svgaPath);

    try {
      print("[GIFT OVERLAY] loading $svgaPath");

      final video = await _parser.decodeFromAssets(svgaPath);
      _controller!.videoItem = video;

      // Start animation
      _controller!.repeat();

      // Safe duration (fallback to 2 seconds if null)
      final duration = _controller!.duration ?? const Duration(seconds: 2);

      await Future.delayed(
        Duration(
          milliseconds: duration.inMilliseconds.clamp(500, 8000),
        ),
      );
    } catch (e) {
      print("❌ SVGA Overlay Error: $e");
    }

    _controller!.stop();
    setState(() => currentSvga = null);

    isPlaying = false;
  }

  @override
  Widget build(BuildContext context) {
    if (currentSvga == null || _controller == null) {
      return const SizedBox.shrink();
    }

    return IgnorePointer(
      ignoring: true,
      child: Center(
        child: SizedBox(
          width: 300,
          height: 300,
          child: SVGAImage(
            _controller!,
            fit: BoxFit.contain,
            clearsAfterStop: false,
            allowDrawingOverflow: true,
            filterQuality: FilterQuality.low,
          ),
        ),
      ),
    );
  }
}
