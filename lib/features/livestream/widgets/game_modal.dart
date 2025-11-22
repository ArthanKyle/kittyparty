import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/api/game_service.dart';
import '../../../core/utils/user_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'game_webview.dart';

class GameListModal extends StatefulWidget {
  const GameListModal({super.key});

  @override
  State<GameListModal> createState() => _GameListModalState();
}

class _GameListModalState extends State<GameListModal> {
  final gameService = GameService();
  List<Map<String, dynamic>> games = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadGames();
  }

  Future<void> _loadGames() async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final userId = userProvider.currentUser?.userIdentification ?? "guest_user";

      final result = await gameService.fetchGames(userId);

      setState(() {
        games = result;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
    }
  }


  void _openGame(Map<String, dynamic> game) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = userProvider.currentUser?.userIdentification ?? "guest_user";

    final baseUrl = game['play_url'];

    // You can keep adding it to the URL if the game needs it there too
    final url = baseUrl.contains('?')
        ? "$baseUrl&user_id=$userId&gameMode=3"
        : "$baseUrl?user_id=$userId&gameMode=3";

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GameWebView(
          url: url,
          gameName: game['name'],
          userId: userId, // <--- PASS IT HERE
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding: const EdgeInsets.all(16),
      height: MediaQuery
          .of(context)
          .size
          .height * 0.7,
      child: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: games.length,
        itemBuilder: (_, i) {
          final g = games[i];
          return ListTile(
            leading: CachedNetworkImage(
              imageUrl: g['icon'],
              width: 50,
              height: 50,
              placeholder: (_, __) => const CircularProgressIndicator(strokeWidth: 1.5),
              errorWidget: (_, __, ___) => const Icon(Icons.videogame_asset),
            ),
            title: Text(g['name']),
            subtitle: Text("v${g['version']}"),
            onTap: () => _openGame(g),
          );
        },
      ),
    );
  }
}