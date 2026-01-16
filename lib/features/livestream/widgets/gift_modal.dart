import 'package:flutter/material.dart';
import 'package:kittyparty/core/global_widgets/dialogs/dialog_info.dart';
import 'package:kittyparty/features/livestream/widgets/user_selector.dart';
import '../viewmodel/live_audio_room_viewmodel.dart';
import 'gift_assets.dart';

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
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  GiftItem _gift(String id, String base, int price, {bool lucky = false, bool couple = false}) {
    return GiftItem(id: id, baseName: base, price: price, isLucky: lucky, isCouple: couple);
  }

  List<GiftItem> get _gifts => [

    // ================= GENERAL =================
    _gift("2001", "Red Rose Bookstore", 55000),
    _gift("2002", "Charming female singer", 1000000),
    _gift("2003", "rose string tone", 45000),
    _gift("2004", "Rolex", 75000),
    _gift("2005", "rose crystal bottle", 11000),
    _gift("2006", "love bouquet", 2000),
    _gift("2007", "wedding dress", 200000),
    _gift("2008", "Romantic love songs", 299000),
    _gift("2009", "lion beauty", 255000),
    _gift("2010", "Wealth-Bringing Demon Mask", 59000),
    _gift("2011", "Silver Crown Daughter", 35000),
    _gift("2012", "Misty Valley White Tiger", 30000),
    _gift("2013", "The Supreme Lion King makes his appearance", 70000),
    _gift("2014", "Golden Elephant Brings Wealth", 52000),

    // ================= LUCKY =================
    _gift("3001", "Donut", 10, lucky: true),
    _gift("3002", "Bouquet of 5 white roses", 100, lucky: true),
    _gift("3003", "Goddess Letter", 30, lucky: true),
    _gift("3004", "love rose", 50, lucky: true),
    _gift("3005", "Love Gramophone", 20, lucky: true),
    _gift("3006", "love chocolate", 100, lucky: true),
    _gift("3007", "love bouquet", 150, lucky: true),
    _gift("3008", "rose crystal bottle", 1000, lucky: true),
    _gift("3009", "rose string tone", 1500, lucky: true),
    _gift("3010", "Red Rose Bookstore", 1200, lucky: true),
    _gift("3011", "Rolex", 88, lucky: true),

    // ================= COUPLE =================
    _gift("4001", "Palm Island sunset", 599000, couple: true),
    _gift("4002", "A Stunning Encounter", 300000, couple: true),
    _gift("4003", "Heartbeat Rose Lover", 350000, couple: true),
    _gift("4004", "Ambiguous cocktail party", 699000, couple: true),
    _gift("4005", "red carpet couple", 399000, couple: true),
    _gift("4006", "private island", 299000, couple: true),
    _gift("4007", "Oath of the Stars", 400000, couple: true),
    _gift("4008", "love chocolate", 2000, couple: true),
    _gift("4009", "golden wedding", 2000000, couple: true),
    _gift("4010", "Wedding Waltz", 50000, couple: true),
    _gift("4011", "glorious century", 450000, couple: true),

    // ================= MALL RIDES (LUCKY) =================
    _gift("5001", "eMule fans", 55000, lucky: true),
    _gift("5002", "eDonkey blue", 35000, lucky: true),
    _gift("5003", "Fortress Armored - Taurus", 150000, lucky: true),
    _gift("5004", "Corona King - Leo", 28000, lucky: true),
    _gift("5005", "Golden Dragon", 300000, lucky: true),
    _gift("5006", "Divine Dragon Supreme", 1000000, lucky: true),
    _gift("5007", "Starry Sky Off-Road - Sagittarius", 75000, lucky: true),
    _gift("5008", "Blazing Storm", 45000, lucky: true),
    _gift("5009", "Neon Phantom", 25000, lucky: true),
    _gift("5010", "Gilded Phantom", 55000, lucky: true),

    // ================= AVATAR FRAMES (LUCKY) =================
    _gift("6001", "Luxury car lion shadow avatar frame", 55000, lucky: true),
    _gift("6002", "Heart-fluttering 520 profile picture frame", 10000, lucky: true),
    _gift("6003", "520 Flower Profile Picture Frame", 20000, lucky: true),
    _gift("6004", "Black Rose Avatar Frame", 15000, lucky: true),
    _gift("6005", "Green Rose Avatar Frame", 15000, lucky: true),
    _gift("6006", "Crystal Crown - Silver", 3000, lucky: true),
    _gift("6007", "Springtime Vitality - Profile Picture Frame", 4000, lucky: true),
    _gift("6008", "Let's get married profile picture frame", 10000, lucky: true),
    _gift("6009", "Eternal Love Avatar Frame", 10000, lucky: true),
    _gift("6010", "CP Cat - Female", 5000, lucky: true),
    _gift("6011", "CP Cat - Male", 8000, lucky: true),
    _gift("6012", "Purple Rose Avatar Frame", 12000, lucky: true),
    _gift("6013", "Blue Rose Avatar Frame", 15000, lucky: true),
    _gift("6014", "Pink Rose Avatar Frame", 10000, lucky: true),

    // ================= MEDALS (VIP) =================
    _gift("7001", "Medal Level 1", 0, lucky: true),
    _gift("7002", "Medal Level 2", 0, lucky: true),
    _gift("7003", "Medal Level 3", 0, lucky: true),
    _gift("7004", "Medal Level 4", 0, lucky: true),
    _gift("7005", "Medal Level 5", 0, lucky: true),
    _gift("7006", "Medal Level 6", 0, lucky: true),
    _gift("7007", "Medal Level 7", 0, lucky: true),

  ];



  /// ================= FILTERED LISTS =================

  List<GiftItem> get _general =>
      _gifts.where((g) =>
      !g.isLucky &&
          !g.isCouple &&
          !g.id.startsWith('5') &&
          !g.id.startsWith('6')
      ).toList();

  /// Lucky tab → ONLY 3xxx gifts
  List<GiftItem> get _lucky =>
      _gifts.where((g) =>
      g.isLucky &&
          g.id.startsWith('3')
      ).toList();

  /// Rides tab → 5xxx (even though they are lucky)
  List<GiftItem> get _rides =>
      _gifts.where((g) =>
          g.id.startsWith('5')
      ).toList();

  /// Frame tab → 6xxx (even though they are lucky)
  List<GiftItem> get _frames =>
      _gifts.where((g) =>
          g.id.startsWith('6')
      ).toList();

  /// Couple tab → unchanged
  List<GiftItem> get _couple =>
      _gifts.where((g) => g.isCouple).toList();

  /// VIP tab → future-proof (7xxx medals, etc.)
  List<GiftItem> get _vip =>
      _gifts.where((g) => g.id.startsWith('7')).toList();


  /// ================== UI ==================
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
          _grabber(),
          const SizedBox(height: 10),
          _title(),
          const SizedBox(height: 10),
          _comboPicker(),
          const SizedBox(height: 10),
          _tabs(),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _grid(_general),
                _grid(_rides),
                _grid(_lucky),
                _grid(_frames),
                _grid(_couple),
                _grid(_vip),
              ],
            ),
          ),

        ],
      ),
    );
  }

  Widget _grabber() => Container(
    width: 40,
    height: 4,
    decoration: BoxDecoration(
      color: Colors.white24,
      borderRadius: BorderRadius.circular(100),
    ),
  );

  Widget _title() => const Align(
    alignment: Alignment.centerLeft,
    child: Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Text("Send a Gift",
          style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 16)),
    ),
  );

  Widget _comboPicker() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Row(
      children: [
        const Text("Quantity:", style: TextStyle(color: Colors.white70,fontSize: 12)),
        const SizedBox(width: 6),
        Wrap(
          spacing: 6,
          children: _comboOptions.map((v){
            final selected=v==_selectedCombo;
            return GestureDetector(
              onTap: ()=>setState(()=>_selectedCombo=v),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal:10,vertical:4),
                decoration:BoxDecoration(
                  color:selected?Colors.pinkAccent:Colors.white10,
                  borderRadius:BorderRadius.circular(12),
                  border:Border.all(color:selected?Colors.pinkAccent:Colors.white24),
                ),
                child: Text("x$v",
                    style:TextStyle(color:selected?Colors.white:Colors.white70,fontSize:11)),
              ),
            );
          }).toList(),
        ),
      ],
    ),
  );

  Widget _tabs() => TabBar(
    controller: _tabController,
    isScrollable: true,
    labelColor: Colors.white,
    unselectedLabelColor: Colors.white54,
    indicatorColor: Colors.pinkAccent,
    tabs: const [
      Tab(text: "General"),
      Tab(text: "Rides"),
      Tab(text: "Lucky"),
      Tab(text: "Frame"),
      Tab(text: "Couple"),
      Tab(text: "VIP"),
    ],
  );


  Widget _grid(List<GiftItem> list)=>GridView.builder(
    padding:const EdgeInsets.all(12),
    itemCount:list.length,
    gridDelegate:const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount:4,
        mainAxisSpacing:10,crossAxisSpacing:10,childAspectRatio:.72),
    itemBuilder:(_,i)=>_cell(list[i]),
  );

  Widget _cell(GiftItem gift){
    return GestureDetector(
      onTap: () async {
        final rootContext = Navigator.of(context, rootNavigator: true).context;

        // Close GiftModal
        Navigator.pop(context);

        final receiver = await showModalBottomSheet<String>(
          context: rootContext,
          backgroundColor: Colors.transparent,
          isScrollControlled: true,
          builder: (_) => UserSelectorModal(viewModel: widget.viewModel),
        );

        if (receiver == null) return;


        widget.viewModel.sendGift(
          roomId: widget.roomId,
          senderId: widget.senderId,
          receiverId: receiver,
          giftType: gift.id,
          giftCount: _selectedCombo,
        );
      },

      child:Column(
        children:[
          Expanded(
            child:Container(
              decoration:BoxDecoration(
                  color:Colors.white10,borderRadius:BorderRadius.circular(12)),
              child:Padding(
                padding:const EdgeInsets.all(6),
                child:Image.asset(gift.png,fit:BoxFit.contain),
              ),
            ),
          ),

          const SizedBox(height:4),

          Text(
            toSentenceCase(gift.baseName),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
            ),
          ),

          const SizedBox(height:2),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset("assets/icons/KPcoin.png", height: 10, width: 10),
              const SizedBox(width: 4),
              Text(
                gift.price.toString(),
                style: const TextStyle(
                  color: Colors.amber,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
String toSentenceCase(String text) {
  if (text.isEmpty) return text;
  return text[0].toUpperCase() + text.substring(1).toLowerCase();
}


class GiftItem {
  final String id;
  final String baseName;
  final int price;
  final bool isLucky;
  final bool isCouple;

  const GiftItem({
    required this.id,
    required this.baseName,
    required this.price,
    required this.isLucky,
    this.isCouple = false,
  });

  String get png {
    final prefix = id.substring(0, 1);

    // 5xxx → rides
    if (prefix == '5') {
      return GiftAssets.ridePng(baseName);
    }

    // 6xxx → avatar frames
    if (prefix == '6') {
      return GiftAssets.avatarPng(baseName);
    }

    // 7xxx → medals (VIP)
    if (prefix == '7') {
      return GiftAssets.medalPng(baseName);
    }

    // default → gifts
    return GiftAssets.png(baseName);
  }

  String get svga => GiftAssets.svga(baseName);
}
