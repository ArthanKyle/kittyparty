import 'package:flutter/material.dart';

import '../../landing/landing_widgets/profile_widgets/mall/asset_catalog.dart';


class MallPage extends StatefulWidget {
  const MallPage({super.key});

  @override
  State<MallPage> createState() => _MallPageState();
}

class _MallPageState extends State<MallPage> {
  int selectedIndex = 0;

  // Mall categories (UI buttons)
  final List<Map<String, String>> categories = const [
    {'icon': 'assets/icons/item/Mount.png', 'label': 'Mount'},
    {'icon': 'assets/icons/item/Avatar.png', 'label': 'Avatar'},
  ];

  // Map category -> asset folder
  // You asked: avatar => assets/image/avatar, rides => assets/image/rides
  static const String _ridesFolder = 'assets/image/rides/';
  static const String _avatarFolder = 'assets/image/avatar/';

  late Future<Map<String, List<String>>> _assetsFuture;

  @override
  void initState() {
    super.initState();
    _assetsFuture = AssetCatalog.listByFolder(
      folders: const [_ridesFolder, _avatarFolder],
    );
  }

  String _folderForSelectedCategory() {
    final label = categories[selectedIndex]['label'];
    if (label == 'Mount') return _ridesFolder;
    if (label == 'Avatar') return _avatarFolder;

    // Not provided: Nameplate/Profile Card/Chat Bubble directories.
    // Keep empty for now.
    return '';
  }

  String _prettyName(String assetPath) {
    // Example: assets/image/avatar/Green Rose Avatar Frame.png
    final file = assetPath.split('/').last;
    final noExt = file.replaceAll(RegExp(r'\.(png|jpg|jpeg|webp)$', caseSensitive: false), '');
    return noExt.replaceAll('_', ' ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C1225),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF061833), Color(0xFF000814)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 18),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Expanded(
                        child: Center(
                          child: Text(
                            "Mall",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6526A8),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.person, size: 16, color: Colors.white),
                            SizedBox(width: 4),
                            Text(
                              "My Dress",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // Categories
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: List.generate(categories.length, (index) {
                      final cat = categories[index];
                      final bool isSelected = index == selectedIndex;

                      return GestureDetector(
                        onTap: () => setState(() => selectedIndex = index),
                        child: Container(
                          margin: const EdgeInsets.only(right: 10),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF2A144A) : const Color(0xFF1B2440),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? const Color(0xFFFFD700) : Colors.transparent,
                              width: 1.2,
                            ),
                          ),
                          child: Column(
                            children: [
                              Image.asset(cat['icon']!, width: 35, height: 35),
                              const SizedBox(height: 6),
                              Text(
                                cat['label']!,
                                style: const TextStyle(color: Colors.white, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ),

                const SizedBox(height: 20),

                // Grid
                Expanded(
                  child: FutureBuilder<Map<String, List<String>>>(
                    future: _assetsFuture,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(
                          child: CircularProgressIndicator(color: Colors.yellow),
                        );
                      }

                      final folder = _folderForSelectedCategory();
                      if (folder.isEmpty) {
                        return const Center(
                          child: Text(
                            "No assets folder mapped for this category yet.",
                            style: TextStyle(color: Colors.white70),
                          ),
                        );
                      }

                      final assets = snapshot.data![folder] ?? const <String>[];
                      if (assets.isEmpty) {
                        return Center(
                          child: Text(
                            "No images found in $folder",
                            style: const TextStyle(color: Colors.white70),
                          ),
                        );
                      }

                      return GridView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 14,
                          crossAxisSpacing: 14,
                          childAspectRatio: 0.8,
                        ),
                        itemCount: assets.length,
                        itemBuilder: (context, index) {
                          final assetPath = assets[index];

                          return Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF11203E),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFF546AA2), width: 0.7),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    topRight: Radius.circular(10),
                                  ),
                                  child: Image.asset(
                                    assetPath,
                                    height: 140,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _prettyName(assetPath),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          Image.asset('assets/icons/KPcoin.png', width: 16, height: 16),
                                          const SizedBox(width: 6),
                                          const Text(
                                            "—",
                                            style: TextStyle(color: Color(0xFFFFD700), fontSize: 13),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      const Text(
                                        "VIP —",
                                        style: TextStyle(color: Colors.grey, fontSize: 11),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),

                // Bottom bar (kept as-is)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  color: const Color(0xFF1B0C3A),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Image.asset('assets/icons/KPcoin.png', width: 24, height: 24),
                          const SizedBox(width: 8),
                          const Text(
                            "0",
                            style: TextStyle(
                              color: Color(0xFFFFD700),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          _bottomButton("Buy", const Color(0xFFFFD700), const Color(0xFF4B3200)),
                          const SizedBox(width: 10),
                          _bottomButton("Give", const Color(0xFFBB7AF8), const Color(0xFF3A006D)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bottomButton(String text, Color color, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(30)),
      child: Text(
        text,
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14),
      ),
    );
  }
}
