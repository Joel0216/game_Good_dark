import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

class MinigameGamePage extends StatefulWidget {
  const MinigameGamePage({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(builder: (_) => const MinigameGamePage());
  }

  @override
  State<MinigameGamePage> createState() => _MinigameGamePageState();
}

class _MinigameGamePageState extends State<MinigameGamePage> {
  late final WebViewController _controller;
  double _loadingProgress = 0;

  @override
  void initState() {
    super.initState();

    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final WebViewController controller =
        WebViewController.fromPlatformCreationParams(params);

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            setState(() {
              _loadingProgress = progress / 100;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _loadingProgress = 1;
            });
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('Error de recurso web: ${error.description}');
          },
        ),
      )
      // 🚨 CAMBIE ESTA URL por la dirección real de su juego web
      ..loadRequest(Uri.parse('https://su-url-real-del-minijuego-web.com/')); 

    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }

    _controller = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'CIRUGÍA PROYECT CASANDRA',
          style: TextStyle(color: Color(0xFF00FFFF)),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF00FFFF)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          // 1. WebView para cargar el juego web
          WebViewWidget(controller: _controller),
          
          // 2. Barra de carga
          if (_loadingProgress < 1.0)
            LinearProgressIndicator(
              value: _loadingProgress,
              color: const Color(0xFF00FFFF),
              backgroundColor: Colors.black,
            ),
        ],
      ),
    );
  }
}
