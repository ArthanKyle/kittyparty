import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
// Required for AndroidWebViewController debugging
import 'package:webview_flutter_android/webview_flutter_android.dart';
import '../viewmodel/game_config.dart';

class GameWebView extends StatefulWidget {
  final String url;
  final String gameName;
  final String userId;

  const GameWebView({
    super.key,
    required this.url,
    required this.gameName,
    required this.userId,
  });

  @override
  State<GameWebView> createState() => _GameWebViewState();
}

class _GameWebViewState extends State<GameWebView> {
  late final WebViewController controller;
  bool isLoading = true;
  bool hasError = false;
  String? errorMessage;

  final String backendUrl = dotenv.env['BASE_URL'] ?? ""; // your app server
  final String baishunAppId = dotenv.env['APP_ID'] ?? ""; // app_id assigned by BAISHUN

  // EventChannel for Android plugin changes
  static const EventChannel _bsEventChannel = EventChannel('baishunChannel');

  @override
  void initState() {
    super.initState();

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..enableZoom(false)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (_) {
          setState(() {
            isLoading = true;
            hasError = false;
          });
        },
        onPageFinished: (_) async {
          // inject proxy only
          await controller.runJavaScript(_jsProxyCode(backendUrl));

          // REMOVED: await controller.runJavaScript(_nativeBridgeCode());
          // Reason: Your custom Java code now injects "NativeBridge" automatically.

          setState(() => isLoading = false);
        },
        onWebResourceError: (error) {
          setState(() {
            hasError = true;
            isLoading = false;
            errorMessage = error.description;
          });
        },
      ))
      ..loadRequest(Uri.parse(widget.url));

    // --- ADDED: Debugging Config (Section 7.3.5) ---
    if (controller.platform is AndroidWebViewController) {
      // Set to 'true' if you need to inspect via Chrome DevTools
      AndroidWebViewController.enableDebugging(false);
      (controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }
    // -----------------------------------------------

    // Setup Android EventChannel listener (only on Android)
    if (Platform.isAndroid) {
      _bsEventChannel.receiveBroadcastStream().listen(_onNativeEvent, onError: (err) {
        debugPrint('BSEventChannel error: $err');
      });
    }
  }

  // Proxy fetch/XHR for relative /v1/api/* -> backendUrl + path
  String _jsProxyCode(String base) {
    final safeBase = base.replaceAll(r'$', r'\$'); // minimal escaping
    return """
(function() {
  const backend = "$safeBase";
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

  // Called on Android plugin event
  void _onNativeEvent(dynamic event) async {
    try {
      if (event == null) return; // Handle null event

      debugPrint("Received Native Event: $event"); // Log the raw event to see what the game sent

      dynamic obj;
      try {
        obj = json.decode(event as String);
      } catch(e) {
        return;
      }

      // ⚠️ FIX: Check if obj is null before accessing []
      if (obj == null || obj is! Map) {
        debugPrint("Native event payload is empty or invalid");
        return;
      }

      final jsFunName = obj['jsCallback'] as String? ?? '';
      final payload = obj['data'] ?? {}; // Default to empty map if data is null

      // Default to 'onGetConfig' because sometimes the game just calls getConfig without specifying a callback name
      final jsCallback = (obj['jsCallback'] != null && obj['jsCallback'].isNotEmpty)
          ? obj['jsCallback']
          : 'onGetConfig';

      if (jsFunName.contains('getConfig')) {
        print("BSGAME: Game requested getConfig"); // Debug log
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
    // 1. Use the ID passed to the Widget, not the empty payload
    final userId = widget.userId;

    // 2. Use your existing logic to get the code/balance
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

    String validIcon = "";

    final configData = GetConfigData(
      appChannel: "kitty",
      appId: int.tryParse(baishunAppId) ?? 0,
      userId: userId,
      gameMode: payload['gameMode']?.toString() ?? "3",
      language: payload['language']?.toString() ?? "2",
      gsp: payload['gsp'] ?? 101,
      roomId: payload['roomId']?.toString() ?? "",
      code: oneTimeCode, // Now this will be valid!
      balance: userBalance,
      gameConfig: GameConfig(
        sceneMode: payload?['gameConfig']?['sceneMode'] ?? 0,
        currencyIcon: validIcon, // Empty string prevents CSP error
      ),
    );

    // 4. Send back to Game
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

  // Example: open your app's recharge UI
  void _openRecharge() {
    // implement showing your purchase screen
    debugPrint('open recharge UI');
  }

  // App-side call to notify game of new wallet balance
  Future<void> walletUpdate(double newBalance) async {
    final updatePayload = {
      "balance": newBalance,
      "currency_icon": "https://example.com/icon.png"
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
      body: Stack(children: [
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
                ElevatedButton(onPressed: _reloadGame, child: const Text("Try Again")),
              ],
            ),
          )
      ]),
    );
  }
}