import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/providers.dart';
import '../components/labeled_text_field.dart';
import '../components/action_button.dart';
import '../components/loading_dialog.dart';

/// iOS ResetPasswordView.swift 대응
class ResetPasswordView extends ConsumerStatefulWidget {
  final String email;
  final VoidCallback? onSuccess;

  const ResetPasswordView({super.key, required this.email, this.onSuccess});

  @override
  ConsumerState<ResetPasswordView> createState() => _ResetPasswordViewState();
}

class _ResetPasswordViewState extends ConsumerState<ResetPasswordView> {
  final _codeController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _codeController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    final code = _codeController.text.trim();
    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (code.isEmpty) {
      _showAlert('입력 오류', '인증코드를 입력해주세요.');
      return;
    }
    if (newPassword.isEmpty) {
      _showAlert('입력 오류', '새 비밀번호를 입력해주세요.');
      return;
    }
    if (newPassword != confirmPassword) {
      _showAlert('입력 오류', '비밀번호가 일치하지 않습니다.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final authUseCase = ref.read(authUseCaseProvider);
      await authUseCase.confirmPasswordReset(
        email: widget.email,
        code: code,
        newPassword: newPassword,
      );
      setState(() => _isLoading = false);
      _showAlert('완료', '비밀번호가 재설정되었습니다.', onConfirm: () {
        if (widget.onSuccess != null) {
          widget.onSuccess!();
        } else {
          // 로그인 화면까지 pop
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showAlert('오류', e.toString());
    }
  }

  void _showAlert(String title, String message, {VoidCallback? onConfirm}) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onConfirm?.call();
            },
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: const Text('비밀번호 재설정'),
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
          ),
          body: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '이메일로 전송된 인증코드를 입력하고\n새 비밀번호를 설정해주세요',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 20),
                  LabeledTextField(
                    title: '인증코드',
                    placeholder: '인증코드를 입력하세요',
                    controller: _codeController,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 10),
                  LabeledTextField(
                    title: '새 비밀번호',
                    placeholder: '새 비밀번호를 입력하세요',
                    isSecure: true,
                    controller: _newPasswordController,
                  ),
                  const SizedBox(height: 10),
                  LabeledTextField(
                    title: '새 비밀번호 확인',
                    placeholder: '새 비밀번호를 다시 입력하세요',
                    isSecure: true,
                    controller: _confirmPasswordController,
                  ),
                  const SizedBox(height: 20),
                  ActionButton(
                    title: '완료',
                    foregroundColor: Colors.white,
                    backgroundColor: AppColors.customBlue1,
                    onPressed: _resetPassword,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (_isLoading) const LoadingDialog(),
      ],
    );
  }
}
