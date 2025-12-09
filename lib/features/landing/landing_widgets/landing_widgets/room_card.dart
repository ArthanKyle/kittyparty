import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/services/api/userProfile_service.dart';
import '../../model/room.dart';
import '../../../landing/model/userProfile.dart';
import '../../../landing/viewmodel/profile_viewmodel.dart';

class RoomCard extends StatefulWidget {
  final Room room;
  final VoidCallback? onTap;

  const RoomCard({
    required this.room,
    this.onTap,
    super.key,
  });

  @override
  State<RoomCard> createState() => _RoomCardState();
}

class _RoomCardState extends State<RoomCard> {
  String? profilePicUrl;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    profilePicUrl = widget.room.hostProfilePic;
    _fetchHostProfileIfNeeded();
  }

  Future<void> _fetchHostProfileIfNeeded() async {
    if (profilePicUrl != null && profilePicUrl!.isNotEmpty) return;

    setState(() => isLoading = true);

    try {
      final service = UserProfileService();

      final profile = await service.getProfileByUserIdentification(
        widget.room.hostId,
      );

      if (!mounted) return;

      if (profile != null && profile.profilePicture != null) {
        setState(() {
          profilePicUrl =
          "${service.baseUrl}/userprofiles/${widget.room.hostId}/profile-picture";
        });
      }
    } catch (e) {
      debugPrint("⚠️ Failed to fetch host profile picture: $e");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
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
              child: _buildProfileImage(),
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
                          widget.room.roomName,
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
                        widget.room.participantsCount.toString(),
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (widget.room.roomName.isNotEmpty)
                    Text(
                      widget.room.roomName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 13,
                      ),
                    ),
                  const SizedBox(height: 6),
                  SizedBox(
                    height: 22,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: widget.room.participantsCount.clamp(0, 20),
                      separatorBuilder: (_, __) => const SizedBox(width: 4),
                      itemBuilder: (_, i) => CircleAvatar(
                        radius: 11,
                        backgroundColor: Colors.grey.shade200,
                        child: Text(
                          '💠',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue[700],
                          ),
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

  Widget _buildProfileImage() {
    if (isLoading) {
      return Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }

    if (profilePicUrl != null && profilePicUrl!.isNotEmpty) {
      return Image.network(
        profilePicUrl!,
        width: 56,
        height: 56,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _fallbackAvatar(),
      );
    }

    return _fallbackAvatar();
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
