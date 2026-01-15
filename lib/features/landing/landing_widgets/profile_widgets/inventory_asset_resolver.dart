class InventoryAssetResolver {
  // ================= BASE PATHS =================
  static const String _avatarBase = 'assets/image/avatar_mall/';
  static const String _rideBase = 'assets/image/ride_mall/';

  // ================= AVATAR FRAMES =================

  /// SKU → Avatar frame asset
  static const Map<String, String> _avatarFrameMap = {
    // 🌹 ROSE FRAMES
    'FRAME-BLUE-ROSE-AVATAR-FRAME': '${_avatarBase}Blue Rose Avatar Frame.png',
    'FRAME-PINK-ROSE-AVATAR-FRAME': '${_avatarBase}Pink Rose Avatar Frame.png',
    'FRAME-BLACK-ROSE-AVATAR-FRAME': '${_avatarBase}Black Rose Avatar Frame.png',
    'FRAME-GREEN-ROSE-AVATAR-FRAME': '${_avatarBase}Green Rose Avatar Frame.png',
    'FRAME-PURPLE-ROSE-AVATAR-FRAME': '${_avatarBase}Purple Rose Avatar Frame.png',

    // 💎 SPECIAL
    'FRAME-ETERNAL-LOVE-AVATAR-FRAME':
    '${_avatarBase}Eternal Love Avatar Frame.png',
    'FRAME-CRYSTAL-CROWN-SILVER':
    '${_avatarBase}Crystal Crown - Silver.png',

    // 🌸 EVENT
    'FRAME-520-FLOWER-PROFILE-PICTURE-FRAME':
    '${_avatarBase}520 Flower Profile Picture Frame.png',
    'FRAME-HEART-FLUTTERING-520-PROFILE-PICTURE-FRAME':
    '${_avatarBase}Heart-fluttering 520 profile picture frame.png',

    // 🐱 CP CAT
    'FRAME-CP-CAT-FEMALE': '${_avatarBase}CP Cat - Female.png',
    'FRAME-CP-CAT-MALE': '${_avatarBase}CP Cat - Male.png',
  };

  // ================= RIDES / MOUNTS =================

  /// SKU → Ride (mount) asset
  static const Map<String, String> _rideMap = {
    'MOUNT-FLAMES-RAGE-WILDLY':
    '${_rideBase}Flames Rage Wildly.png',

    'MOUNT-FORTRESS-ARMOR-TAURUS':
    '${_rideBase}Fortress Armored - Taurus.png',

    'MOUNT-CRYSTAL-CROWN-SILVER':
    '${_rideBase}Crystal Crown Silver Ride.png',


  };



  // ================= RESOLVER =================

  static String normalizeSku(String sku) {
    return sku
        .toUpperCase()
        .replaceAll('_', '-')
        .replaceAll(' ', '-')
        .trim();
  }

  static String? resolve({
    required String category,
    required String sku,
  }) {
    final normalizedSku = sku.toUpperCase();

    switch (category) {
      case 'AVATAR':
        return _avatarFrameMap[normalizedSku];

      case 'MOUNT':
        return _rideMap[normalizedSku];

      default:
        return null;
    }
  }
}
