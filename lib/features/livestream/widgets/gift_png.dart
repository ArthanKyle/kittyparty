import 'dart:io';
import 'package:flutter/material.dart';
import '../../../core/utils/remote_asset_helper.dart';

class GiftPNG extends StatelessWidget {
  final String path;

  const GiftPNG({super.key, required this.path});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<File>(
      future: RemoteAssetHelper.load(path),
      builder: (_, snap) {
        if (!snap.hasData) {
          return const Center(child: SizedBox(width: 18, height: 18));
        }
        return Image.file(
          snap.data!,
          fit: BoxFit.contain,
        );
      },
    );
  }
}
