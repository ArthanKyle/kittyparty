import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/material.dart';

class GameWebView extends StatefulWidget {
  final String url;
  const GameWebView({super.key, required this.url});

  @override
  State<GameWebView> createState() => _GameWebViewState();
}

class _GameWebViewState extends State<GameWebView> {
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Game')),
      body: WebViewWidget(controller: controller),
    );
  }
}
