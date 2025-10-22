import 'package:flutter/material.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Setting',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      backgroundColor: const Color(0xfff8f8f8),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          _buildGroup([
            _buildItem('Change Email', trailingText: 'arthankyle.ydeo@gmail.com'),
            _buildItem('Bind Phone Number'),
            _buildItem('Reset password'),
            _buildItem('Payment Password', trailingText: 'Modify'),
          ]),
          _buildGroup([
            _buildItem('VIP Setting'),
            _buildItem('Notification Setting'),
            _buildItem('Language'),
          ]),
          _buildGroup([
            _buildItem('Shield Manager'),
            _buildItem('Blacklist Management'),
          ]),
          _buildGroup([
            _buildItem('Personal Information and Permissions'),
            _buildItem('Help'),
            _buildItem('Clear Cache'),
            _buildItem('About MoliParty'),
          ]),
        ],
      ),
    );
  }

  Widget _buildGroup(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: List.generate(children.length, (index) {
          return Column(
            children: [
              children[index],
              if (index != children.length - 1)
                const Divider(height: 1, thickness: 0.5, indent: 16, endIndent: 16),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildItem(String title, {String? trailingText}) {
    return ListTile(
      title: Text(title, style: const TextStyle(fontSize: 16)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingText != null)
            Text(
              trailingText,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
      onTap: () {},
      visualDensity: const VisualDensity(vertical: -2),
    );
  }
}
