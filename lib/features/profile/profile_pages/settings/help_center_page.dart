import 'package:flutter/material.dart';

class HelpCenterPage extends StatefulWidget {
  const HelpCenterPage({super.key});

  @override
  State<HelpCenterPage> createState() => _HelpCenterPageState();
}

class _HelpCenterPageState extends State<HelpCenterPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Help Center')),
      body: Column(
        children: [
          ListTile(
            onTap: () => {},
            title: Text('Cancel Account'),
            trailing: Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }
}
