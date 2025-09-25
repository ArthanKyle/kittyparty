import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SocketService {
  late IO.Socket socket;
  late String _userId;
  Function(int)? _onCoinsUpdated;

  void initSocket(String userId, Function(int) onCoinsUpdated) {
    _userId = userId;
    _onCoinsUpdated = onCoinsUpdated;

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
      _joinRoom();
    });

    socket.onReconnect((_) {
      print('🔁 Reconnected, joining room again');
      _joinRoom();
    });

    socket.onDisconnect((_) => print('❌ Socket disconnected'));

    socket.on('coin_update', (data) {
      if (data['coins'] != null) {
        final coins = data['coins'] as int;
        print('💰 Coins updated: $coins');
        _onCoinsUpdated?.call(coins);
      }
    });
  }

  void _joinRoom() {
    socket.emit('joinRoom', _userId);
    print('🔹 Joined room: $_userId');
  }

  void dispose() {
    socket.disconnect();
  }
}
