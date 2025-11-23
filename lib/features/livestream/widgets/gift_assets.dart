import 'package:flutter/material.dart';
import 'package:kittyparty/features/livestream/widgets/user_selector.dart';
import '../viewmodel/live_audio_room_viewmodel.dart';
// import 'gift_assets.dart'; // Defined below in this file for copy-paste convenience

class GiftModal extends StatefulWidget {
  final LiveAudioRoomViewmodel viewModel;
  final String roomId;
  final String receiverId;
  final String senderId;

  const GiftModal({
    super.key,
    required this.viewModel,
    required this.roomId,
    required this.receiverId,
    required this.senderId,
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

  // ACCESSING CENTRALIZED DATA NOW
  List<GiftItem> get _general => GiftAssets.generalGifts;
  List<GiftItem> get _lucky => GiftAssets.luckyGifts;

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
        // 1. Close current modal
        Navigator.pop(context);

        // 2. Select Receiver
        final selectedReceiverId = await showModalBottomSheet<String>(
          context: context,
          backgroundColor: Colors.transparent,
          isScrollControlled: true,
          builder: (_) => UserSelectorModal(
            viewModel: widget.viewModel,
          ),
        );

        if (selectedReceiverId == null) return;

        // 3. Send Gift
        // NOTE: If the error persists, change 'gift.id' to 'gift.baseName' below.
        // Many animation players expect the filename directly if no lookup map is provided.
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
                gift.png,
                fit: BoxFit.contain,
                errorBuilder: (c, o, s) => const Icon(Icons.card_giftcard, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            gift.baseName,
            style: const TextStyle(color: Colors.white, fontSize: 10),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                "assets/icons/jewel.PNG",
                height: 12,
                width: 12,
                errorBuilder: (c, o, s) => const Icon(Icons.diamond, size: 10, color: Colors.blue),
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

// --- REFACTORED MODELS & ASSETS ---

class GiftItem {
  final String id;
  final String baseName;
  final int price;
  final bool isLucky;

  const GiftItem({
    required this.id,
    required this.baseName,
    required this.price,
    required this.isLucky,
  });

  String get png => GiftAssets.png(baseName);
  String get svga => GiftAssets.svga(baseName);
}

class GiftAssets {
  static const String _folder = "assets/image/gift";

  // 1. CENTRALIZED DATA LIST
  static const List<GiftItem> allGifts = [
    GiftItem(id: "2001", baseName: "Red Rose Bookstore", price: 200, isLucky: false),
    GiftItem(id: "2002", baseName: "Charming female singer", price: 400, isLucky: false),
    GiftItem(id: "2003", baseName: "rose string tone", price: 200, isLucky: false),
    GiftItem(id: "2004", baseName: "Rolex", price: 200, isLucky: false),
    GiftItem(id: "2005", baseName: "rose crystal bottle", price: 150, isLucky: false),
    GiftItem(id: "2006", baseName: "love bouquet", price: 200, isLucky: false),
    GiftItem(id: "2007", baseName: "wedding dress", price: 260, isLucky: false),
    GiftItem(id: "2008", baseName: "Romantic love songs", price: 150, isLucky: false),
    GiftItem(id: "2009", baseName: "lion beauty", price: 300, isLucky: false),
    GiftItem(id: "2010", baseName: "Wealth-Bringing Demon Mask", price: 238, isLucky: false),
    GiftItem(id: "2011", baseName: "Silver Crown Daughter", price: 300, isLucky: false),
    GiftItem(id: "2012", baseName: "Misty Valley White Tiger", price: 230, isLucky: false),
    // Lucky category
    GiftItem(id: "3001", baseName: "Donut", price: 66, isLucky: true),
    GiftItem(id: "3002", baseName: "9 red roses", price: 200, isLucky: true),
    GiftItem(id: "3003", baseName: "Bouquet of 5 white roses", price: 166, isLucky: true),
    GiftItem(id: "3004", baseName: "Goddess Letter", price: 150, isLucky: true),
    GiftItem(id: "3005", baseName: "love rose", price: 200, isLucky: true),
    GiftItem(id: "3006", baseName: "Love Gramophone", price: 200, isLucky: true),
  ];

  // 2. GETTERS FOR UI
  static List<GiftItem> get generalGifts => allGifts.where((g) => !g.isLucky).toList();
  static List<GiftItem> get luckyGifts => allGifts.where((g) => g.isLucky).toList();

  // 3. HELPER: Find Gift By ID (Useful for ViewModel/Player)
  static GiftItem? findById(String id) {
    try {
      return allGifts.firstWhere((element) => element.id == id);
    } catch (e) {
      return null;
    }
  }

  // 4. HELPER: Get SVGA Name By ID directly
  static String? getSvgaNameById(String id) {
    final gift = findById(id);
    return gift?.baseName;
  }

  static String png(String baseName) {
    final path = "$_folder/$baseName.png";
    return path;
  }

  static String svga(String baseName) {
    final path = "$_folder/$baseName.svga";
    return path;
  }
}