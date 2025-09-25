import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class TopUpStream {
  final _topUpController = StreamController<Map>.broadcast();
  final _coinController = StreamController<Map>.broadcast();

  Stream<Map> get topUps => _topUpController.stream;
  Stream<Map> get coins => _coinController.stream;

  void attachSocket(IO.Socket socket) {
    socket.on("topup_update", (data) => _topUpController.add(Map<String, dynamic>.from(data)));
    socket.on("coin_update", (data) => _coinController.add(Map<String, dynamic>.from(data)));
  }
}
