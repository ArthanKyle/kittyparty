import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kittyparty/features/landing/landing_widgets/landing_widgets/room_card.dart';
import 'package:kittyparty/features/livestream/view/live_audio_room.dart';
import 'package:kittyparty/core/services/api/room_service.dart';
import 'package:kittyparty/core/utils/user_provider.dart';
import '../../viewmodel/recommend_tab_viewmodel.dart';
import 'banner_carousel.dart';
import 'mode_card.dart';

class RecommendTab extends StatelessWidget {
  const RecommendTab({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final userId = userProvider.currentUser?.userIdentification;

    return ChangeNotifierProvider(
      create: (_) => RecommendViewModel(RoomService())..fetchRooms(userId),
      child: Consumer<RecommendViewModel>(
        builder: (context, vm, _) {
          if (vm.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Expanded(
                      child: ModeCard(
                        title: 'CLASSIC',
                        height: 110,
                        gradient: [Color(0xFFFF6B6B), Color(0xFFFF3B3B)],
                        icon: Icons.sports_esports_rounded,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: ModeCard(
                        title: 'QUICK',
                        height: 110,
                        gradient: [Color(0xFF6B9EFF), Color(0xFF3B82F6)],
                        icon: Icons.bolt_rounded,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                Row(
                  children: const [
                    Expanded(
                      child: ModeCard(
                        title: 'RANKING',
                        height: 86,
                        gradient: [Color(0xFFFDBA74), Color(0xFFF59E0B)],
                        icon: Icons.emoji_events_rounded,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: ModeCard(
                        title: 'EVENT CENTER',
                        height: 86,
                        gradient: [Color(0xFFA78BFA), Color(0xFFD946EF)],
                        icon: Icons.campaign_rounded,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                BannerCarousel(),
                const SizedBox(height: 16),

                // Section header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE6F0FA),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.local_fire_department, color: Colors.orange),
                      SizedBox(width: 6),
                      Text(
                        'New',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                if (vm.rooms.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.meeting_room_outlined, size: 48, color: Colors.grey),
                          SizedBox(height: 12),
                          Text(
                            "No active rooms right now",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black54,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Check back later or create your own!",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black45,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Column(
                    children: vm.rooms.map((room) {
                      return RoomCard(
                        room: room,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => LiveAudioRoom(
                                roomId: room.id!,
                                hostId: room.hostId,
                                roomName: room.roomName,
                                userProvider: userProvider, // only this is needed
                              ),
                            ),
                          );
                        },
                      );
                    }).toList(),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
