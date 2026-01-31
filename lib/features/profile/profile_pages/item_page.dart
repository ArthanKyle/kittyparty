import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/inventory_asset_helper.dart';
import '../../../core/utils/profile_picture_helper.dart';
import '../../../core/utils/user_provider.dart';
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
    {'icon': 'assets/icons/item/Mount.png', 'label': 'Mount', 'type': 'mount'},
    {'icon': 'assets/icons/item/Avatar.png', 'label': 'Avatar', 'type': 'avatar'},
    {'icon': 'assets/icons/item/Nameplate.png', 'label': 'Nameplate', 'type': 'nameplate'},
    {'icon': 'assets/icons/item/Profile_card.png', 'label': 'Profile Card', 'type': 'profile_card'},
    {'icon': 'assets/icons/item/Chat_bubble.png', 'label': 'Chat Bubble', 'type': 'chat_bubble'},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ItemViewModel>().ensureBound(context);
    });
  }

  Future<void> _onRefresh(BuildContext context) async {
    await context.read<ItemViewModel>().loadInventory();
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
          frameUrl: profileVM.avatarFrameAsset,
        );

        final selectedType = categories[selectedIndex]['type'];

        final items = itemVM.inventory
            .where((i) => i.assetType == selectedType)
            .toList()
          ..sort((a, b) {
            if (a.equipped && !b.equipped) return -1;
            if (!a.equipped && b.equipped) return 1;
            return (a.assetKey ?? '').compareTo(b.assetKey ?? '');
          });

        return Scaffold(
          backgroundColor: const Color(0xFF0C1225),
          body: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 12),
                avatar,
                const SizedBox(height: 30),

                /// CATEGORY BAR
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
                              Text(c['label'],
                                  style: const TextStyle(color: Colors.white)),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ),

                const SizedBox(height: 20),

                /// INVENTORY LIST
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () => _onRefresh(context),
                    child: items.isEmpty
                        ? ListView(
                      children: const [
                        SizedBox(height: 120),
                        Center(
                          child: Text(
                            'No items',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ),
                      ],
                    )
                        : ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (_, i) {
                        final inv = items[i];

                        final imageUrl = InventoryMediaHelper.imageUrl(
                          assetType: inv.assetType,
                          assetKey: inv.assetKey!,
                        );

                        return ListTile(
                          leading: Image.network(
                            imageUrl,
                            width: 48,
                            errorBuilder: (_, __, ___) =>
                            const Icon(Icons.image_not_supported),
                          ),
                          title: Text(
                            inv.assetKey ?? inv.sku,
                            style: const TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(
                            inv.assetType,
                            style:
                            const TextStyle(color: Colors.white54),
                          ),
                          trailing: inv.equipped
                              ? TextButton(
                            onPressed: () =>
                                itemVM.unequip(inv),
                            child: const Text('Unequip'),
                          )
                              : TextButton(
                            onPressed: () =>
                                itemVM.equip(inv),
                            child: const Text('Equip'),
                          ),
                        );
                      },
                    ),
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
