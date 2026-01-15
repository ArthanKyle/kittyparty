import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/profile_picture_helper.dart';
import '../../../core/utils/user_provider.dart';
import '../../landing/landing_widgets/profile_widgets/inventory_asset_resolver.dart';
import '../../landing/viewmodel/inventory_viewmodel.dart';
import '../../landing/viewmodel/profile_viewmodel.dart';


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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ItemViewModel>().ensureBound(context);
    });
  }

  /// UI category → allowed backend categories
  List<String> _allowedCategoriesFor(String label) {
    switch (label) {
      case 'Mount':
        return ['mount', 'MOUNT'];
      case 'Avatar':
        return ['avatar', 'AVATAR', 'AVATARFRAME', 'avatarframe'];
      case 'Nameplate':
        return ['nameplate', 'NAMEPLATE'];
      case 'Profile Card':
        return ['profile_card', 'PROFILECARD'];
      case 'Chat Bubble':
        return ['chat_bubble', 'CHATBUBBLE'];
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<UserProvider, ProfileViewModel, ItemViewModel>(
      builder: (context, userProvider, profileVM, itemVM, _) {
        final user = userProvider.currentUser;

        final avatar = user == null
            ? const CircleAvatar(
          radius: 40,
          backgroundColor: Colors.white24,
        )
            : UserAvatarHelper.circleAvatar(
          userIdentification: user.userIdentification,
          displayName:
          user.fullName ?? user.username ?? "U",
          radius: 40,
          localBytes: profileVM.profilePictureBytes,
        );

        // ================= FILTER + SORT =================
        final selectedLabel = categories[selectedIndex]['label'];
        final allowedCategories =
        _allowedCategoriesFor(selectedLabel);

        final filteredInventory = itemVM.inventory
            .where((inv) =>
            allowedCategories.contains(inv.category))
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
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
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
                            "My Item",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 40),
                    ],
                  ),
                ),

                const SizedBox(height: 10),
                avatar,
                const SizedBox(height: 20),

                // ================= CATEGORY BAR =================
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: List.generate(categories.length,
                            (index) {
                          final c = categories[index];
                          final selected =
                              index == selectedIndex;

                          return GestureDetector(
                            onTap: () => setState(
                                    () => selectedIndex = index),
                            child: Container(
                              margin: const EdgeInsets.only(right: 10),
                              padding:
                              const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 10),
                              decoration: BoxDecoration(
                                color: selected
                                    ? const Color(0xFF2A144A)
                                    : const Color(0xFF1B2440),
                                borderRadius:
                                BorderRadius.circular(12),
                              ),
                              child: Column(
                                children: [
                                  Image.asset(
                                    c['icon'],
                                    width: 45,
                                    height: 45,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    c['label'],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                  ),
                ),

                const SizedBox(height: 30),

                // ================= INVENTORY =================
                Expanded(
                  child: filteredInventory.isEmpty
                      ? ListView(
                    children: const [
                      SizedBox(height: 120),
                      Center(
                        child: Text(
                          "No items",
                          style: TextStyle(
                              color: Colors.white70),
                        ),
                      ),
                    ],
                  )
                      : ListView.builder(
                    itemCount:
                    filteredInventory.length,
                    itemBuilder: (_, i) {
                      final inv =
                      filteredInventory[i];

                      final resolvedPath =
                      InventoryAssetResolver.resolve(
                        category: inv.category ?? '',
                        sku: inv.sku,
                      );

                      return ListTile(
                        leading: resolvedPath != null
                            ? Image.asset(
                          resolvedPath,
                          width: 48,
                          height: 48,
                          errorBuilder:
                              (_, __, ___) =>
                          const Icon(
                            Icons
                                .image_not_supported,
                            color:
                            Colors.white54,
                          ),
                        )
                            : const Icon(
                          Icons.inventory_2,
                          color: Colors.white54,
                        ),
                        title: Text(
                          inv.sku,
                          style: const TextStyle(
                              color: Colors.white),
                        ),
                        subtitle: Text(
                          inv.category ?? '',
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                        trailing: inv.equipped
                            ? const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                        )
                            : TextButton(
                          onPressed: () =>
                              itemVM.equip(inv),
                          child:
                          const Text("Equip"),
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
