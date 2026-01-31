import 'package:flutter_dotenv/flutter_dotenv.dart';

class InventoryMediaHelper {
  static String imageUrl({
    required String assetType,
    required String assetKey,
  }) {
    final base = dotenv.env['MEDIA_BASE_URL']!;
    final folder = _folderFromType(assetType);

    return '$base/assets/$folder/$assetKey.png';
  }

  static String _folderFromType(String assetType) {
    switch (assetType) {
      case 'mount':
        return 'rides_mall';
      case 'avatar':
        return 'avatar_mall';
      case 'nameplate':
        return 'nameplate';
      case 'profile_card':
        return 'profile_card_frame';
      case 'chat_bubble':
        return 'chat_bubble';
      default:
        return 'gift';
    }
  }
}
