import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../../core/utils/user_provider.dart';
import '../../landing/landing_widgets/profile_widgets/mall/friend_picker_sheet.dart';
import '../../landing/landing_widgets/profile_widgets/mall/mall_svga_dialog.dart';
import '../../landing/viewmodel/mall_viewmodel.dart';
import '../../landing/model/mall_item.dart';

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

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<MallViewModel>();
      vm.bindUser(context);
      vm.loadMall();
    });
  }

  void _openSvga(MallItem item) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.transparent,
      builder: (_) => MallSvgaDialog(
        svgaUrl: '${dotenv.env['MEDIA_BASE_URL']}${item.svga}',
      ),
    );
  }

  Future<void> _refresh() async {
    await context.read<MallViewModel>().loadMall();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MallViewModel>();

    final items = vm.items.where((i) {
      if (selectedIndex == 0) {
        return i.assetType == 'mount';
      } else {
        return i.assetType == 'avatar';
      }
    }).toList();

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
                child: vm.isLoading
                    ? const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFFFFD700),
                  ),
                )
                    : GridView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: .75,
                  ),
                  itemCount: items.length,
                  itemBuilder: (_, i) {
                    final item = items[i];
                    final isSelected =
                        vm.selectedItem?.id == item.id;

                    return InkWell(
                      onTap: () => vm.select(item),
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
                                  child: Image.network(
                                    '${dotenv.env['MEDIA_BASE_URL']}${item.png}',
                                    height: 130,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  right: 8,
                                  bottom: 8,
                                  child: GestureDetector(
                                    onTap: () => _openSvga(item),
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
                                    item.name,
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
                                        width: 16,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        vm.displayPrice(item)
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

                                  if (item.durationDays != null &&
                                      item.durationDays! > 0) ...[
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
                      Image.asset('assets/icons/KPcoin.png', width: 22),
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
                          final currentUserId = context
                              .read<UserProvider>()
                              .currentUser!
                              .userIdentification;

                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (_) => FriendPickerSheet(
                              currentUserId: currentUserId,
                              onSelected: (friend) {
                                vm.giftSelected(
                                  context,
                                  targetUserIdentification:
                                  friend.userIdentification,
                                );
                              },
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 10),
                      _actionButton(
                        label: 'Buy',
                        enabled:
                        vm.selectedItem != null && !vm.isBuying,
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
