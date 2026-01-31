import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:kittyparty/core/global_widgets/dialogs/dialog_info.dart';
import 'package:kittyparty/features/livestream/widgets/user_selector.dart';

import '../../../core/services/api/gift_service.dart';
import '../../landing/model/gift_item.dart';
import '../viewmodel/live_audio_room_viewmodel.dart';
import '../../../core/utils/remote_asset_helper.dart';

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

  final GiftService _service = GiftService();

  final List<int> _comboOptions = const [1, 5, 10, 20, 50];
  int _selectedCombo = 1;

  Timer? _luckySendTimer;
  bool _isSendingLucky = false;

  bool _loading = true;
  List<GiftItem> _gifts = [];

  // ============================================================
  // INIT
  // ============================================================
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _loadGifts();
  }
  Future<void> _loadGifts() async {
    try {
      final res = await _service.fetchGifts();
      final Map<String, dynamic> data = res['data'];

      final gifts = data.entries
          .map((e) => GiftItem.fromJson(e.key, e.value))
          .toList();

      // 🔥 PRELOAD ALL PNGs ONCE
      await Future.wait(
        gifts.map((g) => RemoteAssetHelper.load(g.png)),
      );

      setState(() {
        _gifts = gifts;
        _loading = false;
      });
    } catch (e, stack) {
      // 🔍 LOG THE ACTUAL ERROR
      debugPrint("❌ [GiftModal] Failed to load gifts");
      debugPrint("❌ Error: $e");
      debugPrint("❌ StackTrace:\n$stack");

      DialogInfo(
        headerText: "Error",
        subText: "Failed to load gifts",
        confirmText: "Confirm",
        onConfirm: () => Navigator.pop(context),
        onCancel: () => Navigator.pop(context),
      ).build(context);
    }
  }



  @override
  void dispose() {
    _luckySendTimer?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  // ============================================================
  // FILTERS
  // ============================================================
  List<GiftItem> _cat(String c) =>
      _gifts.where((g) => g.category == c).toList();

  // ============================================================
  // LUCKY HOLD LOGIC
  // ============================================================
  void _startLuckyGift({
    required VoidCallback sendOnce,
    Duration interval = const Duration(milliseconds: 400),
  }) {
    if (_isSendingLucky) return;

    _isSendingLucky = true;
    sendOnce();

    _luckySendTimer = Timer.periodic(interval, (_) {
      sendOnce();
    });
  }

  void _stopLuckyGift() {
    _luckySendTimer?.cancel();
    _luckySendTimer = null;
    _isSendingLucky = false;
  }

  // ============================================================
  // UI
  // ============================================================
  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const SizedBox(
        height: 420,
        child: Center(child: CircularProgressIndicator()),
      );
    }

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
                _grid(_cat("general")),
                _grid(_cat("ride")),
                _grid(_cat("lucky")),
                _grid(_cat("frame")),
                _grid(_cat("couple")),
                _grid(_cat("vip")),
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

  Widget _title() => const Padding(
    padding: EdgeInsets.symmetric(horizontal: 16),
    child: Align(
      alignment: Alignment.centerLeft,
      child: Text(
        "Send a Gift",
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    ),
  );

  Widget _comboPicker() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Row(
      children: [
        const Text(
          "Quantity:",
          style: TextStyle(color: Colors.white70, fontSize: 12),
        ),
        const SizedBox(width: 6),
        Wrap(
          spacing: 6,
          children: _comboOptions.map((v) {
            final selected = v == _selectedCombo;
            return GestureDetector(
              onTap: () => setState(() => _selectedCombo = v),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: selected ? Colors.pinkAccent : Colors.white10,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "x$v",
                  style: TextStyle(
                    color: selected ? Colors.white : Colors.white70,
                    fontSize: 11,
                  ),
                ),
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

  Widget _grid(List<GiftItem> list) => GridView.builder(
    padding: const EdgeInsets.all(12),
    itemCount: list.length,
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 4,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: .72,
    ),
    itemBuilder: (_, i) => _cell(list[i]),
  );

  Widget _cell(GiftItem gift) {
    final bool isLuckyContinuous =
        gift.category == "lucky" && gift.id.startsWith('3');

    return GestureDetector(
      behavior: HitTestBehavior.opaque,

      onTapDown: isLuckyContinuous
          ? (_) => _startLuckyGift(
        sendOnce: () => widget.viewModel.sendGift(
          roomId: widget.roomId,
          senderId: widget.senderId,
          receiverId: widget.receiverId,
          giftType: gift.id,
          giftCount: _selectedCombo,
        ),
      )
          : null,

      onTapUp: isLuckyContinuous ? (_) => _stopLuckyGift() : null,
      onTapCancel: isLuckyContinuous ? _stopLuckyGift : null,

      onTap: isLuckyContinuous
          ? null
          : () async {
        final rootContext =
            Navigator.of(context, rootNavigator: true).context;

        Navigator.pop(context);

        final receiver = await showModalBottomSheet<String>(
          context: rootContext,
          backgroundColor: Colors.transparent,
          isScrollControlled: true,
          builder: (_) =>
              UserSelectorModal(viewModel: widget.viewModel),
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

      child: Column(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(12),
                border: isLuckyContinuous
                    ? Border.all(color: Colors.pinkAccent)
                    : null,
              ),
              child: _GiftImage(path: gift.png),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            gift.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white, fontSize: 10),
          ),
          const SizedBox(height: 2),
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
    );
  }
}

// ============================================================
// BACKEND PNG LOADER
// ============================================================
class _GiftImage extends StatelessWidget {
  final String path;
  const _GiftImage({required this.path});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<File>(
      future: RemoteAssetHelper.load(path),
      builder: (_, snap) {
        if (!snap.hasData) return const SizedBox();
        return Image.file(snap.data!, fit: BoxFit.contain);
      },
    );
  }
}
