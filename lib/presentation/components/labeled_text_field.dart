import 'package:flutter/material.dart';

/// iOS LabeledTextField 대응
/// SwiftUI: VStack { Text(title) + TextField/SecureField }
/// Flutter: Column { Text + TextField }
///
/// 핵심 차이:
/// - SwiftUI는 @Binding으로 양방향 바인딩 → Flutter는 TextEditingController 사용
/// - SwiftUI SecureField → Flutter TextField의 obscureText 속성
/// - SwiftUI .background(Color(.systemGray6)) → Flutter fillColor + filled
class LabeledTextField extends StatefulWidget {
  final String title;
  final String placeholder;
  final bool isSecure;
  final TextInputType keyboardType;
  final TextEditingController controller;
  final String? errorText;
  final ValueChanged<String>? onChanged;

  const LabeledTextField({
    super.key,
    required this.title,
    required this.placeholder,
    required this.controller,
    this.isSecure = false,
    this.keyboardType = TextInputType.text,
    this.errorText,
    this.onChanged,
  });

  @override
  State<LabeledTextField> createState() => _LabeledTextFieldState();
}

class _LabeledTextFieldState extends State<LabeledTextField> {
  bool _obscured = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 타이틀 라벨
        Text(
          widget.title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        // 입력 필드
        TextField(
          controller: widget.controller,
          keyboardType: widget.keyboardType,
          obscureText: widget.isSecure && _obscured,
          autocorrect: false,
          onChanged: widget.onChanged,
          decoration: InputDecoration(
            hintText: widget.placeholder,
            hintStyle: TextStyle(color: Colors.grey.shade400),
            filled: true,
            fillColor: Colors.grey.shade100, // systemGray6 대응
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            // 에러 상태일 때 빨간 테두리
            enabledBorder: widget.errorText != null
                ? OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.red),
                  )
                : OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: widget.errorText != null ? Colors.red : Colors.blue,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            suffixIcon: widget.isSecure
                ? IconButton(
                    icon: Icon(
                      _obscured ? Icons.visibility : Icons.visibility_off,
                      color: Colors.grey.shade600,
                    ),
                    onPressed: () {
                      setState(() => _obscured = !_obscured);
                    },
                  )
                : null,
          ),
        ),
        // 에러 메시지
        if (widget.errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              widget.errorText!,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }
}
