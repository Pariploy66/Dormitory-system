import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// ThaidLoginScreen — in-app webview that hosts the ThaID sign-in page.
// Intercepts the redirect back to redirect_uri, captures the `code` query param,
// and pops it back to the caller. client_secret never touches the app — the code
// is forwarded to NestJS which performs the token exchange.
// ═══════════════════════════════════════════════════════════════════════════════

class ThaidLoginScreen extends StatefulWidget {
  final String authUrl;
  const ThaidLoginScreen({super.key, required this.authUrl});

  @override
  State<ThaidLoginScreen> createState() => _ThaidLoginScreenState();
}

class _ThaidLoginScreenState extends State<ThaidLoginScreen> {
  late final WebViewController _controller;
  late final String _redirectPrefix;
  bool _done = false;

  @override
  void initState() {
    super.initState();
    // The redirect_uri is embedded in the auth URL the backend built.
    _redirectPrefix =
        Uri.parse(widget.authUrl).queryParameters['redirect_uri'] ?? '';

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) {
            final code = _extractCode(request.url);
            if (code != null) {
              _finish(code);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.authUrl));
  }

  /// Return the `code` only when navigating to our registered redirect_uri.
  String? _extractCode(String url) {
    if (_redirectPrefix.isEmpty || !url.startsWith(_redirectPrefix)) return null;
    return Uri.parse(url).queryParameters['code'];
  }

  void _finish(String code) {
    if (_done) return;
    _done = true;
    Navigator.of(context).pop(code);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ThaID'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
