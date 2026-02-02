import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../viewmodel/live_audio_room_viewmodel.dart';
import 'gift_svga_player.dart';

class GiftAnimationOverlay extends StatefulWidget {
  final LiveAudioRoomViewmodel vm;
  const GiftAnimationOverlay({super.key, required this.vm});

  @override
  State<GiftAnimationOverlay> createState() => _GiftAnimationOverlayState();
}

class _GiftAnimationOverlayState extends State<GiftAnimationOverlay> {
  String? _svgaUrl;
  Timer? _clearTimer;
  StreamSubscription<String>? _sub;

  @override
  void initState() {
    super.initState();

    _sub = widget.vm.giftStream.listen((assetKey) {
      if (!mounted || assetKey.trim().isEmpty) return;

      final base = dotenv.env['MEDIA_BASE_URL'];
      if (base == null || base.isEmpty) return;

      final url = '$base/assets/gift/$assetKey.svga';

      debugPrint('🎬 Overlay play => $url');

      _clearTimer?.cancel();
      setState(() {
        _svgaUrl = url;
      });

      _clearTimer = Timer(const Duration(seconds: 8), () {
        if (mounted) {
          setState(() => _svgaUrl = null);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_svgaUrl == null) return const SizedBox.shrink();

    return Positioned.fill(
      child: IgnorePointer(
        child: Center(
          child: GiftSVGAPlayer(
            svgaUrl: _svgaUrl!,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _sub?.cancel();
    _clearTimer?.cancel();
    super.dispose();
  }
}
