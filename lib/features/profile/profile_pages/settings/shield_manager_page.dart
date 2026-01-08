import 'package:flutter/material.dart';

class ShieldManagerPage extends StatefulWidget {
  const ShieldManagerPage({super.key});

  @override
  State<ShieldManagerPage> createState() => _ShieldManagerPageState();
}

class _ShieldManagerPageState extends State<ShieldManagerPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Shield Manager')),
      body: Column(children: [_emptyShieldWidget()]),
    );
  }

  Center _emptyShieldWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inbox_outlined, size: 80, color: Colors.grey),
          Text(
            'Coming soon!',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
