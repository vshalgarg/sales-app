
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewScreen extends StatefulWidget {
  final String title;
  final String assetPath;

  const WebViewScreen({
    super.key,
    required this.title,
    required this.assetPath,
  });

  @override
  State<WebViewScreen> createState() =>
      _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController controller;
  int loadingProgress = 0;

  @override
  void initState() {
    super.initState();

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (progress) {
            if (mounted) {
              setState(() {
                loadingProgress = progress;
              });
            }
          },
          onNavigationRequest: (request) {
            if (request.url.endsWith('/privacy-policy')) {
              controller.loadFlutterAsset(
                'assets/html/privacy_policy.html',
              );
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
        ),
      );

    loadPage();
  }

  Future<void> loadPage() async {
    await controller.loadFlutterAsset(widget.assetPath);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        elevation: 0,
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: controller),

          if (loadingProgress < 100)
            LinearProgressIndicator(
              value: loadingProgress / 100,
            ),
        ],
      ),
    );
  }
}
