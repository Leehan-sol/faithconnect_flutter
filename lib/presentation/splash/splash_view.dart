import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class SplashView extends StatefulWidget {
  final VoidCallback? onComplete;

  const SplashView({super.key, this.onComplete});

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
    for (int i = 0; i < _text.length; i++) {
      Timer(Duration(milliseconds: i * 100), () {
        if (!mounted) return;
        setState(() => _animatedIndex = i);
      });
    }

    final totalMs = _text.length * 100 + 1000;
    _timer = Timer(Duration(milliseconds: totalMs), () {
      if (!mounted) return;
      widget.onComplete?.call();
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
