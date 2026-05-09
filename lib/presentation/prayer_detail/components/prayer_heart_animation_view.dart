import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class _FloatingHeart {
  final double x;
  final double y;
  final double size;
  final double duration;
  final double delay;
  final Color color;

  _FloatingHeart({
    required this.x,
    required this.y,
    required this.size,
    required this.duration,
    required this.delay,
    required this.color,
  });
}

class PrayerHeartAnimationView extends StatefulWidget {
  final int participationCount;
  final VoidCallback onFinished;

  const PrayerHeartAnimationView({
    super.key,
    required this.participationCount,
    required this.onFinished,
  });

  @override
  State<PrayerHeartAnimationView> createState() =>
      _PrayerHeartAnimationViewState();
}

class _PrayerHeartAnimationViewState extends State<PrayerHeartAnimationView> {
  static const _heartColors = [
    AppColors.customBlue1,
    Color(0xB34A90E2),
    Color(0x801C3D5A),
    Color(0x992196F3),
  ];

  late final List<_FloatingHeart> _hearts;
  bool _showText = false;
  bool _fadeOut = false;

  @override
  void initState() {
    super.initState();
    final rng = Random();
    _hearts = List.generate(12, (i) {
      return _FloatingHeart(
        x: 0.1 + rng.nextDouble() * 0.8,
        y: 0.15 + rng.nextDouble() * 0.7,
        size: 12 + rng.nextDouble() * 10,
        duration: 0.6 + rng.nextDouble() * 0.3,
        delay: i * 0.05 + rng.nextDouble() * 0.02,
        color: _heartColors[rng.nextInt(_heartColors.length)],
      );
    });
    _runAnimation();
  }

  Future<void> _runAnimation() async {
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    setState(() => _showText = true);

    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() => _fadeOut = true);

    await Future.delayed(const Duration(milliseconds: 250));
    if (!mounted) return;
    widget.onFinished();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              ..._hearts.map((heart) => _HeartParticle(
                    heart: heart,
                    fadeOut: _fadeOut,
                    parentWidth: constraints.maxWidth,
                    parentHeight: constraints.maxHeight,
                  )),
              if (_showText)
                Center(
                  child: AnimatedOpacity(
                    opacity: _fadeOut ? 0 : 1,
                    duration: const Duration(milliseconds: 300),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.8, end: 1.0),
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeIn,
                      builder: (context, scale, child) {
                        return Transform.scale(scale: scale, child: child);
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.auto_awesome, size: 36, color: Colors.grey[700]),
                          const SizedBox(height: 12),
                          Text(
                            '${widget.participationCount}명이 기도했어요',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.black87,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _HeartParticle extends StatefulWidget {
  final _FloatingHeart heart;
  final bool fadeOut;
  final double parentWidth;
  final double parentHeight;

  const _HeartParticle({
    required this.heart,
    required this.fadeOut,
    required this.parentWidth,
    required this.parentHeight,
  });

  @override
  State<_HeartParticle> createState() => _HeartParticleState();
}

class _HeartParticleState extends State<_HeartParticle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    final h = widget.heart;
    final totalDur = h.delay + h.duration + 0.4;

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: (totalDur * 1000).toInt()),
    );

    final dFrac = h.delay / totalDur;
    final sFrac = (h.delay + 0.4) / totalDur;

    _scaleAnim = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween(0.0), weight: dFrac * 100),
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.15).chain(CurveTween(curve: Curves.easeOut)),
        weight: (sFrac - dFrac) * 50,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.15, end: 1.0).chain(CurveTween(curve: Curves.elasticOut)),
        weight: (sFrac - dFrac) * 50,
      ),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: (1.0 - sFrac) * 100),
    ]).animate(_controller);

    final fFrac = (h.delay + h.duration) / totalDur;
    _fadeAnim = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween(1.0), weight: fFrac * 100),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.0).chain(CurveTween(curve: Curves.easeOut)),
        weight: (1.0 - fFrac) * 100,
      ),
    ]).animate(_controller);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final h = widget.heart;
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, child) {
        return Positioned(
          left: widget.parentWidth * h.x - h.size / 2,
          top: widget.parentHeight * h.y - h.size / 2,
          child: Opacity(
            opacity: widget.fadeOut ? 0.0 : _fadeAnim.value,
            child: Transform.scale(
              scale: _scaleAnim.value,
              child: child,
            ),
          ),
        );
      },
      child: Icon(Icons.favorite, size: h.size, color: h.color),
    );
  }
}
