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
  late final StreamSubscription _bsSub;

  bool _loading = true;
  bool _fatalError = false;
  String? _error;

  bool _configSent = false;

  late final String backendBaseUrl;
  late final int baishunAppId;
  late final String baishunAppKey;

  static const EventChannel _baishunChannel =
  EventChannel('kitty');

  // =========================
  // INIT
  // =========================
  @override
  void initState() {
    super.initState();

    debugPrint('🟢 [GameWebView] initState');

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    backendBaseUrl = _normalize(dotenv.env['BASE_URL'] ?? '');
    baishunAppId = int.parse(dotenv.env['BAISHUN_APP_ID']!);
    baishunAppKey = dotenv.env['BAISHUN_APP_KEY']!;

    debugPrint('🧩 Config → baseUrl=$backendBaseUrl appId=$baishunAppId');

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            debugPrint('🌐 WebView onPageStarted → $url');
            setState(() => _loading = true);
          },
          onPageFinished: (url) {
            debugPrint('🌐 WebView onPageFinished → $url');
            setState(() => _loading = false);
          },
          onWebResourceError: (e) {
            debugPrint('❌ WebView error → ${e.description}');
            _setFatal(e.description);
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));

    if (controller.platform is AndroidWebViewController) {
      debugPrint('🤖 AndroidWebViewController detected');
      (controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }

    debugPrint('📡 Subscribing to EventChannel');
    _bsSub = _baishunChannel
        .receiveBroadcastStream()
        .listen(
      _onNativeEvent,
      onError: (e) {
        debugPrint('❌ EventChannel error → $e');
      },
    );
  }

  // =========================
  // NATIVE → FLUTTER EVENTS
  // =========================
  Future<void> _onNativeEvent(dynamic event) async {
    debugPrint('📥 Native event received → $event');

    if (_fatalError) {
      debugPrint('⚠️ Ignored event due to fatal error');
      return;
    }

    try {
      final obj = jsonDecode(event as String);
      final jsCallback = obj['jsCallback'] as String;

      debugPrint('🔔 JS Callback → $jsCallback');

      if (jsCallback.contains('getConfig')) {
        if (_configSent) {
          debugPrint('⚠️ getConfig ignored (already sent)');
          return;
        }

        debugPrint('▶️ Handling getConfig');
        await _handleGetConfig(jsCallback);
        _configSent = true;
        debugPrint('✅ getConfig completed');
      }

      else if (jsCallback.contains('destroy')) {
        debugPrint('🧹 destroy called');
        controller.loadRequest(Uri.parse('about:blank'));
        if (mounted) Navigator.of(context).pop();
      }

      else if (jsCallback.contains('gameRecharge')) {
        debugPrint('💰 gameRecharge called');
        // TODO: open payment mall
      }

      else if (jsCallback.contains('gameLoaded')) {
        debugPrint('🎮 gameLoaded event');
      }
    } catch (e, s) {
      debugPrint('❌ Native event handling error → $e');
      debugPrint(s.toString());
      _setFatal(e.toString());
    }
  }

  // =========================
  // GET CONFIG FLOW
  // =========================
  Future<void> _handleGetConfig(String jsCallback) async {
    debugPrint('🔐 Generating OTP');

    final gen = await _generateOtp();

    debugPrint('🔐 OTP received → ${gen['otp']}');
    debugPrint('💰 Balance → ${gen['balance']}');

    debugPrint('🔁 Exchanging OTP for ss_token');
    final ssToken = await _exchangeOtpToSsToken(
      otp: gen['otp'],
      userId: widget.userId,
    );

    debugPrint('🔑 ss_token issued (length=${ssToken.length})');

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

    final js = '$jsCallback(${jsonEncode(config.toJson())});';
    debugPrint('📤 Sending config to JS → $js');

    await controller.runJavaScript(js);
  }

  // =========================
  // BACKEND CALLS
  // =========================
  Uri _api(String path) =>
      Uri.parse('$backendBaseUrl/$path');

  int _ts() => DateTime.now().millisecondsSinceEpoch ~/ 1000;

  String _nonce({int len = 24}) {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final r = Random.secure();
    return List.generate(len, (_) => chars[r.nextInt(chars.length)]).join();
  }

  Future<Map<String, dynamic>> _generateOtp() async {
    debugPrint('🌐 POST generate_code_and_get_balance');

    final r = await http.post(
      _api('games/generate_code_and_get_balance'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'user_id': widget.userId}),
    );

    debugPrint('🌐 OTP response → ${r.body}');

    final b = jsonDecode(r.body);
    if (b['code'] != 0) throw Exception(b['message']);

    return {
      'otp': b['otp'],
      'balance': (b['balance'] as num).toDouble(),
    };
  }

  Future<String> _exchangeOtpToSsToken({
    required String otp,
    required String userId,
  }) async {
    final ts = _ts();
    final nonce = _nonce();
    final raw = '$nonce$baishunAppKey$ts';
    final sign = md5.convert(utf8.encode(raw)).toString();

    debugPrint('🌐 POST get_sstoken ts=$ts nonce=$nonce');

    final r = await http.post(
      _api('games/v1/api/get_sstoken'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'app_id': baishunAppId,
        'user_id': userId,
        'code': otp,
        'timestamp': ts,
        'signature_nonce': nonce,
        'signature': sign,
      }),
    );

    debugPrint('🌐 get_sstoken response → ${r.body}');

    final b = jsonDecode(r.body);
    if (b['code'] != 0) throw Exception(b['message']);

    return b['data']['ss_token'];
  }

  // =========================
  // HELPERS
  // =========================
  String _normalize(String u) {
    var s = u.trim();
    while (s.endsWith('/')) {
      s = s.substring(0, s.length - 1);
    }
    return s;
  }

  void _setFatal(String msg) {
    debugPrint('💥 FATAL ERROR → $msg');
    setState(() {
      _fatalError = true;
      _loading = false;
      _error = msg;
    });
  }

  // =========================
  // DISPOSE
  // =========================
  @override
  void dispose() {
    debugPrint('🧹 GameWebView dispose');
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _bsSub.cancel();
    super.dispose();
  }

  // =========================
  // UI
  // =========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.gameName)),
      body: Stack(
        children: [
          if (!_fatalError) WebViewWidget(controller: controller),
          if (_loading && !_fatalError)
            const Center(child: CircularProgressIndicator()),
          if (_fatalError)
            Center(
              child: Text(
                _error ?? 'Error',
                style: const TextStyle(color: Colors.red),
              ),
            ),
        ],
      ),
    );
  }
}
