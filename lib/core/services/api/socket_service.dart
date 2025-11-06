import 'dart:async';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  late IO.Socket socket;

  // StreamControllers for real-time updates
  final _coinsController = StreamController<int>.broadcast();
  final _diamondsController = StreamController<int>.broadcast();

  Stream<int> get coinsStream => _coinsController.stream;
  Stream<int> get diamondsStream => _diamondsController.stream;

  void initSocket(String userId) {
    final baseUrl = dotenv.env['BASE_URL']!.replaceAll('/api', '');

    socket = IO.io(
      baseUrl,
      <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': true,
        'reconnection': true,
      },
    );

    socket.onConnect((_) {
      print('✅ Socket connected');
      socket.emit('joinRoom', userId);
    });

    socket.onReconnect((_) {
      print('🔁 Socket reconnected');
      socket.emit('joinRoom', userId);
    });

    socket.onDisconnect((_) => print('❌ Socket disconnected'));

    // Coins only
    socket.on('coin_update', (data) {
      final coins = data['coins'] as int?;
      if (coins != null) _coinsController.add(coins);
    });

    // 🔹 Diamonds + Coins (from wallet_update)
    socket.on('wallet_update', (data) {
      final coins = data['coins'] as int?;
      final diamonds = data['diamonds'] as int?;

      if (coins != null) _coinsController.add(coins);
      if (diamonds != null) _diamondsController.add(diamonds);
    });

    socket.on('bonus_hidden', (_) {
      print('🎁 Bonus hidden event received');
    });
  }

  void dispose() {
    socket.dispose();
    _coinsController.close();
    _diamondsController.close();
  }
}
