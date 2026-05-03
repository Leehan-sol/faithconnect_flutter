import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/providers.dart';
import '../components/labeled_text_field.dart';
import '../components/action_button.dart';
import '../components/loading_dialog.dart';
import 'reset_password_view.dart';

/// iOS FindPasswordView.swift 대응
class FindPasswordView extends ConsumerStatefulWidget {
  final String? initialEmail;

  const FindPasswordView({super.key, this.initialEmail});

  @override
  ConsumerState<FindPasswordView> createState() => _FindPasswordViewState();
}

class _FindPasswordViewState extends ConsumerState<FindPasswordView> {
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialEmail != null) {
      _emailController.text = widget.initialEmail!;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _requestReset() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _showAlert('입력 오류', '이메일을 입력해주세요.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final authUseCase = ref.read(authUseCaseProvider);
      await authUseCase.requestPasswordReset(email: email);
      setState(() => _isLoading = false);
      _showAlert('전송 완료', '인증 코드가 이메일로 전송되었습니다.', onConfirm: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ResetPasswordView(email: email),
          ),
        );
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
            title: const Text('비밀번호 찾기'),
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
                    '등록된 이메일 주소로\n비밀번호 재설정 링크를 보내드립니다',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 20),
                  LabeledTextField(
                    title: '이메일',
                    placeholder: '이메일을 입력하세요',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 20),
                  ActionButton(
                    title: '재설정 링크 전송',
                    foregroundColor: Colors.white,
                    backgroundColor: AppColors.customBlue1,
                    onPressed: _requestReset,
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '이메일이 도착하지 않으면 스팸 메일함을 확인해주세요.',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
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
