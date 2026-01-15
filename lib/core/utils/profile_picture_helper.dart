import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class UserAvatarHelper {
  static String avatarUrl(String userIdentification) {
    final base = dotenv.env['BASE_URL'] ?? "";
    return "$base/userprofiles/$userIdentification/profile-picture";
  }

  /// ✅ Correct avatar + frame composition
  static Widget circleAvatar({
    required String userIdentification,
    required String displayName,
    double radius = 40,
    Uint8List? localBytes,
    String? frameAsset,
  }) {
    ImageProvider provider;

    if (localBytes != null && localBytes.isNotEmpty) {
      provider = MemoryImage(localBytes);
    } else {
      provider = NetworkImage(avatarUrl(userIdentification));
    }

    // ============================
    // BASE AVATAR (ALWAYS CIRCULAR)
    // ============================
    final avatar = ClipOval(
      child: Image(
        image: provider,
        width: radius * 2,
        height: radius * 2,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: radius * 2,
          height: radius * 2,
          alignment: Alignment.center,
          color: Colors.grey.shade400,
          child: Text(
            displayName.isNotEmpty
                ? displayName[0].toUpperCase()
                : '?',
            style: TextStyle(
              color: Colors.white,
              fontSize: radius,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );

    // ============================
    // NO FRAME → JUST AVATAR
    // ============================
    if (frameAsset == null || frameAsset.isEmpty) {
      return avatar;
    }

    // ============================
    // FRAME SIZE (BIGGER THAN AVATAR)
    // ============================
    final frameSize = radius * 2.4; // 🔑 critical value

    return SizedBox(
      width: frameSize,
      height: frameSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Avatar stays clean and centered
          avatar,

          // Frame wraps AROUND avatar
          IgnorePointer(
            child: Image.asset(
              frameAsset,
              width: frameSize,
              height: frameSize,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }
}
