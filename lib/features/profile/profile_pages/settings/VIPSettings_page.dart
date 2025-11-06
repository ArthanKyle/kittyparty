import 'package:flutter/material.dart';

class VIPSettingsPage extends StatefulWidget {
  const VIPSettingsPage({Key? key}) : super(key: key);

  @override
  State<VIPSettingsPage> createState() => _VIPSettingsPageState();
}

class _VIPSettingsPageState extends State<VIPSettingsPage> {
  final Map<String, bool> _vipToggles = {
    "Not being Followed": false,
    "Anti-Entering Room": false,
    "Private Browsing": false,
    "Do Not Disturb": false,
    "Invisibility": false,
    "Anti-Kick": false,
  };

  final Map<String, List<String>> _vipLevels = {
    "Not being Followed": ["VIP5", "VIP6", "VIP7", "VIP8", "VIP9"],
    "Anti-Entering Room": ["VIP6", "VIP7", "VIP8", "VIP9"],
    "Private Browsing": ["VIP6", "VIP7", "VIP8", "VIP9"],
    "Do Not Disturb": ["VIP7", "VIP8", "VIP9"],
    "Invisibility": ["VIP7", "VIP8", "VIP9"],
    "Anti-Kick": ["VIP8", "VIP9"],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F6FB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'VIP Setting',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text(
              "VIP Privilege",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
          ..._vipToggles.keys.map((key) => _buildVipTile(key)).toList(),
        ],
      ),
    );
  }

  Widget _buildVipTile(String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: _vipLevels[title]!
                      .map((vip) => _vipBadge(vip))
                      .toList(),
                ),
                const SizedBox(height: 6),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _vipToggles[title]!,
            activeColor: Colors.white,
            activeTrackColor: const Color(0xFFFFB84C),
            inactiveTrackColor: Colors.grey.shade300,
            onChanged: (value) {
              setState(() => _vipToggles[title] = value);
            },
          ),
        ],
      ),
    );
  }

  Widget _vipBadge(String vip) {
    // Color scheme per VIP level
    Color bgColor;
    switch (vip) {
      case "VIP5":
        bgColor = Colors.blue.shade700;
        break;
      case "VIP6":
        bgColor = Colors.green.shade700;
        break;
      case "VIP7":
        bgColor = Colors.purple.shade700;
        break;
      case "VIP8":
        bgColor = const Color(0xFFB76E00); // gold tone
        break;
      case "VIP9":
        bgColor = Colors.red.shade800;
        break;
      default:
        bgColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Text(
        vip,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}
