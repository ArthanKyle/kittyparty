import 'dart:async';
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
  final int gameId;

  const GameWebView({
    super.key,
    required this.url,
    required this.gameName,
    required this.userId,
    required this.roomId,
    required this.gameId,
  });

  @override
  State<GameWebView> createState() => _GameWebViewState();
}

class _GameWebViewState extends State<GameWebView> {
  late final WebViewController controller;
  late StreamSubscription _bsSub;

  bool isLoading = true;
  bool hasError = false;
  String? errorMessage;
  bool _eventBound = false;
  bool _authInProgress = false;
  bool _authCompleted = false;
  bool _sstokenIssued = false;

  late final String backendBaseUrl;
  late final int baishunAppId; // ✅ INT64
  late final String baishunAppKey;

  String? _lastSsToken;

  static const EventChannel _bsEventChannel = EventChannel('kitty');

  // ===========================
  // INIT
  // ===========================
  @override
  void initState() {
    super.initState();

    _bsSub = _bsEventChannel
        .receiveBroadcastStream()
        .listen(_onNativeEvent);

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    backendBaseUrl = _normalizeBaseUrl(dotenv.env['BASE_URL'] ?? '');
    baishunAppId = int.parse(dotenv.env['BAISHUN_APP_ID']!);
    baishunAppKey = dotenv.env['BAISHUN_APP_KEY']!;

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..enableZoom(false)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (!mounted) return;
            setState(() {
              isLoading = true;
              hasError = false;
              errorMessage = null;
            });
          },
          onPageFinished: (_) async {
            await controller.runJavaScript(_authHooks());
            if (mounted) setState(() => isLoading = false);
          },
          onWebResourceError: (e) => _setFatalError(e.description),
        ),
      )
      ..loadRequest(Uri.parse(widget.url));

    if (controller.platform is AndroidWebViewController) {
      (controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }

    if (Platform.isAndroid && !_eventBound) {
      _eventBound = true;
      _bsEventChannel
          .receiveBroadcastStream()
          .listen(_onNativeEvent);
    }
  }

  // ===========================
  // URL HELPERS
  // ===========================
  String _normalizeBaseUrl(String url) {
    var u = url.trim();
    while (u.endsWith('/')) u = u.substring(0, u.length - 1);
    return u;
  }

  Uri _games(String path) =>
      Uri.parse('$backendBaseUrl/games/${path.startsWith('/')
          ? path.substring(1)
          : path}');

  // ===========================
  // BAISHUN SIGNATURE (CORRECT)
  // md5(app_id + user_id + game_id + provider_name + timestamp + nonce + app_key)
  // ===========================
  int _timestampSeconds() =>
      DateTime
          .now()
          .millisecondsSinceEpoch ~/ 1000;

  String _randomNonce({int length = 24}) {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rnd = Random.secure();
    return List
        .generate(length, (_) => chars[rnd.nextInt(chars.length)])
        .join();
  }

  // ===========================
  // BACKEND CALLS
  // ===========================
  Future<Map<String, dynamic>> _generateOtpAndBalance() async {
    final resp = await http.post(
      _games('generate_code_and_get_balance'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'user_id': widget.userId}),
    );

    final body = jsonDecode(resp.body);
    if (body['code'] != 0) throw Exception(body['message']);

    return {
      'otp': body['otp'],
      'balance': (body['balance'] as num).toDouble(),
    };
  }

  Future<String> _exchangeOtpToSsToken({
    required String otp,
    required String userId,
  }) async {
    final int ts = _timestampSeconds();
    final String nonce = _randomNonce();

    // Signature = md5(signature_nonce + appKey + timestamp)
    final String raw = '$nonce$baishunAppKey$ts';
    final String signature =
    md5.convert(utf8.encode(raw)).toString();

    final Uri endpoint = _games('v1/api/get_sstoken');

    final payload = <String, dynamic>{
      'app_id': baishunAppId,     // validated only
      'user_id': userId,
      'code': otp,
      'timestamp': ts,
      'signature_nonce': nonce,
      'signature': signature,
    };

    debugPrint("🟡 get_sstoken RAW = $raw");
    debugPrint("🟡 get_sstoken MD5 = $signature");
    debugPrint("🟡 get_sstoken PAYLOAD = ${jsonEncode(payload)}");

    final resp = await http
        .post(
      endpoint,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    )
        .timeout(const Duration(seconds: 12));

    debugPrint("🟢 get_sstoken status = ${resp.statusCode}");
    debugPrint("🟢 get_sstoken body = ${resp.body}");

    if (resp.statusCode != 200) {
      throw Exception('get_sstoken failed (HTTP ${resp.statusCode})');
    }

    final body = jsonDecode(resp.body);
    if (body['code'] != 0) {
      throw Exception(body['message'] ?? 'get_sstoken error');
    }

    final ssToken = (body['data']?['ss_token'] ?? '').toString();
    if (ssToken.isEmpty) {
      throw Exception('ss_token missing');
    }

    return ssToken;
  }

  // ===========================
  // JS INJECTION
  // ===========================
  String _authHooks() {
    final ss = _lastSsToken ?? '';
    final uid = widget.userId;
    final host = Uri
        .parse(backendBaseUrl)
        .host;

    return """
  (function () {
    window.__KP_SSTOKEN__ = ${jsonEncode(ss)};
    window.__KP_USERID__ = ${jsonEncode(uid)};
  
    function isBackend(url) {
      try { return new URL(url, location.href).host === "$host"; }
      catch (e) { return false; }
    }
  
    const oldFetch = window.fetch;
    if (oldFetch) {
      window.fetch = function(input, init) {
        init = init || {};
        init.headers = init.headers || {};
        const url = typeof input === "string" ? input : input.url;
  
        if (isBackend(url)) {
          if (window.__KP_SSTOKEN__) {
            init.headers["ss_token"] = window.__KP_SSTOKEN__;
            init.headers["sstoken"] = window.__KP_SSTOKEN__;
          }
          init.headers["user_id"] = window.__KP_USERID__;
        }
        return oldFetch.call(this, input, init);
      };
    }
  })();
  """;
  }

  Future<void> _pushAuth(String token) async {
    _lastSsToken = token;
    await controller.runJavaScript(_authHooks());
  }

  // ===========================
  // NATIVE EVENTS
  // ===========================
  void _onNativeEvent(dynamic event) async {
    // 🔒 HARD GUARD — FIRST LINE
    if (_authInProgress || _authCompleted) {
      debugPrint("⚠️ get_sstoken skipped (already handled)");
      return;
    }

    _authInProgress = true;

    try {
      final obj = jsonDecode(event as String);
      final jsCallback = obj['jsCallback'] ?? 'onGetConfig';

      final gen = await _generateOtpAndBalance();
      final otp = gen['otp'];
      final balance = gen['balance'];

      final ssToken = await _exchangeOtpToSsToken(
        otp: otp,
        userId: widget.userId,
      );

      await _pushAuth(ssToken);

      final config = GetConfigData(
        appChannel: 'kitty',
        appId: baishunAppId,
        userId: widget.userId,
        gameMode: '3',
        language: '2',
        gsp: 101,
        roomId: widget.roomId,
        code: otp,
        balance: balance,
        gameConfig: GameConfig(sceneMode: 0, currencyIcon: ''),
      );

      await controller.runJavaScript(
        '$jsCallback(${jsonEncode(config.toJson())});',
      );

      // ✅ MARK SUCCESS ONLY AT THE END
      _authCompleted = true;
      debugPrint("✅ ss_token issued and config sent");
    } catch (e) {
      debugPrint("❌ auth flow failed: $e");
      _authInProgress = false;
      _setFatalError(e.toString());
    }
  }

  // ===========================
  // UI
  // ===========================
  void _setFatalError(String msg) {
    if (!mounted) return;
    setState(() {
      hasError = true;
      isLoading = false;
      errorMessage = msg;
    });
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _bsSub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ---- DEBUG LOGS (VALID LOCATION) ----
    debugPrint(
      "🧱 [BUILD] hasError=$hasError | isLoading=$isLoading | errorMessage=$errorMessage",
    );

    if (!hasError) {
      debugPrint("🧱 [BUILD] WebView should be visible");
    }

    if (isLoading && !hasError) {
      debugPrint("🧱 [BUILD] Loading spinner visible");
    }

    if (hasError) {
      debugPrint("🧱 [BUILD] Error UI visible → $errorMessage");
    }

    // ---- UI ----
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.gameName),
      ),
      body: Stack(
        children: [
          if (!hasError)
            WebViewWidget(controller: controller),

          if (isLoading && !hasError)
            const Center(child: CircularProgressIndicator()),

          if (hasError)
            Center(
              child: Text(
                errorMessage ?? 'Error',
                style: const TextStyle(color: Colors.red),
              ),
            ),
        ],
      ),
    );
  }
}