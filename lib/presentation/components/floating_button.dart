import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// iOS FloatingButton 대응
class FloatingButton extends StatelessWidget {
  final VoidCallback onPressed;

  const FloatingButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: AppColors.customBlue1.withValues(alpha: 0.8),
      shape: const CircleBorder(),
      child: const Icon(Icons.add, color: Colors.white, size: 24),
    );
  }
}
