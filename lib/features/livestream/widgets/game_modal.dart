import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../core/services/api/game_service.dart';
import '../../../core/utils/user_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

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
      debugPrint('🌐 Fetching games...');
      final result = await gameService.fetchGames();
      debugPrint('✅ Games fetched: ${result.length}');
      setState(() {
        games = result;
        loading = false;
      });
    } catch (e) {
      debugPrint('❌ Failed to load games: $e');
      setState(() => loading = false);
    }
  }


  void _openGame(Map<String, dynamic> game) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = userProvider.currentUser?.id ?? "guest_user";

    // ✅ Expect play_url already includes query params from backend
    final baseUrl = game['play_url'];
    final url = baseUrl.contains('?')
        ? "$baseUrl&userId=$userId&gameMode=3"
        : "$baseUrl?userId=$userId&gameMode=3";

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            Scaffold(
              appBar: AppBar(
                  title: Text(game['name']),
                  backgroundColor: Colors.white
              ),
              body: WebViewWidget(
                controller: WebViewController()
                  ..setJavaScriptMode(JavaScriptMode.unrestricted)
                  ..loadRequest(Uri.parse(url)),
              ),
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, // <-- solid background
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
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