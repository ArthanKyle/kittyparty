import 'dart:async';
import 'package:flutter/material.dart';
import '../viewmodel/live_audio_room_viewmodel.dart';
import 'gift_svga_player.dart';

class GiftAnimationOverlay extends StatefulWidget {
  final LiveAudioRoomViewmodel vm;
  const GiftAnimationOverlay({super.key, required this.vm});

  @override
  State<GiftAnimationOverlay> createState() => _GiftAnimationOverlayState();
}

class _GiftAnimationOverlayState extends State<GiftAnimationOverlay> {
  String? playingAssetKey;
  Timer? _clearTimer;

  @override
  void initState() {
    super.initState();

    widget.vm.giftStream.listen((assetKey) {
      if (!mounted || assetKey.isEmpty) return;

      debugPrint("🎬 Overlay received assetKey=$assetKey");

      _clearTimer?.cancel();
      setState(() => playingAssetKey = assetKey);

      _clearTimer = Timer(const Duration(seconds: 5), () {
        if (mounted) setState(() => playingAssetKey = null);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (playingAssetKey == null) return const SizedBox.shrink();

    return Positioned.fill(
      child: IgnorePointer(
        child: Center(
          child: GiftSVGAPlayer(giftName: playingAssetKey!),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _clearTimer?.cancel();
    super.dispose();
  }
}
