import 'package:flutter/material.dart';

class MallPage extends StatefulWidget {
  const MallPage({super.key});

  @override
  State<MallPage> createState() => _MallPageState();
}

class _MallPageState extends State<MallPage> {
  int selectedIndex = 0;

  final List<Map<String, dynamic>> categories = [
    {'icon': 'assets/icons/item/Mount.png', 'label': 'Mount'},
    {'icon': 'assets/icons/item/Avatar.png', 'label': 'Avatar'},
    {'icon': 'assets/icons/item/Nameplate.png', 'label': 'Nameplate'},
    {'icon': 'assets/icons/item/Profile_card.png', 'label': 'Profile Card'},
    {'icon': 'assets/icons/item/Chat_bubble.png', 'label': 'Chat Bubble'},
  ];

  final List<Map<String, dynamic>> products = [
    {
      'image': 'assets/image/Mall_Image.jpg',
      'title': 'The Lion and War',
      'price': '30K/3D',
      'vip': 'VIP5-95%',
      'limited': true,
    },
    {
      'image': 'assets/image/Mall_Image.jpg',
      'title': "Lion's Charge",
      'price': '20K/3D',
      'vip': 'VIP5-95%',
      'limited': false,
    },
    {
      'image': 'assets/image/Mall_Image.jpg',
      'title': 'Lion and Princess',
      'price': '33K/3D',
      'vip': 'VIP5-95%',
      'limited': true,
    },
    {
      'image': 'assets/image/Mall_Image.jpg',
      'title': 'Lion Rush',
      'price': '21K/3D',
      'vip': 'VIP5-95%',
      'limited': false,
    },
    {
      'image': 'assets/image/Mall_Image.jpg',
      'title': 'Blue Wolf',
      'price': '30K/3D',
      'vip': 'VIP5-95%',
      'limited': true,
    },
    {
      'image': 'assets/image/Mall_Image.jpg',
      'title': 'Space Gate',
      'price': '28K/3D',
      'vip': 'VIP5-95%',
      'limited': false,
    },
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔹 Top Bar
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios,
                            color: Colors.white, size: 18),
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
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6526A8),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: const [
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

                // 🏷️ Categories
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
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF2A144A)
                                : const Color(0xFF1B2440),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFFFFD700)
                                  : Colors.transparent,
                              width: 1.2,
                            ),
                          ),
                          child: Column(
                            children: [
                              Image.asset(
                                cat['icon'],
                                width: 35,
                                height: 35,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                cat['label'],
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

                const SizedBox(height: 20),

                // 🦁 Product Grid
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];

                      return Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF11203E),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color(0xFF546AA2),
                            width: 0.7,
                          ),
                        ),
                        child: Stack(
                          children: [
                            // Product Content
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    topRight: Radius.circular(10),
                                  ),
                                  child: Image.asset(
                                    product['image'],
                                    height: 100,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product['title'],
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Image.asset(
                                            'assets/icons/KPcoin.png',
                                            width: 16,
                                            height: 16,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            product['price'],
                                            style: const TextStyle(
                                              color: Color(0xFFFFD700),
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        product['vip'],
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            // 🏷️ Limited Tag
                            if (product['limited'])
                              Positioned(
                                top: 6,
                                left: 6,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFC107),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    "Limited",
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // 💰 Bottom Bar
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  color: const Color(0xFF1B0C3A),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Image.asset(
                            'assets/icons/KPcoin.png',
                            width: 24,
                            height: 24,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            "30000/3D",
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
                          _bottomButton("Buy", const Color(0xFFFFD700),
                              const Color(0xFF4B3200)),
                          const SizedBox(width: 10),
                          _bottomButton("Give", const Color(0xFFBB7AF8),
                              const Color(0xFF3A006D)),
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
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }
}
