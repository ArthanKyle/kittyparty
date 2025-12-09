import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class UserAvatarHelper {
  static String avatarUrl(String userIdentification) {
    final base = dotenv.env['BASE_URL'] ?? "";
    return "$base/userprofiles/$userIdentification/profile-picture";
  }

  static Widget circleAvatar({
    required String userIdentification,
    required String displayName,
    double radius = 20,
    Uint8List? localBytes,
  }) {
    ImageProvider? provider;

    if (localBytes != null && localBytes.isNotEmpty) {
      provider = MemoryImage(localBytes);
    } else {
      provider = NetworkImage(avatarUrl(userIdentification));
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.purple.shade100,
      backgroundImage: provider,
      onBackgroundImageError: (_, __) {},
      child: provider == null
          ? Text(
        displayName.substring(0, 1).toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      )
          : null,
    );
  }
}
