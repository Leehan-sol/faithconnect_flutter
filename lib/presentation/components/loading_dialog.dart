import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// iOS LoadingDialogView 대응
/// 반투명 배경 + 중앙 카드에 아이콘 + "연결 중..." 텍스트
class LoadingDialog extends StatelessWidget {
  const LoadingDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.15),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.group,
                size: 50,
                color: AppColors.customBlue1,
              ),
              const SizedBox(height: 15),
              Text(
                '연결 중...',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.customBlue1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
