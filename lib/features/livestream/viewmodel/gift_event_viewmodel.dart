enum GiftViewRole { sender, receiver, spectator }

class GiftEvent {
  final String giftName;
  final String senderId;
  final String receiverId;
  final int diamondsReceived;
  final int coinsWon;

  GiftEvent({
    required this.giftName,
    required this.senderId,
    required this.receiverId,
    required this.diamondsReceived,
    required this.coinsWon,
  });

  GiftViewRole roleFor(String currentUserId) {
    if (currentUserId == senderId) return GiftViewRole.sender;
    if (currentUserId == receiverId) return GiftViewRole.receiver;
    return GiftViewRole.spectator;
  }
}
