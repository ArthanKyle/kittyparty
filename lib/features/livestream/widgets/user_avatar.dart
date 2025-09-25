import 'dart:typed_data';
import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  final String userId;
  final double size;
  final Map<String, Uint8List?> profileCache;
  final Future<ImageProvider?> Function(String) fetchProfilePicture;

  const UserAvatar({
    super.key,
    required this.userId,
    required this.size,
    required this.profileCache,
    required this.fetchProfilePicture,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ImageProvider?>(
      future: fetchProfilePicture(userId),
      builder: (context, snapshot) {
        final image = snapshot.data;

        return CircleAvatar(
          radius: size / 2,
          backgroundImage: image,
          child: image == null
              ? const Icon(Icons.person, size: 24, color: Colors.grey)
              : null,
        );
      },
    );
  }
}
