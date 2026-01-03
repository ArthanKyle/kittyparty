import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
            title: 'Only Nameplate',
            child: _NameplateThumb(level: vipLevel),
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
    final frameAsset = VipAvatarFrameAssets.framePngByLevel(level);

    return SizedBox(
      width: 72,
      height: 72,
      child: Stack(
        alignment: Alignment.center,
        children: [
          avatar,
          IgnorePointer(
            child: Image.asset(
              frameAsset,
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

class _NameplateThumb extends StatelessWidget {
  final int level;
  const _NameplateThumb({required this.level});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      width: 110,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE7D6A5).withOpacity(0.55)),
        gradient: LinearGradient(
          colors: [
            const Color(0xFF3B2A17).withOpacity(0.95),
            const Color(0xFF1D1208).withOpacity(0.95),
          ],
        ),
      ),
      child: Text(
        'VIP$level',
        style: const TextStyle(
          color: Color(0xFFE7D6A5),
          fontSize: 16,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}
