import 'package:flutter/material.dart';

class ItemPage extends StatefulWidget {
  const ItemPage({super.key});

  @override
  State<ItemPage> createState() => _ItemPageState();
}

class _ItemPageState extends State<ItemPage> {
  int selectedIndex = 0;

  final List<Map<String, dynamic>> items = [
    {'icon': 'assets/icons/item/Mount.png', 'label': 'Mount'},
    {'icon': 'assets/icons/item/Avatar.png', 'label': 'Avatar'},
    {'icon': 'assets/icons/item/Nameplate.png', 'label': 'Nameplate'},
    {'icon': 'assets/icons/item/Profile_card.png', 'label': 'Profile Card'},
    {'icon': 'assets/icons/item/Chat_bubble.png', 'label': 'Chat Bubble'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C1225),
      body: Stack(
        children: [
          // 🌌 Gradient background
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
              children: [
                // 🔹 Top bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 18),
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

                // 🧑 Profile image
                const CircleAvatar(
                  radius: 40,
                  backgroundImage: AssetImage('assets/image/profile.png'),
                ),

                const SizedBox(height: 20),

                // 🏷️ Item categories
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: List.generate(items.length, (index) {
                      final item = items[index];
                      final bool isSelected = index == selectedIndex;

                      return GestureDetector(
                        onTap: () {
                          setState(() => selectedIndex = index);
                        },
                        child: Container(
                          margin: const EdgeInsets.only(right: 10),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF2A144A)
                                : const Color(0xFF1B2440),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              // 🟣 Icon without border or gradient
                              Image.asset(
                                item['icon'],
                                width: 45,
                                height: 45,
                                fit: BoxFit.contain,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                item['label'],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ),

                const SizedBox(height: 40),

                // 🚫 Not used card (no gold border)
                Container(
                  width: 120,
                  height: 140,
                  decoration: BoxDecoration(
                    color: const Color(0xFF251B4B),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.block, size: 40, color: Colors.white70),
                      SizedBox(height: 10),
                      Text(
                        "Not used",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
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
}
