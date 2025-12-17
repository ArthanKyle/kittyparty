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

  final _likeStreamController = StreamController<Map<String, dynamic>>.broadcast();
  final _commentStreamController = StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get likeStream => _likeStreamController.stream;
  Stream<Map<String, dynamic>> get commentStream => _commentStreamController.stream;

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

    // 🔹 Diamonds + Coins (from wallet_update)
    socket.on('wallet_update', (data) {
      final coins = data['coins'] as int? ?? 0;
      final diamonds = data['diamonds'] as int? ?? 0;

      _coinsController.add(coins);
      _diamondsController.add(diamonds);

      print("💼 Wallet socket update → coins=$coins diamonds=$diamonds");
    });


    socket.on('post_like_update', (data) {
      if (data is Map) {
        _likeStreamController.add({
          'postId': data['postId'],
          'likesCount': data['likesCount'],
        });
      }
    });

    socket.on('post_comment_update', (data) {
      if (data is Map) {
        _commentStreamController.add({
          'postId': data['postId'],
          'commentsCount': data['commentsCount'],
        });
      }
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
