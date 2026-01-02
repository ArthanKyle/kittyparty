  import 'dart:convert';
  import 'dart:io';
  
  import 'package:flutter/material.dart';
  import 'package:flutter/services.dart';
  import 'package:flutter_dotenv/flutter_dotenv.dart';
  import 'package:http/http.dart' as http;
  import 'package:webview_flutter/webview_flutter.dart';
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
  
    late final String backendUrl;
    late final String baishunAppId;
  
    static const EventChannel _bsEventChannel = EventChannel('kitty');
  
    @override
    void initState() {
      super.initState();
  
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  
      backendUrl = _normalizeBaseUrl(dotenv.env['BASE_URL'] ?? '');
      baishunAppId = (dotenv.env['APP_ID'] ?? '').trim();
  
      if (backendUrl.isEmpty) {
        _setFatalError('BASE_URL is empty. Please set BASE_URL in .env');
      }
      if (baishunAppId.isEmpty) {
        _setFatalError('APP_ID is empty. Please set APP_ID in .env');
      }
  
      controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..enableZoom(false)
        ..addJavaScriptChannel(
          "REQ",
          onMessageReceived: (msg) => debugPrint("🟣 JS-REQ → ${msg.message}"),
        )
        ..setBackgroundColor(const Color(0x00000000))
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (_) {
              debugPrint("🔵 WebView page started");
              setState(() {
                isLoading = true;
                hasError = false;
                errorMessage = null;
              });
            },
            onPageFinished: (_) {
              // FIX: Make async inside then()
              controller.runJavaScript(_netDebugHooks()).then((_) {
                debugPrint("🟢 WebView page finished");
              }).catchError((e) {
                debugPrint("⚠️ JS hook injection failed: $e");
              });
              setState(() => isLoading = false);
            },
            onWebResourceError: (error) {
              debugPrint("🔴 WebView error: ${error.description}");
              _setFatalError(error.description);
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
          onError: (err) => debugPrint('🔴 BSEventChannel error: $err'),
        );
      }
    }
  
    String _normalizeBaseUrl(String url) {
      var u = url.trim();
      while (u.endsWith('/')) {
        u = u.substring(0, u.length - 1);
      }
      return u;
    }
  
    void _setFatalError(String msg) {
      if (!mounted) return;
      setState(() {
        hasError = true;
        isLoading = false;
        errorMessage = msg;
      });
    }
  
    // ✅ JS network debug hook
    String _netDebugHooks() {
      return r"""
  (function () {
    if (window.__KP_NET_DEBUG__) return;
    window.__KP_NET_DEBUG__ = true;
  
    const OldWS = window.WebSocket;
    window.WebSocket = function (url, protocols) {
      console.log("[KP][WS open]", url, protocols || "");
      const ws = protocols ? new OldWS(url, protocols) : new OldWS(url);
      ws.addEventListener("close", (e) => console.log("[KP][WS close]", e.code, e.reason));
      ws.addEventListener("error", (e) => console.log("[KP][WS error]", e));
      return ws;
    };
  
    const oldFetch = window.fetch;
    if (oldFetch) {
      window.fetch = async function () {
        const args = arguments;
        console.log("[KP][fetch]", args[0], args[1] || "");
        const res = await oldFetch.apply(this, args);
        try {
          const clone = res.clone();
          const text = await clone.text();
          console.log("[KP][fetch resp]", res.status, (text || "").slice(0, 300));
        } catch (e) {}
        return res;
      };
    }
  
    const XHR = window.XMLHttpRequest;
    if (XHR) {
      const open = XHR.prototype.open;
      const send = XHR.prototype.send;
  
      XHR.prototype.open = function (method, url) {
        this.__kp = { method, url };
        return open.apply(this, arguments);
      };
  
      XHR.prototype.send = function (body) {
        this.addEventListener("loadend", function () {
          try {
            console.log("[KP][xhr]", this.__kp.method, this.__kp.url, "->", this.status);
            if (this.status >= 400) {
              console.log("[KP][xhr body]", (this.responseText || "").slice(0, 300));
            }
          } catch (e) {}
        });
        return send.apply(this, arguments);
      };
    }
  })();
  """;
    }
  
    // Handles native event messages
    void _onNativeEvent(dynamic event) async {
      debugPrint("🔵 Native Event Received: $event");
      try {
        final obj = json.decode(event as String);
        if (obj is! Map) return;
        final jsFunName = obj['jsCallback'] as String? ?? '';
        final payload = obj['data'] ?? {};
  
        final jsCallback = jsFunName.isNotEmpty ? jsFunName : 'onGetConfig';
  
        if (jsFunName.contains('getConfig')) {
          await _handleGetConfig(payload, jsCallback);
        } else if (jsFunName.contains('destroy')) {
          await controller.loadRequest(Uri.parse('about:blank'));
          if (mounted) Navigator.of(context).maybePop();
        } else if (jsFunName.contains('gameRecharge')) {
          _openRecharge();
        } else if (jsFunName.contains('gameLoaded')) {
          if (mounted) setState(() => isLoading = false);
        }
      } catch (e) {
        debugPrint('🔴 Error handling native event: $e');
      }
    }
  
    Future<void> _handleGetConfig(dynamic payload, String jsCallback) async {
      debugPrint("📘 [DOC-CHECK] getConfig called");
      debugPrint("📘 user_id   = ${widget.userId}");
      debugPrint("📘 room_id   = ${widget.roomId}");
      debugPrint("📘 app_id    = $baishunAppId");
  
      if (backendUrl.isEmpty || baishunAppId.isEmpty) {
        _setFatalError('Missing BASE_URL / APP_ID configuration.');
        return;
      }
  
      String oneTimeCode = '';
      double userBalance = 0.0;
  
      try {
        final url = '$backendUrl/games/generate_code_and_get_balance';
        final resp = await http
            .post(
          Uri.parse(url),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'user_id': widget.userId,
            'gameName': widget.gameName,
          }),
        )
            .timeout(const Duration(seconds: 12));
  
        debugPrint("🟢 getConfig status = ${resp.statusCode}");
        debugPrint("🟢 getConfig body   = ${resp.body}");
  
        if (resp.statusCode != 200) {
          _setFatalError('getConfig failed (HTTP ${resp.statusCode}).');
          return;
        }
  
        final body = jsonDecode(resp.body);
        if (body is! Map) {
          _setFatalError('getConfig response is not JSON object.');
          return;
        }
  
        if ((body['code'] ?? -1) != 0) {
          _setFatalError(
              'getConfig backend error: ${body['message'] ?? body['msg'] ?? 'Unknown'}');
          return;
        }
  
        oneTimeCode = (body['otp'] ?? '').toString();
        userBalance = (body['balance'] as num?)?.toDouble() ?? 0.0;
  
        if (oneTimeCode.isEmpty) {
          _setFatalError('OTP/code is empty from backend. Cannot continue.');
          return;
        }
      } catch (e) {
        _setFatalError('getConfig error: $e');
        return;
      }
  
      final configData = GetConfigData(
        appChannel: "kitty",
        appId: int.tryParse(baishunAppId) ?? 0,
        userId: widget.userId,
        gameMode: (payload is Map && payload['gameMode'] != null)
            ? payload['gameMode'].toString()
            : "3",
        language: (payload is Map && payload['language'] != null)
            ? payload['language'].toString()
            : "2",
        gsp: (payload is Map && payload['gsp'] != null) ? payload['gsp'] : 101,
        roomId: widget.roomId,
        code: oneTimeCode,
        balance: userBalance,
        gameConfig: GameConfig(
          sceneMode: (payload is Map &&
              payload['gameConfig'] is Map &&
              payload['gameConfig']['sceneMode'] != null)
              ? payload['gameConfig']['sceneMode']
              : 0,
          currencyIcon: "",
        ),
      );
  
      debugPrint("📤 [FINAL CONFIG] ${configData.toJson()}");
      await _finalMapToJs(jsCallback, configData.toJson());
    }
  
    Future<void> _finalMapToJs(String jsFuncName, Map<String, dynamic> map) async {
      final js = "$jsFuncName(${jsonEncode(map)});";
      try {
        await controller.runJavaScript(js);
      } catch (e) {
        _setFatalError('Failed to run JS callback: $e');
      }
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
            if (isLoading && !hasError)
              const Center(child: CircularProgressIndicator()),
            if (hasError)
              Container(
                color: Colors.black,
                alignment: Alignment.center,
                padding: const EdgeInsets.all(16),
                child: Text(
                  errorMessage ?? "Unknown error",
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      );
    }
  }
