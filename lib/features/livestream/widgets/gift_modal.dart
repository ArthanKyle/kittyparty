import 'package:flutter/material.dart';
import 'package:kittyparty/features/livestream/widgets/user_selector.dart';
import '../viewmodel/live_audio_room_viewmodel.dart';

class GiftModal extends StatefulWidget {
  final LiveAudioRoomViewmodel viewModel;
  final String roomId;
  final String receiverId;
  final String senderId;   // <-- ADD THIS

  const GiftModal({
    super.key,
    required this.viewModel,
    required this.roomId,
    required this.receiverId,
    required this.senderId,   // <-- ADD THIS
  });

  @override
  State<GiftModal> createState() => _GiftModalState();
}

class _GiftModalState extends State<GiftModal>
    with SingleTickerProviderStateMixin {

  late TabController _tabController;

  final List<int> _comboOptions = const [1, 5, 10, 20, 50];
  int _selectedCombo = 1;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  GiftItem _buildGift({
    required String id,
    required String name,
    required String pngFileName,
    required int price,
    required bool isLucky,
  }) {
    return GiftItem(
      id: id,
      name: name,
      pngFileName: pngFileName,
      price: price,
      isLucky: isLucky,
    );
  }

  List<GiftItem> get _allGifts {
    return [
      // ===========================
      // GENERAL
      // ===========================
      _buildGift(id: "2001", name: "Red Rose Book Pavilion", pngFileName: "Red Rose Bookstore.png", price: 200, isLucky: false),
      _buildGift(id: "2002", name: "Charming Female Singer", pngFileName: "Charming female singer.png", price: 400, isLucky: false),
      _buildGift(id: "2003", name: "Rose String Sound", pngFileName: "rose string tone.png", price: 200, isLucky: false),
      _buildGift(id: "2004", name: "Rolex A", pngFileName: "Rolex.png", price: 200, isLucky: false),
      _buildGift(id: "2005", name: "Rose Crystal Bottle", pngFileName: "rose crystal bottle.png", price: 150, isLucky: false),
      _buildGift(id: "2006", name: "Passionate Love Bouquet", pngFileName: "love bouquet.png", price: 200, isLucky: false),
      _buildGift(id: "2007", name: "Wedding Dress", pngFileName: "wedding dress.png", price: 260, isLucky: false),
      _buildGift(id: "2008", name: "Romantic Love Songs", pngFileName: "Romantic love songs.png", price: 150, isLucky: false),
      _buildGift(id: "2009", name: "Lion Beauty", pngFileName: "lion beauty.png", price: 300, isLucky: false),
      _buildGift(id: "2010", name: "Wealth-Bringing Demon Mask", pngFileName: "Wealth-Bringing Demon Mask.png", price: 238, isLucky: false),
      _buildGift(id: "2011", name: "Silver Crown Daughter", pngFileName: "Silver Crown Daughter.png", price: 300, isLucky: false),
      _buildGift(id: "2012", name: "Misty Valley White Tiger", pngFileName: "Misty Valley White Tiger.png", price: 230, isLucky: false),

      // ===========================
      // LUCKY
      // ===========================
      _buildGift(id: "3001", name: "Donut", pngFileName: "Donut.png", price: 66, isLucky: true),
      _buildGift(id: "3002", name: "7 Red Roses & 9 Blossoms", pngFileName: "9 red roses.png", price: 200, isLucky: true),
      _buildGift(id: "3003", name: "5 White Rose Bouquets", pngFileName: "Bouquet of 5 white roses.png", price: 166, isLucky: true),
      _buildGift(id: "3004", name: "5 Goddess Letters", pngFileName: "Goddess Letter.png", price: 150, isLucky: true),
      _buildGift(id: "3005", name: "Love Language Rose", pngFileName: "love rose.png", price: 200, isLucky: true),
      _buildGift(id: "3006", name: "Love Phonograph", pngFileName: "Love Gramophone.png", price: 200, isLucky: true),
    ];
  }

  List<GiftItem> get _general => _allGifts.where((g) => !g.isLucky).toList();
  List<GiftItem> get _lucky => _allGifts.where((g) => g.isLucky).toList();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 420,
      decoration: const BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 8),
          _handle(),
          const SizedBox(height: 8),
          _header(),
          const SizedBox(height: 8),
          _comboSelector(),
          const SizedBox(height: 8),
          _tabs(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _grid(_general),
                _grid(_lucky),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _handle() => Container(
    width: 40,
    height: 4,
    decoration: BoxDecoration(
      color: Colors.white24,
      borderRadius: BorderRadius.circular(100),
    ),
  );

  Widget _header() => const Padding(
    padding: EdgeInsets.symmetric(horizontal: 16.0),
    child: Align(
      alignment: Alignment.centerLeft,
      child: Text(
        "Send a Gift",
        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
      ),
    ),
  );

  Widget _comboSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          const Text("Quantity:", style: TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(width: 8),
          Wrap(
            spacing: 6,
            children: _comboOptions.map((v) {
              final selected = v == _selectedCombo;
              return GestureDetector(
                onTap: () => setState(() => _selectedCombo = v),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: selected ? Colors.pinkAccent : Colors.white10,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: selected ? Colors.pinkAccent : Colors.white24),
                  ),
                  child: Text("x$v", style: TextStyle(color: selected ? Colors.white : Colors.white70, fontSize: 11)),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _tabs() {
    return TabBar(
      controller: _tabController,
      labelColor: Colors.white,
      unselectedLabelColor: Colors.white54,
      indicatorColor: Colors.pinkAccent,
      tabs: const [
        Tab(text: "General"),
        Tab(text: "Lucky"),
      ],
    );
  }

  Widget _grid(List<GiftItem> list) {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: list.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.72,
      ),
      itemBuilder: (_, i) => _tile(list[i]),
    );
  }

  Widget _tile(GiftItem gift) {
    return GestureDetector(
      onTap: () async {
        Navigator.pop(context); // close gift modal

        final selectedReceiverId = await showModalBottomSheet<String>(
          context: context,
          backgroundColor: Colors.transparent,
          isScrollControlled: true,
          builder: (_) => UserSelectorModal(
            viewModel: widget.viewModel,
          ),
        );

        if (selectedReceiverId == null) return;

        await widget.viewModel.sendGift(
          roomId: widget.roomId,
          senderId: widget.senderId,
          receiverId: selectedReceiverId,
          giftType: gift.id,
          giftCount: _selectedCombo,
        );
      },

      child: Column(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Image.asset(
                "assets/image/gift/${gift.pngFileName}",
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
              gift.name,
              style: const TextStyle(color: Colors.white, fontSize: 10),
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 2),

          /// PRICE WITH JEWEL ICON
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                "assets/icons/jewel.PNG",
                height: 12,
                width: 12,
              ),
              const SizedBox(width: 3),
              Text(
                "${gift.price}",
                style: const TextStyle(
                  color: Colors.blueAccent,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class GiftItem {
  final String id;
  final String name;
  final String pngFileName;
  final int price;
  final bool isLucky;

  GiftItem({
    required this.id,
    required this.name,
    required this.pngFileName,
    required this.price,
    required this.isLucky,
  });
}
