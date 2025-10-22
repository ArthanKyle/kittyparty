import 'package:flutter/material.dart';

class DailyTaskPage extends StatefulWidget {
  const DailyTaskPage({super.key});

  @override
  State<DailyTaskPage> createState() => _DailyTaskPageState();
}

class _DailyTaskPageState extends State<DailyTaskPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7E5),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header with gift box and title
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFFFE4A0), Color(0xFFFFF0D1)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Image.asset('assets/image/gift-box.png', height: 48),
                            const SizedBox(width: 8),
                            const Text(
                              '100',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                            ),
                          ],
                        ),
                        Image.asset('assets/image/gift-box.png', height: 48),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Task Center',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.brown,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      onPressed: () {},
                      child: const Text(
                        'Sign in now',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),

              // Tab navigation (Daily, Weekly, Agent)
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _tabButton('Daily Tasks', true),
                    _tabButton('Weekly Tasks', false),
                    _tabButton('Agent Tasks', false),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Task Cards
              _taskCard(
                icon: Icons.check_circle_outline,
                color: Colors.green,
                title: 'Sign in daily',
                reward: '+5 M',
              ),
              _taskCard(
                icon: Icons.home_outlined,
                color: Colors.pinkAccent,
                title: 'Room coins income',
                reward: '+8000 M',
                progress: 0.8,
                subtitle: 'Daily room coins income',
              ),
              _taskCard(
                icon: Icons.videogame_asset_outlined,
                color: Colors.blueAccent,
                title: 'Play games (0/3)',
                reward: '+1000',
              ),
              _taskCard(
                icon: Icons.attach_money,
                color: Colors.orangeAccent,
                title: 'Recharge (0/7000) Coins',
                reward: '+100 M',
              ),
              _taskCard(
                icon: Icons.attach_money,
                color: Colors.orange,
                title: 'Recharge (0/35000) Coins',
                reward: '+500 M +500',
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tabButton(String text, bool active) {
    return Column(
      children: [
        Text(
          text,
          style: TextStyle(
            color: active ? Colors.orange : Colors.grey,
            fontWeight: active ? FontWeight.bold : FontWeight.normal,
            fontSize: 15,
          ),
        ),
        if (active)
          Container(
            margin: const EdgeInsets.only(top: 4),
            height: 3,
            width: 60,
            decoration: BoxDecoration(
              color: Colors.orange,
              borderRadius: BorderRadius.circular(3),
            ),
          )
      ],
    );
  }

  Widget _taskCard({
    required IconData icon,
    required Color color,
    required String title,
    String? subtitle,
    required String reward,
    double progress = 0,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.15),
            radius: 24,
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15)),
                if (subtitle != null)
                  Text(subtitle,
                      style:
                          const TextStyle(color: Colors.grey, fontSize: 13)),
                if (progress > 0)
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    height: 6,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: FractionallySizedBox(
                      widthFactor: progress,
                      alignment: Alignment.centerLeft,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            reward,
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.orange),
          ),
        ],
      ),
    );
  }
}
