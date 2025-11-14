import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GameWebView extends StatefulWidget {
  final String url;
  final String gameName;

  const GameWebView({
    super.key,
    required this.url,
    required this.gameName,
  });

  @override
  State<GameWebView> createState() => _GameWebViewState();
}

class _GameWebViewState extends State<GameWebView> {
  late final WebViewController controller;
  bool isLoading = true;
  bool hasError = false;
  String? errorMessage;

  final String backendUrl = dotenv.env['BACKEND_URL'] ?? "";
  final String baishunAppId = dotenv.env['APP_ID'] ?? "";

  @override
  void initState() {
    super.initState();

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..enableZoom(false)
      ..setBackgroundColor(Colors.black)
      ..addJavaScriptChannel(
        "GameBridge",
        onMessageReceived: (msg) {
          final data = jsonDecode(msg.message);
          final type = data['type'];
          final payload = data['data'];

          switch (type) {
            case 'getConfig':
              _handleGetConfig(payload);
              break;
            case 'gameLoaded':
              break;
            case 'destroy':
              Navigator.pop(context);
              break;
            case 'gameRecharge':
              _handleRecharge(payload);
              break;
          }
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            setState(() {
              isLoading = true;
              hasError = false;
            });
          },
          onPageFinished: (_) async {
            await controller.runJavaScript(_jsProxyCode(backendUrl));
            await controller.runJavaScript(_nativeBridgeCode());
            setState(() => isLoading = false);
          },
          onWebResourceError: (error) {
            setState(() {
              hasError = true;
              isLoading = false;
              errorMessage = error.description;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  String _jsProxyCode(String base) {
    return """
      (function() {
        const backend = "$base";

        const originalFetch = window.fetch;
        window.fetch = function(resource, options) {
          if (typeof resource === 'string' && resource.startsWith('/v1/api/')) {
            resource = backend + resource;
          }
          return originalFetch(resource, options);
        };

        const originalOpen = XMLHttpRequest.prototype.open;
        XMLHttpRequest.prototype.open = function(method, url) {
          if (typeof url === 'string' && url.startsWith('/v1/api/')) {
            arguments[1] = backend + url;
          }
          return originalOpen.apply(this, arguments);
        };
      })();
    """;
  }

  String _nativeBridgeCode() {
    return """
      (function() {
        if (!window.NativeBridge) window.NativeBridge = {};

        function sendToFlutter(type, data) {
          GameBridge.postMessage(JSON.stringify({ type, data }));
        }

        window.NativeBridge.getConfig = function(payload) {
          sendToFlutter('getConfig', payload);
        };

        window.NativeBridge.gameLoaded = function(payload) {
          sendToFlutter('gameLoaded', payload);
        };

        window.NativeBridge.destroy = function(payload) {
          sendToFlutter('destroy', payload);
        };

        window.NativeBridge.gameRecharge = function(payload) {
          sendToFlutter('gameRecharge', payload);
        };
      })();
    """;
  }

  Future<void> _handleGetConfig(dynamic payload) async {
    final code = payload['code'];
    final userId = payload['userId'];

    String? ssToken;
    Map<String, dynamic> finalConfig = { "user_id": userId, "balance": 0 };

    try {
      final ssTokenResponse = await http.post(
        Uri.parse('$backendUrl/v1/api/get_sstoken'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'app_id': baishunAppId,
          'user_id': userId,
          'code': code,
        }),
      );

      final tokenData = jsonDecode(ssTokenResponse.body);
      if (tokenData['code'] != 0) {
        throw Exception('Failed to get SSToken: ${tokenData['message']}');
      }
      ssToken = tokenData['data']['ss_token'];

      final userInfoResponse = await http.post(
        Uri.parse('$backendUrl/v1/api/get_user_info'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'app_id': baishunAppId,
          'user_id': userId,
          'ss_token': ssToken,
          'client_ip': '127.0.0.1',
          'game_id': '1000',
        }),
      );

      final userData = jsonDecode(userInfoResponse.body);
      if (userData['code'] != 0) {
        throw Exception('Failed to get user info: ${userData['message']}');
      }

      final data = userData['data'];
      finalConfig = {
        "user_id": data['user_id'],
        "user_name": data['user_name'] ?? 'Player',
        "avatar": data['user_avatar'] ?? '',
        "balance": data['balance'] ?? 0,
        "token": ssToken,
      };

    } catch (e) {
      finalConfig['token'] = '';
      finalConfig['balance'] = 0;
    }

    final js =
        "window.onGetConfig && window.onGetConfig(${jsonEncode(finalConfig)});";
    await controller.runJavaScript(js);
  }

  Future<void> _handleRecharge(payload) async {
    await _updateGameBalance(120.50);
  }

  Future<void> _updateGameBalance(double newBalance) async {
    final updatePayload = {
      "balance": newBalance,
      "currency_icon": "http://example.com/icon.png"
    };

    final js =
        "window.walletUpdate && window.walletUpdate(${jsonEncode(updatePayload)});";
    await controller.runJavaScript(js);
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _reloadGame() {
    setState(() {
      hasError = false;
      isLoading = true;
    });
    controller.reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.gameName)),
      body: Stack(
        children: [
          if (!hasError) WebViewWidget(controller: controller),
          if (isLoading)
            const Center(child: CircularProgressIndicator(color: Colors.purpleAccent)),
          if (hasError)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.wifi_off, size: 48, color: Colors.redAccent),
                  const SizedBox(height: 12),
                  const Text(
                    "Connection lost.\nPlease reopen or refresh the game.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _reloadGame,
                    child: const Text("Try Again"),
                  )
                ],
              ),
            ),
        ],
      ),
    );
  }
}