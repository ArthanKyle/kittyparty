import 'package:flutter/material.dart';
import '../../../core/global_widgets/toast/top_toast.dart';
import '../viewmodel/live_audio_room_viewmodel.dart';
import 'gift_svga_player.dart';

class GiftAnimationOverlay extends StatefulWidget {
  final LiveAudioRoomViewmodel vm;
  const GiftAnimationOverlay({super.key, required this.vm});

  @override
  State<GiftAnimationOverlay> createState() => _GiftAnimationOverlayState();
}

class _GiftAnimationOverlayState extends State<GiftAnimationOverlay> {

  String? playing;

  @override
  void initState() {
    super.initState();

    widget.vm.giftStream.listen((giftName) {
      if (!mounted) return;

      TopToast.show(
        context,
        message: "🎁 Gift sent: $giftName",
      );

      setState(() => playing = giftName);

      Future.delayed(const Duration(seconds: 5), () {
        if (mounted) {
          setState(() => playing = null);
        }
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    if (playing == null) return SizedBox.shrink();

    return Positioned.fill(
      child: Center(child: GiftSVGAPlayer(giftName: playing!)),
    );
  }
}
