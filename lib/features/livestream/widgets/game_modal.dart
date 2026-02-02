import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/services/api/game_service.dart';
import '../../../core/utils/user_provider.dart';
import '../../../core/config/game_config.dart';
import 'game_webview.dart';

class GameListModal extends StatefulWidget {
  final String roomId;

  const GameListModal({
    super.key,
    required this.roomId,
  });

  @override
  State<GameListModal> createState() => _GameListModalState();
}

class _GameListModalState extends State<GameListModal> {
  final gameService = GameService();
  List<Map<String, dynamic>> games = [];
  bool loading = true;

  GameConfigModel? gameConfigModel;

  @override
  void initState() {
    super.initState();
    _loadGames();
  }

  Future<void> _loadGames() async {
    try {
      final userProvider = context.read<UserProvider>();
      final userId =
          userProvider.currentUser?.userIdentification ?? 'guest_user';
      final user = context.read<UserProvider>().currentUser!;

      gameConfigModel = await gameService.getGameConfig(int.parse(userId), widget.roomId,user.userIdentification, );

      final result = await gameService.fetchGames(userId);

      if (!mounted) return;

      setState(() {
        games = result;
        loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => loading = false);
    }
  }

  void _openGame(Map<String, dynamic> game) {
    if (gameConfigModel == null) return;

    final num? sh = game['safeHeight'] as num?;
    final double safeHeight = sh?.toDouble() ?? 150000;


    final user = context.read<UserProvider>().currentUser!;

    // final config = GameConfigModel(
    //   userId: user.userIdentification,
    //   roomId: widget.roomId,
    // );
    print("=========game config======");
    print(gameConfigModel!.toJson());

    ShowGameUrl(
      context,
      game['play_url'],// game url...
      gameConfigModel!,
      safeHeight,

    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.5,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: games.length,
        itemBuilder: (_, i) {
          final g = games[i];

          return ListTile(
            leading: CachedNetworkImage(
              imageUrl: g['icon'],
              width: 48,
              height: 48,
              fit: BoxFit.cover,
              placeholder: (_, __) =>
              const CircularProgressIndicator(strokeWidth: 1.5),
              errorWidget: (_, __, ___) =>
              const Icon(Icons.videogame_asset),
            ),
            title: Text(g['name']),
            subtitle: Text('v${g['version']}'),
            onTap: () => _openGame(g),
          );
        },
      ),
    );
  }
}
