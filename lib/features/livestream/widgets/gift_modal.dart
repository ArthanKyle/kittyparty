import 'package:flutter/material.dart';
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
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  GiftItem _gift(String id, String base, int price, {bool lucky = false, bool couple = false}) {
    return GiftItem(id: id, baseName: base, price: price, isLucky: lucky, isCouple: couple);
  }

  /// ================== GIFT LIST ==================
  List<GiftItem> get _gifts => [

    // GENERAL
    _gift("2001", "Red Rose Bookstore", 200),
    _gift("2002", "Charming female singer", 400),
    _gift("2003", "rose string tone", 200),
    _gift("2004", "Rolex", 200),
    _gift("2005", "rose crystal bottle", 150),
    _gift("2006", "love bouquet", 200),
    _gift("2007", "wedding dress", 260),
    _gift("2008", "Romantic love songs", 150),
    _gift("2009", "lion beauty", 300),
    _gift("2010", "Wealth-Bringing Demon Mask", 238),
    _gift("2011", "Silver Crown Daughter", 300),
    _gift("2012", "Misty Valley White Tiger", 230),

    // LUCKY
    _gift("3001", "Donut", 66, lucky: true),
    _gift("3002", "9 red roses", 200, lucky: true),
    _gift("3003", "Bouquet of 5 white roses", 166, lucky: true),
    _gift("3004", "Goddess Letter", 150, lucky: true),
    _gift("3005", "love rose", 200, lucky: true),
    _gift("3006", "Love Gramophone", 200, lucky: true),

    // COUPLE (empty now, but UI won't break)
    // _gift("4001","Couple Swan",500,couple:true),  ← example later
  ];

  List<GiftItem> get _general => _gifts.where((g) => !g.isLucky && !g.isCouple).toList();
  List<GiftItem> get _lucky => _gifts.where((g) => g.isLucky).toList();
  List<GiftItem> get _couple => _gifts.where((g) => g.isCouple).toList();

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
                _grid(_lucky),
                _grid(_couple),   // FIXED — no crash anymore
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

  Widget _tabs()=>TabBar(
    controller:_tabController,
    labelColor:Colors.white,
    unselectedLabelColor:Colors.white54,
    indicatorColor:Colors.pinkAccent,
    tabs: const [
      Tab(text:"General"),
      Tab(text:"Lucky"),
      Tab(text:"Couple"),    // ← FIXED: now corresponding TabBarView exists
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
      onTap:()async{
        Navigator.pop(context);

        final receiver=await showModalBottomSheet<String>(
          context:context,
          backgroundColor:Colors.transparent,
          isScrollControlled:true,
          builder:(_)=>UserSelectorModal(viewModel:widget.viewModel),
        );

        if(receiver==null) return;

        widget.viewModel.sendGift(
          roomId:widget.roomId,
          senderId:widget.senderId,
          receiverId:receiver,
          giftType:gift.id,
          giftCount:_selectedCombo,
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

          Text(gift.baseName,
              maxLines:2,overflow:TextOverflow.ellipsis,
              style:const TextStyle(color:Colors.white,fontSize:10)
          ),

          const SizedBox(height:2),

          Row(
            mainAxisAlignment:MainAxisAlignment.center,
            children:[
              Image.asset("assets/icons/jewel.PNG",height:12,width:12),
              const SizedBox(width:4),
              Text("${gift.price}",
                  style:const TextStyle(
                      color:Colors.blueAccent,fontWeight:FontWeight.bold,fontSize:11))
            ],
          ),
        ],
      ),
    );
  }
}

class GiftItem{
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
    this.isCouple=false,
  });

  String get png => GiftAssets.png(baseName);
  String get svga => GiftAssets.svga(baseName);
}
