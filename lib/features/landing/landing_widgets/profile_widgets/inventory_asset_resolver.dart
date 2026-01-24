class InventoryAssetResolver {
  static String? fromKey({
    required String assetType,
    required String assetKey,
  }) {
    switch (assetType) {
      case 'mount':
        return 'assets/image/rides_mall/$assetKey.png';

      case 'avatar':
        return 'assets/image/avatar_mall/$assetKey.png';

      case 'nameplate':
        return 'assets/image/nameplate_mall/$assetKey.png';

      case 'profile_card':
        return 'assets/image/profilecard_mall/$assetKey.png';

      case 'chat_bubble':
        return 'assets/image/chatbubble_mall/$assetKey.png';

      default:
        return null;
    }
  }
}
