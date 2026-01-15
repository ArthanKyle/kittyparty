class InventoryAssetResolver {
  static String? resolve({
    required String category,
    required String sku,
  }) {
    final normalizedSku =
    sku.replaceAll('-', ' ').trim();

    switch (category.toUpperCase()) {
      case 'AVATARFRAME':
      case 'AVATAR':
        return 'assets/avatar/$normalizedSku.png';

      case 'MOUNT':
        return 'assets/mount/$normalizedSku.png';

      case 'NAMEPLATE':
        return 'assets/nameplate/$normalizedSku.png';

      case 'PROFILECARD':
        return 'assets/profile_card/$normalizedSku.png';

      case 'CHATBUBBLE':
        return 'assets/chat_bubble/$normalizedSku.png';

      default:
        return null;
    }
  }
}
