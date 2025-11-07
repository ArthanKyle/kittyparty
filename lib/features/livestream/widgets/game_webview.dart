import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

class GameWebView extends StatefulWidget {
  final String url;
  final String gameName;

  const GameWebView({
    super.key,
    required this.url,
    required this.gameName,
  });

  @override
  State<GameWebView> createState() => _GameWebViewState();
}

class _GameWebViewState extends State<GameWebView> {
  late final WebViewController controller;
  bool isLoading = true;
  bool hasError = false;
  String? errorMessage;

  final String backendUrl = "https://kittypartybackend-production.up.railway.app";

  @override
  void initState() {
    super.initState();

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..enableZoom(false)
      ..setBackgroundColor(Colors.black)
      ..addJavaScriptChannel(
        "GameBridge",
        onMessageReceived: (msg) {
          debugPrint("🎮 Game Message: ${msg.message}");
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            setState(() {
              isLoading = true;
              hasError = false;
            });
          },
          onPageFinished: (_) async {
            // Inject our proxy script after page loads
            await controller.runJavaScript(_jsProxyCode(backendUrl));
            setState(() => isLoading = false);
          },
          onWebResourceError: (error) {
            debugPrint('❌ WebView error: ${error.description}');
            setState(() {
              hasError = true;
              isLoading = false;
              errorMessage = error.description;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  String _jsProxyCode(String base) {
    return """
      (function() {
        const backend = "$base";

        // Patch fetch
        const originalFetch = window.fetch;
        window.fetch = function(resource, options) {
          if (typeof resource === 'string' && resource.startsWith('/v1/api/')) {
            resource = backend + resource;
          }
          return originalFetch(resource, options);
        };

        // Patch XMLHttpRequest
        const originalOpen = XMLHttpRequest.prototype.open;
        XMLHttpRequest.prototype.open = function(method, url) {
          if (typeof url === 'string' && url.startsWith('/v1/api/')) {
            arguments[1] = backend + url;
          }
          return originalOpen.apply(this, arguments);
        };

        console.log('✅ Game API proxy enabled to:', backend);
      })();
    """;
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _reloadGame() {
    setState(() {
      hasError = false;
      isLoading = true;
    });
    controller.reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.gameName)),
      body: Stack(
        children: [
          if (!hasError)
            WebViewWidget(controller: controller),

          if (isLoading)
            const Center(
              child: CircularProgressIndicator(color: Colors.purpleAccent),
            ),

          if (hasError)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.wifi_off, size: 48, color: Colors.redAccent),
                  const SizedBox(height: 12),
                  Text(
                    "Connection lost.\nPlease reopen or refresh the game.",
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _reloadGame,
                    icon: const Icon(Icons.refresh),
                    label: const Text("Try Again"),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
