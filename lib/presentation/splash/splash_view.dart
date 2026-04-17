import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView>
    with TickerProviderStateMixin {
  static const _text = 'FaithConnect';
  int _animatedIndex = -1;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startAnimation();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startAnimation() {
    // 글자별 0.1초 간격으로 등장
    for (int i = 0; i < _text.length; i++) {
      Timer(Duration(milliseconds: i * 100), () {
        if (!mounted) return;
        setState(() => _animatedIndex = i);
      });
    }

    // 모든 글자 등장 + 1초 유지 → 페이드아웃 후 반복
    final totalMs = _text.length * 100 + 1000;
    _timer = Timer(Duration(milliseconds: totalMs), () {
      if (!mounted) return;
      setState(() => _animatedIndex = -1);
      Timer(const Duration(milliseconds: 600), () {
        if (!mounted) return;
        _startAnimation();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.customBlue1,
      body: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(_text.length, (index) {
            final visible = _animatedIndex >= index;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              transform: Matrix4.translationValues(0, visible ? 0 : 5, 0),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                opacity: visible ? 1.0 : 0.1,
                child: Text(
                  _text[index],
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
