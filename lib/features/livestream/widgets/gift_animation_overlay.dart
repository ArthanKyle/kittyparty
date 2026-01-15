import 'dart:async';
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
  String? playingGiftName;
  Timer? _clearTimer;

  /// 🔒 SINGLE SOURCE OF TRUTH
  /// giftType (ID) → exact baseName used by assets
  static const Map<String, String> _giftIdToBaseName = {
    // ================= GENERAL =================
    "2001": "Red Rose Bookstore",
    "2002": "Charming female singer",
    "2003": "rose string tone",
    "2004": "Rolex",
    "2005": "rose crystal bottle",
    "2006": "love bouquet",
    "2007": "wedding dress",
    "2008": "Romantic love songs",
    "2009": "lion beauty",
    "2010": "Wealth-Bringing Demon Mask",
    "2011": "Silver Crown Daughter",
    "2012": "Misty Valley White Tiger",
    "2013": "The Supreme Lion King makes his appearance",
    "2014": "Golden Elephant Brings Wealth",

    // ================= LUCKY =================
    "3001": "Donut",
    "3002": "Bouquet of 5 white roses",
    "3003": "Goddess Letter",
    "3004": "love rose",
    "3005": "Love Gramophone",
    "3006": "love chocolate",
    "3007": "love bouquet",
    "3008": "rose crystal bottle",
    "3009": "rose string tone",
    "3010": "Red Rose Bookstore",
    "3011": "Rolex",

    // ================= COUPLE =================
    "4001": "Palm Island sunset",
    "4002": "A Stunning Encounter",
    "4003": "Heartbeat Rose Lover",
    "4004": "Ambiguous cocktail party",
    "4005": "red carpet couple",
    "4006": "private island",
    "4007": "Oath of the Stars",
    "4008": "love chocolate",
    "4009": "golden wedding",
    "4010": "Wedding Waltz",
    "4011": "glorious century",

    // ================= RIDES =================
    "5001": "eMule fans",
    "5002": "eDonkey blue",
    "5003": "Fortress Armored - Taurus",
    "5004": "Corona King - Leo",
    "5005": "Golden Dragon",
    "5006": "Divine Dragon Supreme",
    "5007": "Starry Sky Off-Road - Sagittarius",
    "5008": "Blazing Storm",
    "5009": "Neon Phantom",
    "5010": "Gilded Phantom",

    // ================= AVATAR FRAMES =================
    "6001": "Luxury car lion shadow avatar frame",
    "6002": "Heart-fluttering 520 profile picture frame",
    "6003": "520 Flower Profile Picture Frame",
    "6004": "Black Rose Avatar Frame",
    "6005": "Green Rose Avatar Frame",
    "6006": "Crystal Crown - Silver",
    "6007": "Springtime Vitality - Profile Picture Frame",
    "6008": "Let's get married profile picture frame",
    "6009": "Eternal Love Avatar Frame",
    "6010": "CP Cat - Female",
    "6011": "CP Cat - Male",
    "6012": "Purple Rose Avatar Frame",
    "6013": "Blue Rose Avatar Frame",
    "6014": "Pink Rose Avatar Frame",
  };

  @override
  void initState() {
    super.initState();

    widget.vm.giftStream.listen((giftType) {
      if (!mounted) return;

      final baseName = _giftIdToBaseName[giftType];
      if (baseName == null) {
        debugPrint("🚫 No baseName mapping for giftType=$giftType");
        return;
      }

      TopToast.show(
        context,
        message: "🎁 Gift sent: $baseName",
      );

      _clearTimer?.cancel();

      setState(() => playingGiftName = baseName);

      _clearTimer = Timer(const Duration(seconds: 5), () {
        if (mounted) {
          setState(() => playingGiftName = null);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (playingGiftName == null) return const SizedBox.shrink();

    return Positioned.fill(
      child: IgnorePointer(
        child: Center(
          child: GiftSVGAPlayer(giftName: playingGiftName!),
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
