// lib/features/social/widgets/friend_picker_sheet.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../core/services/api/social_service.dart';
import '../../../../../core/utils/profile_picture_helper.dart';
import '../../../../../core/utils/user_provider.dart';
import '../../../model/friend_user.dart';

class FriendPickerSheet extends StatefulWidget {
  final String currentUserId;
  final void Function(FriendUser friend) onSelected;

  const FriendPickerSheet({
    super.key,
    required this.currentUserId,
    required this.onSelected,
  });

  @override
  State<FriendPickerSheet> createState() => _FriendPickerSheetState();
}

class _FriendPickerSheetState extends State<FriendPickerSheet> {
  final _service = SocialService();
  List<FriendUser> friends = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    friends = await _service.fetchFriends(widget.currentUserId);
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.read<UserProvider>();

    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFF1B0C3A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // grab handle
          const Center(
            child: SizedBox(
              width: 40,
              height: 4,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          const Text(
            "Select Friend",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          if (loading)
            const Expanded(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (friends.isEmpty)
            const Expanded(
              child: Center(
                child: Text(
                  "No friends available",
                  style: TextStyle(color: Colors.white54),
                ),
              ),
            )
          else
            Expanded(
              child: ListView.separated(
                itemCount: friends.length,
                separatorBuilder: (_, __) =>
                const Divider(color: Colors.white12),
                itemBuilder: (_, i) {
                  final f = friends[i];
                  final displayName =
                      f.username ?? f.fullName ?? f.userIdentification;

                  return ListTile(
                    onTap: () {
                      Navigator.pop(context);
                      widget.onSelected(f);
                    },

                    // ✅ REAL AVATAR (your helper)
                    leading: UserAvatarHelper.circleAvatar(
                      userIdentification: f.userIdentification,
                      displayName: displayName,
                      localBytes: null, // not me
                      radius: 20,
                      frameAsset: null,
                    ),

                    title: Text(
                      displayName,
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      "ID: ${f.userIdentification}",
                      style: const TextStyle(color: Colors.white38),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
