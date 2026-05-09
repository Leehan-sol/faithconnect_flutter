import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class SplashView extends StatefulWidget {
  final VoidCallback? onComplete;

  const SplashView({super.key, this.onComplete});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  static const _text = 'FaithConnect';
  int _animatedIndex = -1;
  bool _calledComplete = false;

  @override
  void initState() {
    super.initState();
    _startAnimation();
  }

  void _startAnimation() {
    // 글자 하나씩 페이드인
    for (int i = 0; i < _text.length; i++) {
      Timer(Duration(milliseconds: i * 100), () {
        if (!mounted) return;
        setState(() => _animatedIndex = i);
      });
    }

    final totalMs = _text.length * 100 + 1000;

    // 첫 사이클 완료 시 onComplete 호출
    if (!_calledComplete) {
      Timer(Duration(milliseconds: totalMs), () {
        if (!mounted) return;
        _calledComplete = true;
        widget.onComplete?.call();
      });
    }

    // 페이드아웃 후 다시 반복
    Timer(Duration(milliseconds: totalMs), () {
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
