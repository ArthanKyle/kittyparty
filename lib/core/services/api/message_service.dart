import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class MessageService {
  final String baseUrl;
  late IO.Socket socket;

  MessageService({String? baseUrl})
      : baseUrl = baseUrl ?? dotenv.env['BASE_URL']! {
    _initializeSocket();
  }

  // Connect socket.io client
  void _initializeSocket() {
    socket = IO.io(baseUrl, IO.OptionBuilder()
        .setTransports(['websocket'])
        .disableAutoConnect()
        .build());
    socket.connect();

    socket.onConnect((_) {
      print('Connected to socket server');
    });

    socket.onDisconnect((_) {
      print('Disconnected from socket server');
    });
  }

  // Listen for new messages in real-time
  void onNewMessage(Function(dynamic data) callback) {
    socket.on('new_message', callback);
  }

  // Stop listening
  void offNewMessage() {
    socket.off('new_message');
  }

  // Send message to backend
  Future<Map<String, dynamic>> sendMessage({
    required String conversationId,
    required String senderId,
    required String messageType,
    required String messageContent,
    String? mediaUrl,
  }) async {
    final url = Uri.parse('$baseUrl/api/messages/sent');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "ConversationID": conversationId,
        "SenderID": senderId,
        "MessageType": messageType,
        "MessageContent": messageContent,
        "MediaURL": mediaUrl,
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to send message: ${response.body}');
    }
  }
}
