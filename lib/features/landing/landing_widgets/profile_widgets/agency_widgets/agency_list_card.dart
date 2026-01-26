import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kittyparty/core/constants/colors.dart';

class AgencyListCard extends StatelessWidget {
  final String name;
  final String agencyCode;
  final int members;
  final int maxMembers;
  final List<dynamic> media;
  final VoidCallback onTap;

  final bool hasPendingRequest;

  final String? waveAsset;
  final double waveOpacity;

  const AgencyListCard({
    super.key,
    required this.name,
    required this.agencyCode,
    required this.members,
    required this.maxMembers,
    required this.media,
    required this.onTap,
    required this.hasPendingRequest,
    this.waveAsset,
    this.waveOpacity = 0.35,
  });

  bool get isFull => members >= maxMembers;

  @override
  Widget build(BuildContext context) {
    final base = dotenv.env['BASE_URL'] ?? "";

    String? imageUrl;
    if (media.isNotEmpty && media.first is Map<String, dynamic>) {
      final id = media.first['id']?.toString();
      if (id != null && id.isNotEmpty) {
        imageUrl = "$base/media/$id";
      }
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Stack(
        children: [
          /// BASE CARD (YOUR ORIGINAL DESIGN)
          Container(
            height: 90,
            color: Colors.black,
            child: Row(
              children: [
                const SizedBox(width: 12),

                /// AVATAR
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey.shade900,
                    image: imageUrl != null
                        ? DecorationImage(
                      image: NetworkImage(imageUrl),
                      fit: BoxFit.cover,
                    )
                        : null,
                  ),
                  child: imageUrl == null
                      ? Center(
                    child: Text(
                      name.isNotEmpty
                          ? name[0].toUpperCase()
                          : "A",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                      : null,
                ),

                const SizedBox(width: 12),

                /// INFO
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Agent ID: $agencyCode',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$members / $maxMembers',
                        style: TextStyle(
                          color:
                          isFull ? Colors.redAccent : Colors.amber,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                /// ACTION BUTTON
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: _buildActionButton(),
                ),
              ],
            ),
          ),

          /// 🌊 GOLD WAVE ACCENT (BOTTOM OVERLAY)
          if (waveAsset != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 22,
              child: IgnorePointer(
                child: Opacity(
                  opacity: waveOpacity,
                  child: Image.asset(
                    waveAsset!,
                    fit: BoxFit.cover,
                    alignment: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// =========================
  /// BUTTON STATES
  /// =========================
  Widget _buildActionButton() {
    if (isFull) {
      return _pill(
        text: 'Full',
        background: Colors.grey.shade800,
        textColor: Colors.white54,
      );
    }

    if (hasPendingRequest) {
      return _pill(
        text: 'Pending',
        background: Colors.grey.shade700,
        textColor: Colors.white70,
      );
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: AppColors.goldShineGradient),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text(
          'Join',
          style: TextStyle(
            color: Colors.black,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _pill({
    required String text,
    required Color background,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
