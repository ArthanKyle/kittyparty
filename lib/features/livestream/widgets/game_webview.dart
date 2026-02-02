import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kittyparty/features/livestream/widgets/game_modal.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import '../../../core/config/game_config.dart';

//Qianmu
void ShowGameUrl(
    BuildContext context,
    String url,
    GameConfigModel config,
    double safeHeight, // 👈 SH from backend
    ) {
  final screenWidth = MediaQuery.of(context).size.width;

  // === Native-equivalent computation ===
  final double ratio = 750 / safeHeight;
  final double webViewHeight = screenWidth / ratio;
  final mediaQuery = MediaQuery.of(context);

  showModalBottomSheet(
    backgroundColor: Colors.transparent,
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return SizedBox(
        width: screenWidth,
        height: mediaQuery.size.height,
        child: GameWebViewPage(
          url: url,
          config: config,
        ),
      );
    },
  );
}


class GameWebViewPage extends StatefulWidget {
  const GameWebViewPage({
    super.key,
    required this.url,
    required this.config,
  });

  final String url;
  final GameConfigModel config;

  @override
  _GameWebViewPageState createState() => _GameWebViewPageState();
}

class _GameWebViewPageState extends State<GameWebViewPage> {
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..loadRequest(Uri.parse(widget.url));

    EventChannel _eventChannelPlugin = EventChannel('baishunChannel');
    if (Platform.isAndroid) {
      _eventChannelPlugin.receiveBroadcastStream().listen((event) {
        final obj = json.decode(event);
        String jsFunName = obj['jsCallback'];
        if (jsFunName.contains('getConfig')) {
          print("BSGAME 游戏调⽤getConfig main.dart");
          String jsUrl = jsFunName + "(${jsonEncode(widget.config.toJson())})";
          controller!.runJavaScript(jsUrl);
        } else if (jsFunName.contains('destroy')) {
          print("BSGAME 游戏调⽤destroy main.dart");
          //关闭游戏 TODO 客⼾端
          Navigator.pop(context);
        } else if (jsFunName.contains('gameRecharge')) {
          print("BSGAME 游戏调⽤gameRecharge main.dart");
          //拉起⽀付商城 TODO 客⼾端
        } else if (jsFunName.contains('gameLoaded')) {
          print("BSGAME 游戏调⽤gameLoaded main.dart");
          //游戏加载完毕 TODO 客⼾端
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(controller: controller);
  }
}
