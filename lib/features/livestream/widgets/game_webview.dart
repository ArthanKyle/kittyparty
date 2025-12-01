import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter_android/webview_flutter_android.dart';
import '../viewmodel/game_config.dart';

class GameWebView extends StatefulWidget {
  final String url;
  final String gameName;
  final String userId;
  final String roomId; // ADD THIS

  const GameWebView({
    super.key,
    required this.url,
    required this.gameName,
    required this.userId,
    required this.roomId, // ADD THIS
  });


  @override
  State<GameWebView> createState() => _GameWebViewState();
}

class _GameWebViewState extends State<GameWebView> {
  late final WebViewController controller;
  bool isLoading = true;
  bool hasError = false;
  String? errorMessage;

  final String backendUrl = dotenv.env['BASE_URL'] ?? ""; // e.g. https://.../api
  final String baishunAppId = dotenv.env['APP_ID'] ?? ""; // app_id assigned by BAISHUN

  static const EventChannel _bsEventChannel = EventChannel('baishunChannel');

  @override
  void initState() {
    super.initState();

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..enableZoom(false)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            setState(() {
              isLoading = true;
              hasError = false;
            });
          },
          onPageFinished: (_) async {
            // inject proxy only
            await controller.runJavaScript(_jsProxyCode(backendUrl));
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

    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(false);
      (controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }

    if (Platform.isAndroid) {
      _bsEventChannel
          .receiveBroadcastStream()
          .listen(_onNativeEvent, onError: (err) {
        debugPrint('BSEventChannel error: $err');
      });
    }
  }

  String _jsProxyCode(String base) {
    final safeBase = base.replaceAll(r'$', r'\$');

    return """
(function() {
  const backend = "$safeBase";

  function fixUrl(u) {
    if (typeof u !== "string") return u;

    // Remove host
    const noHost = u.replace(/^https?:\\/\\/[^/]+/, "");

    // 1. BAISHUN routing server
    if (noHost.startsWith("/game_route/get_addr") || noHost.includes("game_route/get_addr")) {
      return backend + "/games/game_route/get_addr" + (noHost.startsWith("/") ? noHost.replace("/game_route/get_addr", "") : "");
    }

    // 2. Core BAISHUN APIs
    if (noHost.startsWith("/v1/api/") || noHost.startsWith("v1/api/")) {
      const path = noHost.startsWith("/") ? noHost : "/" + noHost;
      return backend + "/games" + path;
    }

    return u;
  }

  const originalFetch = window.fetch;
  window.fetch = function(resource, options) {
    return originalFetch(fixUrl(resource), options);
  };

  const originalOpen = XMLHttpRequest.prototype.open;
  XMLHttpRequest.prototype.open = function(method, url) {
    return originalOpen.call(this, method, fixUrl(url));
  };
})();
""";
  }

  // Called on Android plugin event
  void _onNativeEvent(dynamic event) async {
    try {
      if (event == null) return;

      debugPrint("Received Native Event: $event");

      dynamic obj;
      try {
        obj = json.decode(event as String);
      } catch (e) {
        return;
      }

      if (obj == null || obj is! Map) {
        debugPrint("Native event payload is empty or invalid");
        return;
      }

      final jsFunName = obj['jsCallback'] as String? ?? '';
      final payload = obj['data'] ?? {};

      final jsCallback = (obj['jsCallback'] != null && obj['jsCallback'].isNotEmpty)
          ? obj['jsCallback']
          : 'onGetConfig';

      if (jsFunName.contains('getConfig')) {
        print("BSGAME: Game requested getConfig");
        await _handleGetConfig(payload, jsCallback);
      } else if (jsFunName.contains('destroy')) {
        print("BSGAME: Game requested destroy");
        await controller.loadRequest(Uri.parse('about:blank'));
        if (mounted) Navigator.of(context).maybePop();
      } else if (jsFunName.contains('gameRecharge')) {
        print("BSGAME: Game requested recharge");
        _openRecharge();
      } else if (jsFunName.contains('gameLoaded')) {
        print("BSGAME: Game Loaded");
        setState(() => isLoading = false);
      }
    } catch (e) {
      debugPrint('Error handling native event: $e');
    }
  }

  Future<void> _handleGetConfig(dynamic payload, String jsCallback) async {
    final userId = widget.userId;

    String oneTimeCode = '';
    double userBalance = 0.0;

    try {
      final resp = await http.post(
        Uri.parse('$backendUrl/games/generate_code_and_get_balance'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user_id': userId, 'gameName': widget.gameName}),
      );
      if (resp.statusCode == 200) {
        final body = jsonDecode(resp.body);
        oneTimeCode = body['code'] ?? '';
        userBalance = (body['balance'] as num?)?.toDouble() ?? 0.0;
      } else {
        debugPrint("Backend Error: ${resp.body}");
      }
    } catch (e) {
      debugPrint('Server request failed: $e');
    }

    final configData = GetConfigData(
      appChannel: "kitty",
      appId: int.tryParse(baishunAppId) ?? 0,
      userId: userId,
      gameMode: payload['gameMode']?.toString() ?? "3",
      language: payload['language']?.toString() ?? "2",
      gsp: payload['gsp'] ?? 101,
      roomId: widget.roomId,
      code: oneTimeCode,
      balance: userBalance,
      gameConfig: GameConfig(
        sceneMode: payload?['gameConfig']?['sceneMode'] ?? 0,
        currencyIcon: "",
      ),
    );

    print("BSGAME: Sending Config to Game: ${jsonEncode(configData.toJson())}");
    await finalMapToJs(jsCallback, configData.toJson());
  }

  Future<void> finalMapToJs(String jsFuncName, Map<String, dynamic> map) async {
    final js = "$jsFuncName(${jsonEncode(map)});";
    try {
      await controller.runJavaScript(js);
    } catch (e) {
      debugPrint('Error runJavaScript: $e');
    }
  }

  void _openRecharge() {
    debugPrint('open recharge UI');
  }

  Future<void> walletUpdate(double newBalance) async {
    final updatePayload = {
      "balance": newBalance,
      "currency_icon": "assets/icons/KPcoin.png"
    };
    final js = "walletUpdate(${jsonEncode(updatePayload)});";
    await controller.runJavaScript(js);
  }

  void _reloadGame() {
    setState(() {
      hasError = false;
      isLoading = true;
    });
    controller.reload();
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.gameName)),
      body: Stack(
        children: [
          if (!hasError) WebViewWidget(controller: controller),
          if (isLoading) const Center(child: CircularProgressIndicator()),
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
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
