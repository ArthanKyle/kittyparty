import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SocketService {
  late IO.Socket socket;

  void initSocket(String userId) {
    final baseUrl = dotenv.env['BASE_URL']!.replaceAll('/api', '');
    socket = IO.io(baseUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });

    socket.connect();
    socket.onConnect((_) {
      print('✅ Connected to socket');
      socket.emit('joinRoom', userId);
    });
  }

  void listenToCoins(Function(int) onCoinsUpdated) {
    socket.on('coin_update', (data) {
      final coins = data['coins'] as int;
      print('💰 Coins updated: $coins');
      onCoinsUpdated(coins);
    });
  }

  void dispose() {
    socket.disconnect();
  }
}
