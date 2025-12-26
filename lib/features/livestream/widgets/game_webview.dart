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
  final String roomId;

  const GameWebView({
    super.key,
    required this.url,
    required this.gameName,
    required this.userId,
    required this.roomId,
  });

  @override
  State<GameWebView> createState() => _GameWebViewState();
}

class _GameWebViewState extends State<GameWebView> {
  late final WebViewController controller;
  bool isLoading = true;
  bool hasError = false;
  String? errorMessage;

  final String backendUrl = dotenv.env['BASE_URL'] ?? "";
  final String baishunAppId = dotenv.env['APP_ID'] ?? "";

  static const EventChannel _bsEventChannel = EventChannel('kitty');

  @override
  void initState() {
    super.initState();

    debugPrint("✅ [INIT] GameWebView started");
    debugPrint("✅ [INIT] gameName = ${widget.gameName}");
    debugPrint("✅ [INIT] userId   = ${widget.userId}");
    debugPrint("✅ [INIT] roomId   = ${widget.roomId}");
    debugPrint("✅ [INIT] url      = ${widget.url}");
    debugPrint("✅ [INIT] backend  = $backendUrl");
    debugPrint("✅ [INIT] appId    = $baishunAppId");

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..enableZoom(false)
      ..addJavaScriptChannel(
        "REQ",
        onMessageReceived: (msg) =>
            debugPrint("🟣 JS-REQ → ${msg.message}"),
      )
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            debugPrint("🔵 WebView page started");
            setState(() {
              isLoading = true;
              hasError = false;
            });
          },
          onPageFinished: (_) async {
            debugPrint("🟣 Injecting JS Proxy...");
            await controller.runJavaScript(_jsProxyCode(backendUrl));
            setState(() => isLoading = false);
          },
          onWebResourceError: (error) {
            debugPrint("🔴 WebView error: ${error.description}");
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
      _bsEventChannel.receiveBroadcastStream().listen(
        _onNativeEvent,
        onError: (err) {
          debugPrint('🔴 BSEventChannel error: $err');
        },
      );
    }
  }

  String _jsProxyCode(String base) {
    final safeBase = base.replaceAll(r'$', r'\$');

    debugPrint("🟣 Injecting backend BASE URL into JS: $safeBase");

    return """
    (function () {
      const backend = "$safeBase";
    
      function fixUrl(u) {
        REQ.postMessage("REQUEST → " + u);
        const full = new URL(u, window.location.origin);
        const p = full.pathname;
        let fixed = u;

        if (p === "/game_route/get_addr") {
          fixed = backend + "/games/game_route/get_addr";
        }
        else if (p.startsWith("/v1/api/")) {
          fixed = backend + "/games" + p;
        }
        
        REQ.postMessage("REWRITE → " + fixed);
        return fixed;
      }
    
      const oldFetch = window.fetch;
      window.fetch = function (resource, options) {
        REQ.postMessage("FETCH CALL → " + resource);
        return oldFetch(fixUrl(resource), options);
      };
    
      const oldOpen = XMLHttpRequest.prototype.open;
      XMLHttpRequest.prototype.open = function (method, url) {
        REQ.postMessage("XHR CALL → " + url);
        return oldOpen.call(this, method, fixUrl(url));
      };
    })();
    """;
  }

  void _onNativeEvent(dynamic event) async {
    debugPrint("🔵 Native Event Received: $event");

    try {
      final obj = json.decode(event as String);

      if (obj is! Map) {
        debugPrint("🔴 Native event not a Map");
        return;
      }

      final jsFunName = obj['jsCallback'] as String? ?? '';
      final payload = obj['data'] ?? {};

      debugPrint("📦 [JS→NATIVE] jsCallback = $jsFunName");
      debugPrint("📦 [JS→NATIVE] payload keys = ${(payload as Map).keys.toList()}");

      final jsCallback = jsFunName.isNotEmpty ? jsFunName : 'onGetConfig';

      if (jsFunName.contains('getConfig')) {
        await _handleGetConfig(payload, jsCallback);
      } else if (jsFunName.contains('verifySSToken')) {
        await _handleVerifySSToken(payload, jsCallback);
      } else if (jsFunName.contains('destroy')) {
        debugPrint("🔵 Game requested destroy()");
        await controller.loadRequest(Uri.parse('about:blank'));
        if (mounted) Navigator.of(context).maybePop();
      } else if (jsFunName.contains('gameRecharge')) {
        debugPrint("🔵 Game requested recharge UI");
        _openRecharge();
      } else if (jsFunName.contains('gameLoaded')) {
        debugPrint("🟢 Game fully loaded");
        setState(() => isLoading = false);
      }
    } catch (e) {
      debugPrint('🔴 Error handling native event: $e');
    }
  }

  // ---------------------------------------------------
  // VERIFY SSTOKEN
  // ---------------------------------------------------
  Future<void> _handleVerifySSToken(dynamic payload, String jsCallback) async {
    debugPrint("🟡 verifySSToken payload → $payload");

    Map<String, dynamic> result = {
      "success": false,
      "message": "Verification failed"
    };

    try {
      final url = '$backendUrl/games/v1/api/verifysstoken';
      debugPrint("🟡 POST → $url");

      final resp = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      debugPrint("🟢 Status = ${resp.statusCode}");
      debugPrint("🟢 Body   = ${resp.body}");

      if (resp.statusCode == 200) {
        result = jsonDecode(resp.body);
      }
    } catch (e) {
      debugPrint('🔴 verifySSToken error: $e');
    }

    await finalMapToJs(jsCallback, result);
  }

  // ---------------------------------------------------
  // GET CONFIG
  // ---------------------------------------------------
  Future<void> _handleGetConfig(dynamic payload, String jsCallback) async {
    debugPrint("📘 [DOC-CHECK] getConfig called");
    debugPrint("📘 user_id   = ${widget.userId}");
    debugPrint("📘 room_id   = ${widget.roomId}");
    debugPrint("📘 app_id    = $baishunAppId");
    debugPrint("📘 gameMode  = ${payload['gameMode']}");
    debugPrint("📘 language  = ${payload['language']}");
    debugPrint("📘 gsp/node  = ${payload['gsp']}");

    String oneTimeCode = '';
    double userBalance = 0.0;

    try {
      final url = '$backendUrl/games/generate_code_and_get_balance';
      final resp = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': widget.userId,
          'gameName': widget.gameName,
        }),
      );

      debugPrint("🟢 getConfig status = ${resp.statusCode}");
      debugPrint("🟢 getConfig body   = ${resp.body}");

      if (resp.statusCode == 200) {
        final body = jsonDecode(resp.body);
        oneTimeCode = body['otp'] ?? '';
        userBalance = (body['balance'] as num?)?.toDouble() ?? 0.0;

        debugPrint("🔑 otp     = $oneTimeCode");
        debugPrint("💰 balance = $userBalance");
      }
    } catch (e) {
      debugPrint('🔴 getConfig error: $e');
    }

    final configData = GetConfigData(
      appChannel: "kitty",
      appId: int.tryParse(baishunAppId) ?? 0,
      userId: widget.userId,
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

    debugPrint("📤 [FINAL CONFIG] ${configData.toJson()}");

    await finalMapToJs(jsCallback, configData.toJson());
  }

  Future<void> finalMapToJs(String jsFuncName, Map<String, dynamic> map) async {
    final js = "$jsFuncName(${jsonEncode(map)});";
    debugPrint("🟣 Executing JS → $js");
    await controller.runJavaScript(js);
  }

  void _openRecharge() {
    debugPrint('🟡 openRecharge()');
  }

  @override
  void dispose() {
    debugPrint("🔵 GameWebView disposed");
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
        ],
      ),
    );
  }
}
