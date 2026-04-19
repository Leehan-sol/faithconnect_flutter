import 'package:flutter/material.dart';

/// iOS ActionButton 대응
/// SwiftUI: Button { Text().foregroundColor().bold().frame().padding().background().cornerRadius() }
/// Flutter: SizedBox(width: double.infinity) + ElevatedButton
///
/// 핵심 차이:
/// - SwiftUI는 .frame(maxWidth: .infinity)로 전체 너비 → Flutter는 SizedBox(width: double.infinity)
/// - SwiftUI는 수식어 체인 → Flutter는 ElevatedButton.styleFrom()으로 한번에
class ActionButton extends StatelessWidget {
  final String title;
  final Color foregroundColor;
  final Color backgroundColor;
  final VoidCallback? onPressed;

  const ActionButton({
    super.key,
    required this.title,
    required this.foregroundColor,
    required this.backgroundColor,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          foregroundColor: foregroundColor,
          backgroundColor: backgroundColor,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
