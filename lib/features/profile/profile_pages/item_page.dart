import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/profile_picture_helper.dart';
import '../../../core/utils/user_provider.dart';
import '../../landing/landing_widgets/profile_widgets/inventory_asset_resolver.dart';
import '../../landing/viewmodel/inventory_viewmodel.dart';
import '../../landing/viewmodel/profile_viewmodel.dart';
import '../../landing/model/userInventory.dart';

class ItemPage extends StatefulWidget {
  const ItemPage({super.key});

  @override
  State<ItemPage> createState() => _ItemPageState();
}

class _ItemPageState extends State<ItemPage> {
  int selectedIndex = 0;

  final List<Map<String, dynamic>> categories = const [
    {'icon': 'assets/icons/item/Mount.png', 'label': 'Mount'},
    {'icon': 'assets/icons/item/Avatar.png', 'label': 'Avatar'},
    {'icon': 'assets/icons/item/Nameplate.png', 'label': 'Nameplate'},
    {'icon': 'assets/icons/item/Profile_card.png', 'label': 'Profile Card'},
    {'icon': 'assets/icons/item/Chat_bubble.png', 'label': 'Chat Bubble'},
  ];

  @override
  void initState() {
    super.initState();
  }

  // ================= CATEGORY HELPERS =================

  String deriveCategoryFromSku(String sku) {
    final s = sku.toUpperCase();
    if (s.startsWith('MOUNT')) return 'MOUNT';
    if (s.contains('FRAME') || s.contains('AVATAR')) return 'AVATAR';
    if (s.contains('NAMEPLATE')) return 'NAMEPLATE';
    if (s.contains('PROFILE')) return 'PROFILECARD';
    if (s.contains('CHAT')) return 'CHATBUBBLE';
    return 'UNKNOWN';
  }

  bool isAvatarFrame(String sku) {
    return sku.toUpperCase().contains('FRAME');
  }

  List<String> _allowedCategoriesFor(String label) {
    switch (label) {
      case 'Mount':
        return ['MOUNT'];
      case 'Avatar':
        return ['AVATAR'];
      case 'Nameplate':
        return ['NAMEPLATE'];
      case 'Profile Card':
        return ['PROFILECARD'];
      case 'Chat Bubble':
        return ['CHATBUBBLE'];
      default:
        return [];
    }
  }

  // ================= EQUIP / UNEQUIP =================

  Future<void> _handleEquip(BuildContext context, UserInventoryItem inv) async {
    final itemVM = context.read<ItemViewModel>();
    final profileVM = context.read<ProfileViewModel>();

    if (itemVM.isEquipping) return;

    await itemVM.equip(inv);

    // ✅ FORCE PROFILE SYNC AFTER EQUIP
    profileVM.syncFromInventory(itemVM.inventory);
  }

  Future<void> _handleUnequip(BuildContext context, UserInventoryItem inv) async {
    final itemVM = context.read<ItemViewModel>();
    final profileVM = context.read<ProfileViewModel>();

    if (itemVM.isEquipping) return;

    await itemVM.unequip(inv);

    // ✅ FORCE PROFILE SYNC AFTER UNEQUIP
    profileVM.syncFromInventory(itemVM.inventory);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<UserProvider, ProfileViewModel, ItemViewModel>(
      builder: (context, userProvider, profileVM, itemVM, _) {
        final user = userProvider.currentUser;

        final avatar = user == null
            ? const CircleAvatar(radius: 60)
            : UserAvatarHelper.circleAvatar(
          userIdentification: user.userIdentification,
          displayName: user.fullName ?? user.username ?? 'U',
          radius: 60,
          localBytes: profileVM.profilePictureBytes,
          frameAsset: profileVM.avatarFrameAsset,
        );

        final selectedLabel = categories[selectedIndex]['label'];
        final allowed = _allowedCategoriesFor(selectedLabel);

        final items = itemVM.inventory
            .where((i) => allowed.contains(deriveCategoryFromSku(i.sku)))
            .toList()
          ..sort((a, b) {
            if (a.equipped && !b.equipped) return -1;
            if (!a.equipped && b.equipped) return 1;
            return a.sku.compareTo(b.sku);
          });

        return Scaffold(
          backgroundColor: const Color(0xFF0C1225),
          body: SafeArea(
            child: Column(
              children: [
                // ================= HEADER =================
                Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white,
                          size: 18,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Expanded(
                        child: Center(
                          child: Text(
                            'My Item',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 40), // balance back button
                    ],
                  ),
                ),

                const SizedBox(height: 20),
                avatar,
                const SizedBox(height: 50),

                // ================= CATEGORY BAR =================
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: List.generate(categories.length, (i) {
                      final c = categories[i];
                      final selected = i == selectedIndex;

                      return GestureDetector(
                        onTap: () => setState(() => selectedIndex = i),
                        child: Container(
                          margin: const EdgeInsets.only(right: 10),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: selected
                                ? const Color(0xFF2A144A)
                                : const Color(0xFF1B2440),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Image.asset(c['icon'], width: 45),
                              const SizedBox(height: 6),
                              Text(
                                c['label'],
                                style:
                                const TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ),

                const SizedBox(height: 40),

                // ================= INVENTORY =================
                Expanded(
                  child: items.isEmpty
                      ? const Center(
                    child: Text(
                      'No items',
                      style:
                      TextStyle(color: Colors.white70),
                    ),
                  )
                      : ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (_, i) {
                      final inv = items[i];
                      final category =
                      deriveCategoryFromSku(inv.sku);

                      final asset =
                      InventoryAssetResolver.resolve(
                        category: category,
                        sku: inv.sku,
                      );

                      return ListTile(
                        leading: asset != null
                            ? Image.asset(asset, width: 48)
                            : const Icon(
                          Icons.inventory_2,
                          color: Colors.white54,
                        ),
                        title: Text(
                          inv.sku,
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        subtitle: Text(
                          category,
                          style: const TextStyle(
                            color: Colors.white54,
                          ),
                        ),
                        trailing: itemVM.isEquipping
                            ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                            : inv.equipped
                            ? TextButton(
                          onPressed: () => _handleUnequip(context, inv),
                          child: const Text('Unequip'),
                        )
                            : TextButton(
                          onPressed: () => _handleEquip(context, inv),
                          child: const Text('Equip'),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
