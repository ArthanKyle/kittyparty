import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import '../../../core/services/api/game_service.dart';
import 'game_webview.dart';

class GameListModal extends StatefulWidget {
  const GameListModal({super.key});

  @override
  State<GameListModal> createState() => _GameListModalState();
}

class _GameListModalState extends State<GameListModal> {
  final GameService _gameService = GameService(); // ✅ Create instance

  List<Map<String, dynamic>> games = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _fetchGames();
  }

  Future<void> _fetchGames() async {
    try {
      final fetchedGames = await _gameService.fetchGames(); // ✅ Use instance
      setState(() {
        games = fetchedGames;
        loading = false;
      });
    } catch (e) {
      print('❌ Failed to fetch games: $e');
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.7,
      child: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: games.length,
        itemBuilder: (_, i) {
          final g = games[i];
          return ListTile(
            leading: Image.network(g["preview_url"], width: 50, height: 50, fit: BoxFit.cover),
            title: Text(g["name"], style: const TextStyle(color: Colors.white)),
            subtitle: Text("Version: ${g["game_version"]}", style: const TextStyle(color: Colors.grey)),
            trailing: const Icon(Icons.play_arrow, color: Colors.white),
            onTap: () => _openGame(context, g["download_url"]),
          );
        },
      ),
    );
  }

  void _openGame(BuildContext context, String url) {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => GameWebView(url: url)),
    );
  }
}
