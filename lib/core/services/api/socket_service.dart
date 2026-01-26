import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  late IO.Socket socket;

  /// ==============================
  /// Wallet streams (authoritative)
  /// ==============================
  final StreamController<int> _coinsController =
  StreamController<int>.broadcast();
  final StreamController<int> _diamondsController =
  StreamController<int>.broadcast();

  Stream<int> get coinsStream => _coinsController.stream;
  Stream<int> get diamondsStream => _diamondsController.stream;

  /// ==============================
  /// Social streams
  /// ==============================
  final StreamController<Map<String, dynamic>> _likeStreamController =
  StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _commentStreamController =
  StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get likeStream =>
      _likeStreamController.stream;
  Stream<Map<String, dynamic>> get commentStream =>
      _commentStreamController.stream;

  bool _initialized = false;

  /// ==============================
  /// Init socket (JOIN USING UserIdentification)
  /// ==============================
  void initSocket(String userIdentification) {
    if (_initialized) {
      debugPrint('⚠️ Socket already initialized');
      return;
    }
    _initialized = true;

    final baseUrl = dotenv.env['BASE_URL']!.replaceAll('/api', '');

    debugPrint('🔌 Initializing socket → $baseUrl');
    debugPrint('🧩 Joining room → $userIdentification');

    socket = IO.io(
      baseUrl,
      <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': true,
        'reconnection': true,
        'reconnectionAttempts': 10,
        'reconnectionDelay': 1000,
      },
    );

    /// ------------------------------
    /// Connection lifecycle
    /// ------------------------------
    socket.onConnect((_) {
      debugPrint('✅ Socket connected');
      socket.emit('joinRoom', userIdentification);
    });

    socket.onReconnect((_) {
      debugPrint('🔁 Socket reconnected');
      socket.emit('joinRoom', userIdentification);
    });

    socket.onDisconnect((_) {
      debugPrint('❌ Socket disconnected');
    });

    socket.onConnectError((err) {
      debugPrint('🚫 Socket connect error: $err');
    });

    socket.onError((err) {
      debugPrint('🚫 Socket error: $err');
    });

    /// ------------------------------
    /// Wallet updates (CRITICAL)
    /// ------------------------------
    socket.on('wallet_update', (data) {
      if (data is! Map) {
        debugPrint('⚠️ wallet_update invalid payload: $data');
        return;
      }

      final coins = (data['coins'] as num?)?.toInt() ?? 0;
      final diamonds = (data['diamonds'] as num?)?.toInt() ?? 0;

      debugPrint(
        '💼 Wallet socket update → coins=$coins diamonds=$diamonds',
      );

      _coinsController.add(coins);
      _diamondsController.add(diamonds);
    });

    /// ------------------------------
    /// Social events
    /// ------------------------------
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

    /// ------------------------------
    /// Misc events
    /// ------------------------------
    socket.on('bonus_hidden', (_) {
      debugPrint('🎁 Bonus hidden event received');
    });
  }

  /// ==============================
  /// Dispose safely
  /// ==============================
  void dispose() {
    debugPrint('🧹 Disposing SocketService');

    if (socket.connected) {
      socket.disconnect();
    }

    socket.dispose();
    _coinsController.close();
    _diamondsController.close();
    _likeStreamController.close();
    _commentStreamController.close();

    _initialized = false;
  }
}
