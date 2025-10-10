import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class UserAvatar extends StatefulWidget {
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
  State<UserAvatar> createState() => _UserAvatarState();
}

class _UserAvatarState extends State<UserAvatar> {
  ImageProvider? _image;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    if (widget.userId.isEmpty) return;

    final cachedBytes = widget.profileCache[widget.userId];
    if (cachedBytes != null && cachedBytes.isNotEmpty) {
      setState(() {
        _image = MemoryImage(cachedBytes);
        _loading = false;
      });
      return;
    }

    final image = await widget.fetchProfilePicture(widget.userId);
    if (mounted) {
      setState(() {
        _image = image;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _loading
        ? Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: CircleAvatar(
        radius: widget.size / 2,
        backgroundColor: Colors.grey.shade200,
      ),
    )
        : CircleAvatar(
      radius: widget.size / 2,
      backgroundImage: _image,
      backgroundColor: Colors.grey.shade200,
      child: _image == null
          ? const Icon(Icons.person, size: 24, color: Colors.grey)
          : null,
    );
  }
}
