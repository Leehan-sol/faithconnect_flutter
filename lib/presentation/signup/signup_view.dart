import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../components/labeled_text_field.dart';
import '../components/action_button.dart';
import '../components/loading_dialog.dart';
import 'signup_notifier.dart';

/// iOS SignUpView.swift 대응
class SignUpView extends ConsumerStatefulWidget {
  const SignUpView({super.key});

  @override
  ConsumerState<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends ConsumerState<SignUpView> {
  final _nameController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _nicknameController.dispose();
    _emailController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(signUpNotifierProvider);
    final notifier = ref.read(signUpNotifierProvider.notifier);

    ref.listen(signUpNotifierProvider, (prev, next) {
      if (next.alertMessage != null && prev?.alertMessage == null) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text(next.alertTitle ?? ''),
            content: Text(next.alertMessage!),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  notifier.clearAlert();
                  if (next.signUpSuccess) {
                    Navigator.of(context).pop(); // 회원가입 화면 닫기
                  }
                },
                child: const Text('확인'),
              ),
            ],
          ),
        );
      }
    });

    return Stack(
      children: [
        AbsorbPointer(
          absorbing: state.isLoading,
          child: Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              title: const Text('회원가입'),
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 0,
            ),
            body: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '회원가입을 위해\n정보를 입력해 주세요',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 20),

                    LabeledTextField(
                      title: '이름',
                      placeholder: '이름을 입력하세요',
                      controller: _nameController,
                      onChanged: notifier.setName,
                    ),
                    const SizedBox(height: 10),

                    LabeledTextField(
                      title: '닉네임',
                      placeholder: '닉네임을 입력하세요',
                      controller: _nicknameController,
                      onChanged: notifier.setNickname,
                    ),
                    const SizedBox(height: 10),

                    // 이메일 + 인증
                    const Text(
                      '이메일',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            autocorrect: false,
                            enabled: !state.isEmailVerified,
                            onChanged: notifier.setEmail,
                            decoration: InputDecoration(
                              hintText: '이메일을 입력하세요',
                              hintStyle: TextStyle(color: Colors.grey.shade400),
                              filled: true,
                              fillColor: Colors.grey.shade100,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 16),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 90,
                          child: ElevatedButton(
                            onPressed: state.isEmailVerified
                                ? null
                                : notifier.requestEmailVerification,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: state.isEmailVerified
                                  ? Colors.grey
                                  : AppColors.customBlue1,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              state.isVerificationCodeSent ? '재전송' : '인증요청',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    if (state.isVerificationCodeSent && !state.isEmailVerified) ...[
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _codeController,
                              keyboardType: TextInputType.number,
                              onChanged: notifier.setVerificationCode,
                              decoration: InputDecoration(
                                hintText: '인증 코드를 입력하세요',
                                hintStyle: TextStyle(color: Colors.grey.shade400),
                                filled: true,
                                fillColor: Colors.grey.shade100,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 16),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 90,
                            child: ElevatedButton(
                              onPressed: notifier.confirmEmailVerification,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.customBlue1,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text(
                                '확인',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],

                    if (state.isEmailVerified) ...[
                      const SizedBox(height: 8),
                      const Text(
                        '이메일 인증이 완료되었습니다.',
                        style: TextStyle(fontSize: 12, color: Colors.green),
                      ),
                    ],

                    const SizedBox(height: 10),

                    LabeledTextField(
                      title: '비밀번호',
                      placeholder: '영문, 숫자 포함 8자 이상',
                      isSecure: true,
                      controller: _passwordController,
                      onChanged: notifier.setPassword,
                    ),
                    const SizedBox(height: 10),

                    LabeledTextField(
                      title: '비밀번호 확인',
                      placeholder: '비밀번호를 다시 입력하세요',
                      isSecure: true,
                      controller: _confirmPasswordController,
                      onChanged: notifier.setConfirmPassword,
                    ),
                    const SizedBox(height: 20),

                    ActionButton(
                      title: '회원가입',
                      foregroundColor: Colors.white,
                      backgroundColor:
                          state.isEmailVerified ? AppColors.customBlue1 : Colors.grey,
                      onPressed: state.isEmailVerified ? notifier.signUp : null,
                    ),
                    const SizedBox(height: 20),

                    // 안내 박스
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _infoText('• 이메일은 인증 목적으로만 사용되며 다른 사용자에게 공개되지 않습니다.'),
                          _infoText('• 이름은 본인 확인 용도로만 사용됩니다.'),
                          _infoText('• 닉네임은 다른 사용자에게 표시될 수 있습니다.'),
                          _infoText('• 개인정보는 안전하게 보호됩니다.'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (state.isLoading) const LoadingDialog(),
      ],
    );
  }

  Widget _infoText(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
      ),
    );
  }
}
