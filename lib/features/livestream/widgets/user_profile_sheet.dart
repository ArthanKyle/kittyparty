// lib/features/livestream/widgets/user_frame_profile_sheet.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class UserFrameProfileSheet {
  static Future<void> show(
      BuildContext context, {
        required String userId,
        required String displayName,
        Uint8List? avatarBytes,
        ImageProvider? avatarImage,
        int? age,
        String? genderText,
        int? vipLevel,
        List<Widget> badges = const [],
        VoidCallback? onActionMuteMic,
        VoidCallback? onActionMuteSpeaker,
        VoidCallback? onActionLock,
        VoidCallback? onActionStand,
      }) async {
    await showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: false,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      builder: (_) => _UserFrameProfileSheetView(
        userId: userId,
        displayName: displayName,
        avatarBytes: avatarBytes,
        avatarImage: avatarImage,
        age: age,
        genderText: genderText,
        vipLevel: vipLevel,
        badges: badges,
        onActionMuteMic: onActionMuteMic,
        onActionMuteSpeaker: onActionMuteSpeaker,
        onActionLock: onActionLock,
        onActionStand: onActionStand,
      ),
    );
  }
}

class _UserFrameProfileSheetView extends StatelessWidget {
  final String userId;
  final String displayName;
  final Uint8List? avatarBytes;
  final ImageProvider? avatarImage;
  final int? age;
  final String? genderText;
  final int? vipLevel;
  final List<Widget> badges;

  final VoidCallback? onActionMuteMic;
  final VoidCallback? onActionMuteSpeaker;
  final VoidCallback? onActionLock;
  final VoidCallback? onActionStand;

  const _UserFrameProfileSheetView({
    required this.userId,
    required this.displayName,
    this.avatarBytes,
    this.avatarImage,
    this.age,
    this.genderText,
    this.vipLevel,
    this.badges = const [],
    this.onActionMuteMic,
    this.onActionMuteSpeaker,
    this.onActionLock,
    this.onActionStand,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 46),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 66, 16, 18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                      color: Colors.black.withOpacity(0.18),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            displayName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        _GenderAgePill(
                          genderText: genderText,
                          age: age,
                          vipLevel: vipLevel,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'ID:$userId',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: Colors.black54,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 10),
                        InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: () async {
                            await Clipboard.setData(ClipboardData(text: userId));
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Copied'),
                                  duration: Duration(milliseconds: 900),
                                ),
                              );
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.black.withOpacity(0.06),
                            ),
                            child: const Icon(Icons.copy, size: 18, color: Colors.black87),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    if (badges.isNotEmpty) ...[
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        alignment: WrapAlignment.center,
                        children: badges,
                      ),
                      const SizedBox(height: 14),
                    ] else
                      const SizedBox(height: 6),

                    Container(
                      width: 74,
                      height: 74,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF27D7F7), Color(0xFF35F4B5)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 18,
                            offset: const Offset(0, 10),
                            color: Colors.black.withOpacity(0.12),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.card_giftcard, size: 34, color: Colors.white),
                    ),

                    const SizedBox(height: 16),
                    Divider(height: 1, color: Colors.black.withOpacity(0.10)),
                    const SizedBox(height: 14),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _ActionCircle(
                          bg: const Color(0xFFF6D6D6),
                          icon: Icons.mic_off,
                          onTap: onActionMuteMic,
                        ),
                        _ActionCircle(
                          bg: const Color(0xFFDDF6D6),
                          icon: Icons.volume_off,
                          onTap: onActionMuteSpeaker,
                        ),
                        _ActionCircle(
                          bg: const Color(0xFFDCE6FF),
                          icon: Icons.lock,
                          onTap: onActionLock,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            Container(
              width: 92,
              height: 92,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                    color: Colors.black.withOpacity(0.12),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(6),
              child: CircleAvatar(
                backgroundColor: Colors.grey.shade200,
                backgroundImage: _resolveAvatarImage(),
                child: _resolveAvatarImage() == null
                    ? const Icon(Icons.person, size: 42, color: Colors.black26)
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  ImageProvider? _resolveAvatarImage() {
    if (avatarBytes != null) return MemoryImage(avatarBytes!);
    if (avatarImage != null) return avatarImage;
    return null;
  }
}

class _GenderAgePill extends StatelessWidget {
  final String? genderText;
  final int? age;
  final int? vipLevel;

  const _GenderAgePill({
    this.genderText,
    this.age,
    this.vipLevel,
  });

  @override
  Widget build(BuildContext context) {
    final text = [
      if ((genderText ?? '').trim().isNotEmpty) genderText!.trim(),
      if (age != null) '$age',
      if (vipLevel != null) 'VIP $vipLevel',
    ].join(' ');

    if (text.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFE6F5FF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 12,
          color: Color(0xFF1A74D6),
        ),
      ),
    );
  }
}

class _ActionCircle extends StatelessWidget {
  final Color bg;
  final IconData icon;
  final VoidCallback? onTap;

  const _ActionCircle({
    required this.bg,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap ?? () {},
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: bg,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.black54, size: 26),
      ),
    );
  }
}
