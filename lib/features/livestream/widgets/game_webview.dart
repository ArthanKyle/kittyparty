import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

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

  bool _authInProgress = false;
  bool _authCompleted = false;

  late final String backendBaseUrl;
  late final int baishunAppId;
  late final String baishunAppKey;

  String? _lastSsToken;

  static const EventChannel _bsEventChannel = EventChannel('kitty');

  // ===========================
  // INIT
  // ===========================
  @override
  void initState() {
    super.initState();

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    backendBaseUrl = _normalizeBaseUrl(dotenv.env['BASE_URL'] ?? '');
    baishunAppId = int.parse(dotenv.env['BAISHUN_APP_ID']!);
    baishunAppKey = dotenv.env['BAISHUN_APP_KEY']!;

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..enableZoom(false)
      ..addJavaScriptChannel(
        'KITTY',
        onMessageReceived: (msg) {
          debugPrint("🟣 JS LOG: ${msg.message}");
        },
      )
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
            // 1️⃣ Inject console.log bridge
            await controller.runJavaScript(_consoleBridge());

            // 2️⃣ Inject auth hooks
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

    _bsSub = _bsEventChannel
        .receiveBroadcastStream()
        .listen(_onNativeEvent);
  }

  // ===========================
  // JS CONSOLE BRIDGE
  // ===========================
  String _consoleBridge() {
    return """
  (function () {
    if (window.__KP_CONSOLE_BOUND__) return;
    window.__KP_CONSOLE_BOUND__ = true;
  
    const oldLog = console.log;
    console.log = function () {
      try {
        window.KITTY.postMessage(JSON.stringify({
          type: 'log',
          data: Array.from(arguments)
        }));
      } catch (e) {}
      oldLog.apply(console, arguments);
    };
  
    const oldErr = console.error;
    console.error = function () {
      try {
        window.KITTY.postMessage(JSON.stringify({
          type: 'error',
          data: Array.from(arguments)
        }));
      } catch (e) {}
      oldErr.apply(console, arguments);
    };
  })();
  """;
  }

  // ===========================
  // URL HELPERS
  // ===========================
  String _normalizeBaseUrl(String url) {
    var u = url.trim();
    while (u.endsWith('/')) {
      u = u.substring(0, u.length - 1);
    }
    return u;
  }

  Uri _games(String path) =>
      Uri.parse('$backendBaseUrl/games/${path.startsWith('/') ? path.substring(1) : path}');

  // ===========================
  // AUTH HOOKS
  // ===========================
  String _authHooks() {
    final ss = _lastSsToken ?? '';
    final uid = widget.userId;
    final host = Uri.parse(backendBaseUrl).host;

    return """
(function () {
  window.__KP_SSTOKEN__ = ${jsonEncode(ss)};
  window.__KP_USERID__ = ${jsonEncode(uid)};

  function isBackend(url) {
    try {
      return new URL(url, location.href).host === "$host";
    } catch (e) {
      return false;
    }
  }

  const oldFetch = window.fetch;
  if (oldFetch) {
    window.fetch = function (input, init) {
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

  // ===========================
  // BACKEND CALLS
  // ===========================
  int _timestampSeconds() =>
      DateTime.now().millisecondsSinceEpoch ~/ 1000;

  String _randomNonce({int length = 24}) {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rnd = Random.secure();
    return List.generate(length, (_) => chars[rnd.nextInt(chars.length)]).join();
  }

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
    final ts = _timestampSeconds();
    final nonce = _randomNonce();
    final raw = '$nonce$baishunAppKey$ts';
    final signature = md5.convert(utf8.encode(raw)).toString();

    final resp = await http.post(
      _games('v1/api/get_sstoken'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'app_id': baishunAppId,
        'user_id': userId,
        'code': otp,
        'timestamp': ts,
        'signature_nonce': nonce,
        'signature': signature,
      }),
    );

    final body = jsonDecode(resp.body);
    if (body['code'] != 0) throw Exception(body['message']);

    return body['data']['ss_token'];
  }

  Future<void> _pushAuth(String token) async {
    _lastSsToken = token;
    await controller.runJavaScript(_authHooks());
  }

  // ===========================
  // NATIVE EVENTS
  // ===========================
  void _onNativeEvent(dynamic event) async {
    if (_authInProgress || _authCompleted) return;

    _authInProgress = true;

    try {
      final obj = jsonDecode(event as String);
      final jsCallback = obj['jsCallback'] ?? 'onGetConfig';

      final gen = await _generateOtpAndBalance();
      final ssToken = await _exchangeOtpToSsToken(
        otp: gen['otp'],
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
        code: gen['otp'],
        balance: gen['balance'],
        gameConfig: GameConfig(sceneMode: 0, currencyIcon: ''),
      );

      await controller.runJavaScript(
        '$jsCallback(${jsonEncode(config.toJson())});',
      );

      _authCompleted = true;
      debugPrint("✅ ss_token issued and config sent");
    } catch (e) {
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
    return Scaffold(
      appBar: AppBar(title: Text(widget.gameName)),
      body: Stack(
        children: [
          if (!hasError) WebViewWidget(controller: controller),
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
