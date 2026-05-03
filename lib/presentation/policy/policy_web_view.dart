import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// iOS PolicyWebView.swift 대응 — 로컬 HTML 파일 로드
enum PolicyType {
  terms,
  privacy;

  String get title {
    switch (this) {
      case PolicyType.terms:
        return '이용약관';
      case PolicyType.privacy:
        return '개인정보 처리방침';
    }
  }

  String get assetPath {
    switch (this) {
      case PolicyType.terms:
        return 'assets/terms.html';
      case PolicyType.privacy:
        return 'assets/privacy.html';
    }
  }
}

class PolicyWebView extends StatefulWidget {
  final PolicyType policyType;

  const PolicyWebView({super.key, required this.policyType});

  @override
  State<PolicyWebView> createState() => _PolicyWebViewState();
}

class _PolicyWebViewState extends State<PolicyWebView> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted);
    _loadHtml();
  }

  Future<void> _loadHtml() async {
    final html = await rootBundle.loadString(widget.policyType.assetPath);
    await _controller.loadHtmlString(html);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.policyType.title),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
