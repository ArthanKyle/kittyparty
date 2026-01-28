import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/user_provider.dart';
import '../../landing/landing_widgets/profile_widgets/mall/friend_picker_sheet.dart';
import '../../landing/landing_widgets/profile_widgets/mall/mall_svga_dialog.dart';
import '../../landing/viewmodel/mall_viewmodel.dart';
import '../../landing/landing_widgets/profile_widgets/mall/asset_catalog.dart';

class MallPage extends StatefulWidget {
  const MallPage({super.key});

  @override
  State<MallPage> createState() => _MallPageState();
}

class _MallPageState extends State<MallPage> {
  int selectedIndex = 0;

  final List<Map<String, String>> categories = const [
    {'icon': 'assets/icons/item/Mount.png', 'label': 'Mount'},
    {'icon': 'assets/icons/item/Avatar.png', 'label': 'Avatar'},
  ];

  static const String _ridesFolder = 'assets/image/rides_mall/';
  static const String _avatarFolder = 'assets/image/avatar_mall/';

  late Future<Map<String, List<String>>> _assetsFuture;

  @override
  void initState() {
    super.initState();

    _assetsFuture = AssetCatalog.listByFolder(
      folders: const [_ridesFolder, _avatarFolder],
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<MallViewModel>();
      vm.bindUser(context);
      vm.loadMall();
    });
  }

  String _currentFolder() =>
      selectedIndex == 0 ? _ridesFolder : _avatarFolder;

  String assetKeyFromPath(String assetPath) {
    final file = assetPath.split('/').last;
    return file
        .replaceAll(
      RegExp(r'\.(png|jpg|jpeg|webp|svga)$', caseSensitive: false),
      '',
    )
        .replaceAll('_', ' ')
        .trim(); // ⬅️ DO NOT lowercase
  }


  void _openSvga(String assetKey) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.transparent,
      builder: (_) => MallSvgaDialog(
        key: ValueKey('${assetKey}_${DateTime.now().millisecondsSinceEpoch}'),
        assetKey: assetKey,
      ),
    );
  }

  Future<void> _refresh() async {
    await context.read<MallViewModel>().loadMall();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MallViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFF0C1225),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),

            /// CATEGORY BAR
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(categories.length, (i) {
                final isSelected = selectedIndex == i;
                final cat = categories[i];

                return InkWell(
                  onTap: () => setState(() => selectedIndex = i),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF2A144A)
                          : Colors.black26,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFFFFD700)
                            : Colors.transparent,
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Image.asset(cat['icon']!, width: 22),
                        const SizedBox(width: 8),
                        Text(
                          cat['label']!,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),

            const SizedBox(height: 16),

            /// GRID + PULL TO REFRESH
            Expanded(
              child: RefreshIndicator(
                color: const Color(0xFFFFD700),
                onRefresh: _refresh,
                child: FutureBuilder<Map<String, List<String>>>(
                  future: _assetsFuture,
                  builder: (_, snap) {
                    if (!snap.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFFFD700),
                        ),
                      );
                    }

                    final assets =
                        snap.data![_currentFolder()] ?? const <String>[];

                    return GridView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                        childAspectRatio: .75,
                      ),
                      itemCount: assets.length,
                      itemBuilder: (_, i) {
                        final assetPath = assets[i];
                        final key = assetKeyFromPath(assetPath);
                        final item = vm.findByAssetKey(key);
                        final isSelected =
                            vm.selectedItem?.assetKey == item?.assetKey;

                        return InkWell(
                          onTap:
                          item == null ? null : () => vm.select(item),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF2A144A)
                                  : const Color(0xFF11203E),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFFFFD700)
                                    : const Color(0xFF546AA2),
                                width: isSelected ? 1.4 : 0.7,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius:
                                      const BorderRadius.vertical(
                                          top: Radius.circular(12)),
                                      child: Image.asset(
                                        assetPath,
                                        height: 130,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Positioned(
                                      right: 8,
                                      bottom: 8,
                                      child: GestureDetector(
                                        onTap: () => _openSvga(key),
                                        child: Container(
                                          padding:
                                          const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: Colors.black
                                                .withOpacity(0.65),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.play_arrow,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item?.name ?? key,
                                        style: const TextStyle(
                                            color: Colors.white),
                                        maxLines: 1,
                                        overflow:
                                        TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 6),

                                      Row(
                                        children: [
                                          Image.asset(
                                              'assets/icons/KPcoin.png',
                                              width: 16),
                                          const SizedBox(width: 6),
                                          Text(
                                            item == null
                                                ? '—'
                                                : vm
                                                .displayPrice(item)
                                                .toString(),
                                            style: const TextStyle(
                                              color:
                                              Color(0xFFFFD700),
                                              fontWeight:
                                              FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 2),
                                      Text(
                                        'VIP 5 • 95% OFF',
                                        style: TextStyle(
                                          color: vm.isVip5
                                              ? Colors.greenAccent
                                              : Colors.white38,
                                          fontSize: 11,
                                        ),
                                      ),

                                      if (item?.durationDays != null &&
                                          item!.durationDays! > 0) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          'Valid ${item.durationDays} day(s)',
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),

            /// BOTTOM BAR
            Container(
              padding: const EdgeInsets.all(16),
              color: const Color(0xFF1B0C3A),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Image.asset('assets/icons/KPcoin.png',
                          width: 22),
                      const SizedBox(width: 8),
                      Text(
                        vm.selectedItem == null
                            ? '0'
                            : vm
                            .displayPrice(vm.selectedItem!)
                            .toString(),
                        style: const TextStyle(
                          color: Color(0xFFFFD700),
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      _actionButton(
                        label: 'Gift',
                        enabled: vm.canGiftSelected,
                        onTap: () {
                          final currentUserId =
                              context.read<UserProvider>().currentUser!.userIdentification;

                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (_) => FriendPickerSheet(
                              currentUserId: currentUserId,
                              onSelected: (friend) {
                                vm.giftSelected(
                                  context,
                                  targetUserIdentification: friend.userIdentification,
                                );
                              },
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 10),
                      _actionButton(
                        label: 'Buy',
                        enabled: vm.selectedItem != null &&
                            !vm.isBuying,
                        onTap: () => vm.buySelected(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton({
    required String label,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      height: 44,
      child: ElevatedButton(
        onPressed: enabled ? onTap : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4B3200),
          foregroundColor: const Color(0xFFFFD700),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        child: Text(label),
      ),
    );
  }
}
