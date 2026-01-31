import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svga/flutter_svga.dart';
import '../../../../../core/utils/profile_picture_helper.dart';
import '../../../../../core/utils/user_provider.dart';
import '../../../viewmodel/profile_viewmodel.dart';
import 'vip_frame_assets.dart';

class VipIdentificationSection extends StatelessWidget {
  final int vipLevel;

  const VipIdentificationSection({super.key, required this.vipLevel});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().currentUser;
    final vm = context.watch<ProfileViewModel>();

    final profilePictureWidget = UserAvatarHelper.circleAvatar(
      userIdentification: user?.userIdentification ?? '',
      displayName: user?.fullName ?? user?.username ?? "U",
      radius: 32,
      localBytes: vm.profilePictureBytes,
      frameUrl:vm.avatarFrameAsset,
    );

    return Row(
      children: [
        Expanded(
          child: _VipInfoCard(
            title: 'Only Headdress',
            child: _FramedAvatarThumb(
              level: vipLevel,
              avatar: profilePictureWidget,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _VipInfoCard(
            title: 'Preview',
            // ✅ SVGA frame preview + avatar behind
            child: _AvatarFrameSvgaPreview(
              level: vipLevel,
              avatar: profilePictureWidget,
            ),
          ),
        ),
      ],
    );
  }
}

class _VipInfoCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _VipInfoCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 128,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF22170C).withOpacity(0.78),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF6C5130).withOpacity(0.8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 16,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          child,
          if (title.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFFE7D6A5),
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _FramedAvatarThumb extends StatelessWidget {
  final int level;
  final Widget avatar;

  const _FramedAvatarThumb({required this.level, required this.avatar});

  @override
  Widget build(BuildContext context) {
    final framePng = VipAvatarFrameAssets.framePngByLevel(level);

    return SizedBox(
      width: 72,
      height: 72,
      child: Stack(
        alignment: Alignment.center,
        children: [
          avatar,
          IgnorePointer(
            child: Image.asset(
              framePng,
              width: 72,
              height: 72,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }
}

/// ✅ Missing widget in your code — added here
class _AvatarFrameSvgaPreview extends StatefulWidget {
  final int level;
  final Widget avatar;

  const _AvatarFrameSvgaPreview({
    required this.level,
    required this.avatar,
  });

  @override
  State<_AvatarFrameSvgaPreview> createState() => _AvatarFrameSvgaPreviewState();
}

class _AvatarFrameSvgaPreviewState extends State<_AvatarFrameSvgaPreview>
    with SingleTickerProviderStateMixin {
  SVGAAnimationController? controller;
  final parser = SVGAParser();

  @override
  void initState() {
    super.initState();
    controller = SVGAAnimationController(vsync: this);
    _loadAndLoop();
  }

  @override
  void didUpdateWidget(covariant _AvatarFrameSvgaPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.level != widget.level) {
      _loadAndLoop();
    }
  }

  Future<void> _loadAndLoop() async {
    final path = VipAvatarFrameAssets.frameSvgaByLevel(widget.level);
    if (path.isEmpty) return;

    try {
      final video = await parser.decodeFromAssets(path);
      if (!mounted) return;

      controller?.stop();
      controller!.videoItem = video;

      // ✅ seamless loop
      controller!
        ..value = 0.0
        ..repeat(
          min: 0.0,
          max: 1.0,
          period: controller!.duration,
        );
    } catch (e) {
      debugPrint("❌ Avatar frame SVGA load failed => $path | $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72,
      height: 72,
      child: Stack(
        alignment: Alignment.center,
        children: [
          widget.avatar,
          if (controller?.videoItem != null)
            IgnorePointer(
              child: SVGAImage(
                controller!,
                fit: BoxFit.contain,
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
