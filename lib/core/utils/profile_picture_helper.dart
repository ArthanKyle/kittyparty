import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class UserAvatarHelper {
  static String avatarUrl(String userIdentification) {
    final base = dotenv.env['BASE_URL'] ?? "";
    return "$base/userprofiles/$userIdentification/profile-picture";
  }

  /// ✅ Avatar + NETWORK frame composition
  static Widget circleAvatar({
    required String userIdentification,
    required String displayName,
    double radius = 40,
    Uint8List? localBytes,
    String? frameUrl, // ✅ NETWORK URL
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
    if (frameUrl == null || frameUrl.isEmpty) {
      return avatar;
    }

    // ============================
    // FRAME SIZE
    // ============================
    final frameSize = radius * 2.5;

    return SizedBox(
      width: frameSize,
      height: frameSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          avatar,

          IgnorePointer(
            child: Image.network(
              frameUrl,
              width: frameSize + 8,
              height: frameSize + 8,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }
}
