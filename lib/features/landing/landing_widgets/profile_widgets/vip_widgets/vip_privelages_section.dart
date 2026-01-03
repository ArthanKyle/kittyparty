import 'package:flutter/material.dart';

class VipPrivilegesSection extends StatelessWidget {
  const VipPrivilegesSection({super.key});

  @override
  Widget build(BuildContext context) {
    // 3 columns × 2 rows (like screenshot)
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: GridView.count(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 8,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: const [
          VipPrivilegeItem(
            icon: Icons.visibility_off_rounded,
            label: 'Private Browsing',
          ),
          VipPrivilegeItem(
            icon: Icons.workspace_premium_rounded,
            label: 'VIP Logo',
            active: true,
          ),
          VipPrivilegeItem(
            icon: Icons.person_search_rounded,
            label: 'View Visitors',
          ),
          VipPrivilegeItem(
            icon: Icons.account_circle_rounded,
            label: 'Only Headdress',
          ),
          VipPrivilegeItem(
            icon: Icons.card_giftcard_rounded,
            label: 'Nobles Gift',
            disabled: true,
          ),
          VipPrivilegeItem(
            icon: Icons.badge_rounded,
            label: 'Only Nameplate',
          ),
        ],
      ),
    );
  }
}

class VipPrivilegeItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final bool disabled;

  const VipPrivilegeItem({
    super.key,
    required this.icon,
    required this.label,
    this.active = false,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final baseColor = const Color(0xFFE7D6A5);
    final iconColor = disabled
        ? baseColor.withOpacity(0.22)
        : active
        ? const Color(0xFFFFE6A6)
        : baseColor.withOpacity(0.55);

    final textColor = disabled
        ? baseColor.withOpacity(0.18)
        : active
        ? const Color(0xFFFFE6A6)
        : baseColor.withOpacity(0.45);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          height: 44,
          width: 44,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: disabled
                  ? const Color(0xFFE7D6A5).withOpacity(0.08)
                  : const Color(0xFFE7D6A5).withOpacity(0.18),
            ),
          ),
          child: Icon(icon, color: iconColor, size: 26),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: textColor,
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
