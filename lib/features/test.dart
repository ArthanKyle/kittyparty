import 'package:flutter/material.dart';
import 'livestream/widgets/game_modal.dart'; // adjust import path if different

class Next extends StatefulWidget {
  const Next({super.key});

  @override
  State<Next> createState() => _NextState();
}

class _NextState extends State<Next> {
  @override
  void initState() {
    super.initState();

    // ✅ Automatically show modal after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showGameModal();
    });
  }

  void _showGameModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const GameListModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Test Game List")),
      body: Center(
        child: ElevatedButton(
          onPressed: _showGameModal,
          child: const Text("Open Game List"),
        ),
      ),
    );
  }
}
