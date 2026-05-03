import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../components/labeled_text_field.dart';
import '../components/action_button.dart';
import '../components/loading_dialog.dart';
import 'login_notifier.dart';

/// iOS LoginView 대응 — Phase 2: Riverpod 상태관리 연결
///
/// === SwiftUI 비교 ===
/// iOS: .alert(item: $viewModel.alertType) { alert in Alert(...) }
/// Flutter: ref.listen()으로 상태 변화 감지 → showDialog()
///
/// ref.listen vs ref.watch:
///  - watch: 상태 바뀌면 build() 재실행 (UI 반영용)
///  - listen: 상태 바뀌면 콜백 실행 (사이드이펙트용 — 다이얼로그, 네비게이션 등)
class LoginView extends ConsumerStatefulWidget {
  const LoginView({super.key});

  @override
  ConsumerState<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends ConsumerState<LoginView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(loginNotifierProvider);
    final notifier = ref.read(loginNotifierProvider.notifier);

    // ref.listen: alertMessage가 생기면 다이얼로그 표시
    // iOS의 .alert(item: $viewModel.alertType) 대응
    ref.listen(loginNotifierProvider, (prev, next) {
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
                },
                child: const Text('확인'),
              ),
            ],
          ),
        );
      }
    });

    // iOS: ZStack { VStack { ... }.disabled(isLoading)  if isLoading { LoadingDialogView() } }
    return Stack(
      children: [
        AbsorbPointer(
          absorbing: loginState.isLoading,
          child: Scaffold(
            backgroundColor: Colors.white,
            body: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: SafeArea(
                child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      const SizedBox(height: 30),

                      Image.asset(
                        'assets/images/heart_icon.png',
                        width: 120,
                        height: 120,
                      ),
                      const SizedBox(height: 20),

                      const Text(
                        'Faith Connect',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),

                      Text(
                        '함께 기도하는 우리 교회',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 20),

                      LabeledTextField(
                        title: '이메일',
                        placeholder: '이메일을 입력하세요',
                        controller: _emailController,
                        onChanged: notifier.setEmail,
                      ),
                      const SizedBox(height: 20),

                      LabeledTextField(
                        title: '비밀번호',
                        placeholder: '비밀번호를 입력하세요',
                        isSecure: true,
                        controller: _passwordController,
                        onChanged: notifier.setPassword,
                      ),
                      const SizedBox(height: 20),

                      Row(
                        children: [
                          TextButton(
                            onPressed: () => context.push('/find-id'),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text(
                              '이메일 찾기',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              '|',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade400,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () => context.push('/find-password'),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text(
                              '비밀번호 찾기',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      ActionButton(
                        title: '로그인',
                        foregroundColor: Colors.white,
                        backgroundColor: AppColors.customBlue1,
                        onPressed: notifier.login,
                      ),
                      const SizedBox(height: 16),

                      TextButton(
                        onPressed: () => context.push('/signup'),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '계정이 없으신가요? 회원가입',
                              style: TextStyle(
                                color: AppColors.customBlue1,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.chevron_right,
                              size: 18,
                              color: AppColors.customBlue1,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: TextButton(
                  onPressed: () {},
                  child: Text(
                    '문의하기',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
        ),
        if (loginState.isLoading) const LoadingDialog(),
      ],
    );
  }
}
