// import 'package:flutter/material.dart';
// import 'package:webview_flutter/webview_flutter.dart';

// class WebViewPage extends StatefulWidget {
//   final String title;
//   final String initialUrl;

//   const WebViewPage({
//     super.key,
//     required this.title,
//     required this.initialUrl,
//   });

//   @override
//   State<WebViewPage> createState() => _WebViewPageState();
// }

// class _WebViewPageState extends State<WebViewPage> {
//   late final WebViewController _controller;
//   double _progress = 0;

//   @override
//   void initState() {
//     super.initState();
//     _controller = WebViewController()
//       ..setJavaScriptMode(JavaScriptMode.unrestricted)
//       ..setBackgroundColor(const Color(0x00000000))
//       ..setNavigationDelegate(
//         NavigationDelegate(
//           onProgress: (p) => setState(() => _progress = p / 100),
//           onPageStarted: (_) {},
//           onPageFinished: (_) => setState(() => _progress = 1),
//         ),
//       )
//       ..loadRequest(Uri.parse(widget.initialUrl));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.title),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.refresh),
//             onPressed: () => _controller.reload(),
//           ),
//         ],
//         bottom: PreferredSize(
//           preferredSize: const Size.fromHeight(3),
//           child: _progress < 1
//               ? LinearProgressIndicator(value: _progress)
//               : const SizedBox.shrink(),
//         ),
//       ),
//       body: WebViewWidget(controller: _controller),
//     );
//   }
// }
