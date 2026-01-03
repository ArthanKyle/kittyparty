// lib/pages/game_webview.dart
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
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

  late final String backendBaseUrl; // e.g. https://domain.com (NO trailing slash, NO /api)
  late final String baishunAppId; // APP_ID
  late final String baishunAppKey; // APP_KEY (must match process.env.BAISHUN_APP_KEY)

  String? _lastSsToken;

  static const EventChannel _bsEventChannel = EventChannel('kitty');

  @override
  void initState() {
    super.initState();

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    backendBaseUrl = _normalizeBaseUrl(dotenv.env['BASE_URL'] ?? '');
    baishunAppId = (dotenv.env['BAISHUN_APP_ID'] ?? '').trim();
    baishunAppKey = (dotenv.env['BAISHUN_APP_KEY'] ?? '').trim();

    if (backendBaseUrl.isEmpty) _setFatalError('BASE_URL is empty. Please set BASE_URL in .env');
    if (baishunAppId.isEmpty) _setFatalError('APP_ID is empty. Please set APP_ID in .env');
    if (baishunAppKey.isEmpty) _setFatalError('APP_KEY is empty. Please set APP_KEY in .env');

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
            if (!mounted) return;
            setState(() {
              isLoading = true;
              hasError = false;
              errorMessage = null;
            });
          },
          onPageFinished: (_) async {
            try {
              await controller.runJavaScript(_netDebugHooks());
              // Inject auth hooks *after* page loads (so game requests include token)
              await controller.runJavaScript(_authHooks());
              debugPrint("🟢 WebView page finished + hooks injected");
            } catch (e) {
              debugPrint("⚠️ JS hook injection failed: $e");
            }

            if (!mounted) return;
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
      (controller.platform as AndroidWebViewController).setMediaPlaybackRequiresUserGesture(false);
    }

    if (Platform.isAndroid) {
      _bsEventChannel.receiveBroadcastStream().listen(
        _onNativeEvent,
        onError: (err) => debugPrint('🔴 BSEventChannel error: $err'),
      );
    }
  }

  // -----------------------------
  // URL helpers
  // -----------------------------
  String _normalizeBaseUrl(String url) {
    var u = url.trim();
    while (u.endsWith('/')) {
      u = u.substring(0, u.length - 1);
    }
    return u;
  }

  /// Builds: {BASE_URL}/api/{path}
  Uri _api(String path) {
    final p = path.startsWith('/') ? path.substring(1) : path;
    return Uri.parse('$backendBaseUrl/$p');
  }

  /// Builds: {BASE_URL}/api/games/{path}
  Uri _games(String path) {
    final p = path.startsWith('/') ? path.substring(1) : path;
    return _api('games/$p');
  }

  // -----------------------------
  // Signature (BAISHUN)
  // signature = md5(nonce + appKey + timestampSeconds)
  // -----------------------------
  int _timestampSeconds() => DateTime.now().millisecondsSinceEpoch ~/ 1000;

  String _randomNonceHex({int bytes = 8}) {
    final rnd = Random.secure();
    final b = Uint8List(bytes);
    for (var i = 0; i < bytes; i++) {
      b[i] = rnd.nextInt(256);
    }
    final sb = StringBuffer();
    for (final v in b) {
      sb.write(v.toRadixString(16).padLeft(2, '0'));
    }
    return sb.toString();
  }

  String _makeSignature({
    required String nonce,
    required String appKey,
    required int timestampSeconds,
  }) {
    final raw = '$nonce$appKey$timestampSeconds';
    return md5.convert(utf8.encode(raw)).toString();
  }

  // -----------------------------
  // Backend calls
  // -----------------------------
  Future<String> _exchangeOtpToSsToken({
    required String otp,
    required String userId,
  }) async {
    final nonce = _randomNonceHex();
    final ts = _timestampSeconds();
    final sig = _makeSignature(nonce: nonce, appKey: baishunAppKey, timestampSeconds: ts);

    // ✅ Correct because app.js mounts /api, routes mounts /games:
    // -> {BASE_URL}/api/games/v1/api/get_sstoken
    final endpoint = _games('v1/api/get_sstoken');

    final payload = <String, dynamic>{
      'app_id': baishunAppId,
      'user_id': userId,
      'code': otp,

      // BAISHUN signature fields (must match backend middleware keys)
      'signature_nonce': nonce,
      'timestamp': ts,
      'signature': sig,
    };

    debugPrint("🟡 get_sstoken POST = $endpoint");
    debugPrint("🟡 get_sstoken payload = ${jsonEncode(payload)}");

    final resp = await http
        .post(
      endpoint,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    )
        .timeout(const Duration(seconds: 12));

    debugPrint("🟢 get_sstoken status = ${resp.statusCode}");
    debugPrint("🟢 get_sstoken body   = ${resp.body}");

    if (resp.statusCode != 200) {
      throw Exception('get_sstoken failed (HTTP ${resp.statusCode})');
    }

    final body = jsonDecode(resp.body);
    if (body is! Map) throw Exception('get_sstoken response not JSON object');

    final code = body['code'];
    if (code != 0) {
      throw Exception('get_sstoken error: ${body['message'] ?? body['msg'] ?? 'Unknown'}');
    }

    final data = body['data'];
    if (data is! Map) throw Exception('get_sstoken data missing');

    final ssToken = (data['ss_token'] ?? '').toString().trim();
    if (ssToken.isEmpty) throw Exception('ss_token is empty');

    return ssToken;
  }

  Future<Map<String, dynamic>> _generateOtpAndBalance() async {
    // ✅ Correct because app.js mounts /api, routes mounts /games:
    // -> {BASE_URL}/api/games/generate_code_and_get_balance
    final endpoint = _games('generate_code_and_get_balance');

    final resp = await http
        .post(
      endpoint,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': widget.userId,
        'gameName': widget.gameName,
      }),
    )
        .timeout(const Duration(seconds: 12));

    debugPrint("🟢 generate_code_and_get_balance status = ${resp.statusCode}");
    debugPrint("🟢 generate_code_and_get_balance body   = ${resp.body}");

    if (resp.statusCode != 200) {
      throw Exception('generate_code_and_get_balance failed (HTTP ${resp.statusCode})');
    }

    final body = jsonDecode(resp.body);
    if (body is! Map) throw Exception('generate_code_and_get_balance response not JSON object');

    if ((body['code'] ?? -1) != 0) {
      throw Exception('backend error: ${body['message'] ?? body['msg'] ?? 'Unknown'}');
    }

    final otp = (body['otp'] ?? '').toString().trim();
    final balance = (body['balance'] as num?)?.toDouble() ?? 0.0;

    if (otp.isEmpty) throw Exception('OTP is empty');

    return {'otp': otp, 'balance': balance};
  }

  // -----------------------------
  // UI + error
  // -----------------------------
  void _setFatalError(String msg) {
    if (!mounted) return;
    setState(() {
      hasError = true;
      isLoading = false;
      errorMessage = msg;
    });
  }

  // -----------------------------
  // JS hooks
  // -----------------------------
  // Network debug hook
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

  /// Inject token + user_id into fetch/XHR headers and ws URL query.
  /// This fixes the common 401 {code:1001} when the game forgets to send token.
  String _authHooks() {
    // These values are substituted by Dart at runtime (not a raw string).
    final ss = _lastSsToken ?? "";
    final uid = widget.userId;

    // If token is still empty at injection time, hooks still install but do nothing.
    return """
(function () {
  if (window.__KP_AUTH_HOOKS__) return;
  window.__KP_AUTH_HOOKS__ = true;

  function getToken() { return (window.__KP_SSTOKEN__ || "").toString(); }
  function getUserId() { return (window.__KP_USERID__ || "").toString(); }

  window.__KP_SSTOKEN__ = ${jsonEncode(ss)};
  window.__KP_USERID__ = ${jsonEncode(uid)};

  // Patch fetch
  const oldFetch = window.fetch;
  if (oldFetch) {
    window.fetch = function(input, init) {
      try {
        init = init || {};
        init.headers = init.headers || {};
        const t = getToken();
        const u = getUserId();
        if (t) {
          // accept multiple header names
          init.headers["sstoken"] = t;
          init.headers["ss_token"] = t;
          init.headers["x-sstoken"] = t;
          init.headers["x-ss-token"] = t;
          init.headers["Authorization"] = "Bearer " + t;
        }
        if (u) {
          init.headers["user_id"] = u;
          init.headers["userId"] = u;
        }
      } catch (e) {}
      return oldFetch.call(this, input, init);
    };
  }

  // Patch XHR
  const XHR = window.XMLHttpRequest;
  if (XHR) {
    const open = XHR.prototype.open;
    const send = XHR.prototype.send;
    XHR.prototype.open = function(method, url) {
      this.__kp_url = url;
      return open.apply(this, arguments);
    };
    XHR.prototype.send = function(body) {
      try {
        const t = getToken();
        const u = getUserId();
        if (t) {
          this.setRequestHeader("sstoken", t);
          this.setRequestHeader("ss_token", t);
          this.setRequestHeader("x-sstoken", t);
          this.setRequestHeader("x-ss-token", t);
          this.setRequestHeader("Authorization", "Bearer " + t);
        }
        if (u) {
          this.setRequestHeader("user_id", u);
          this.setRequestHeader("userId", u);
        }
      } catch (e) {}
      return send.apply(this, arguments);
    };
  }

  // Patch WebSocket: append query params (?sstoken=...&user_id=...)
  const OldWS = window.WebSocket;
  if (OldWS) {
    window.WebSocket = function(url, protocols) {
      try {
        const t = getToken();
        const u = getUserId();
        if (t || u) {
          const hasQuery = url.indexOf("?") >= 0;
          const sep = hasQuery ? "&" : "?";
          const qp = [];
          if (t) { qp.push("sstoken=" + encodeURIComponent(t)); qp.push("ss_token=" + encodeURIComponent(t)); }
          if (u) { qp.push("user_id=" + encodeURIComponent(u)); qp.push("userId=" + encodeURIComponent(u)); }
          url = url + sep + qp.join("&");
        }
      } catch (e) {}
      return protocols ? new OldWS(url, protocols) : new OldWS(url);
    };
  }

  console.log("[KP][AUTH] hooks installed. tokenLen=", getToken().length, "user=", getUserId());
})();
""";
  }

  Future<void> _pushAuthToWebView({
    required String ssToken,
    required String userId,
  }) async {
    _lastSsToken = ssToken;
    final js = """
(function(){
  window.__KP_SSTOKEN__ = ${jsonEncode(ssToken)};
  window.__KP_USERID__ = ${jsonEncode(userId)};
  console.log("[KP][AUTH] updated tokenLen=", (window.__KP_SSTOKEN__||"").length, "user=", window.__KP_USERID__);
})();
""";
    try {
      await controller.runJavaScript(js);
      // Ensure hooks exist (safe even if already installed)
      await controller.runJavaScript(_authHooks());
    } catch (e) {
      debugPrint("⚠️ Failed pushing auth to WebView: $e");
    }
  }

  // -----------------------------
  // Native event handler
  // -----------------------------
  void _onNativeEvent(dynamic event) async {
    debugPrint("🔵 Native Event Received: $event");
    try {
      final obj = json.decode(event as String);
      if (obj is! Map) return;

      final jsFunName = (obj['jsCallback'] as String?) ?? '';
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
    debugPrint("📘 [getConfig] user_id=${widget.userId} room_id=${widget.roomId} app_id=$baishunAppId");

    if (backendBaseUrl.isEmpty || baishunAppId.isEmpty || baishunAppKey.isEmpty) {
      _setFatalError('Missing BASE_URL / APP_ID / APP_KEY configuration.');
      return;
    }

    try {
      // 1) Generate OTP and balance from your backend
      final gen = await _generateOtpAndBalance();
      final otp = gen['otp'] as String;
      final balance = gen['balance'] as double;

      // 2) Exchange OTP -> ss_token (BAISHUN)
      final ssToken = await _exchangeOtpToSsToken(otp: otp, userId: widget.userId);
      debugPrint("🟢 ss_token acquired (len=${ssToken.length})");

      // 3) Push token into WebView so game network requests stop 401
      await _pushAuthToWebView(ssToken: ssToken, userId: widget.userId);

      // 4) Build config to JS callback
      final configData = GetConfigData(
        appChannel: "kitty",
        appId: int.tryParse(baishunAppId) ?? 0,
        userId: widget.userId,
        gameMode: (payload is Map && payload['gameMode'] != null) ? payload['gameMode'].toString() : "3",
        language: (payload is Map && payload['language'] != null) ? payload['language'].toString() : "2",
        gsp: (payload is Map && payload['gsp'] != null) ? payload['gsp'] : 101,
        roomId: widget.roomId,

        // IMPORTANT:
        // Some game builds want "code" (otp), some want "ss_token".
        // We keep your existing field "code" = otp, and ALSO include token by injecting auth hooks.
        code: otp,
        balance: balance,

        gameConfig: GameConfig(
          sceneMode: (payload is Map && payload['gameConfig'] is Map && payload['gameConfig']['sceneMode'] != null)
              ? payload['gameConfig']['sceneMode']
              : 0,
          currencyIcon: "",
        ),
      );

      debugPrint("📤 [FINAL CONFIG] ${configData.toJson()}");
      await _finalMapToJs(jsCallback, configData.toJson());
    } catch (e) {
      _setFatalError('getConfig error: $e');
      return;
    }
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
          if (isLoading && !hasError) const Center(child: CircularProgressIndicator()),
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
