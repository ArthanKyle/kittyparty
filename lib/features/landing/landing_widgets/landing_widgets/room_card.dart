import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../model/room.dart';

class RoomCard extends StatelessWidget {
  final Room room;
  final VoidCallback? onTap;

  const RoomCard({
    required this.room,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 7),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 2),
            )
          ],
        ),
        child: Row(
          children: [

            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: (room.hostProfilePic != null &&
                  room.hostProfilePic!.isNotEmpty)
                  ? Image.network(
                room.hostProfilePic!,
                width: 56,
                height: 56,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _fallbackAvatar(),
              )
                  : _fallbackAvatar(),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          room.roomName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.rocket_launch_rounded,
                          size: 20, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        room.participantsCount.toString(),
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (room.roomName.isNotEmpty)
                    Text(
                      room.roomName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: Colors.black54, fontSize: 13),
                    ),
                  const SizedBox(height: 6),
                  SizedBox(
                    height: 22,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: room.participantsCount.clamp(0, 10), // show up to 10
                      separatorBuilder: (_, __) =>
                      const SizedBox(width: 4),
                      itemBuilder: (_, i) => CircleAvatar(
                        radius: 11,
                        backgroundColor: Colors.grey.shade200,
                        child: Text(
                          '💠',
                          style: TextStyle(
                              fontSize: 12, color: Colors.blue[700]),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fallbackAvatar() {
    return Container(
      width: 56,
      height: 56,
      color: AppColors.accentWhite,
      alignment: Alignment.center,
      child: const Icon(Icons.image_not_supported_outlined),
    );
  }
}
