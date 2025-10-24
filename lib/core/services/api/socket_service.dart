import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  late IO.Socket socket;
  Function(int)? _onCoinsUpdated;
  Function()? _onBonusHidden;

  void initSocket(String userId, Function(int) onCoinsUpdated, {Function()? onBonusHidden}) {
    _onCoinsUpdated = onCoinsUpdated;
    _onBonusHidden = onBonusHidden;

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

    socket.on('coin_update', (data) {
      final coins = data['coins'] as int?;
      if (coins != null) _onCoinsUpdated?.call(coins);
    });

    socket.on('bonus_hidden', (_) {
      _onBonusHidden?.call();
    });
  }

  void dispose() {
    socket.dispose();
  }
}
