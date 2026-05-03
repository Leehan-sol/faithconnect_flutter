import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers.dart';
import 'signup_state.dart';

class SignUpNotifier extends Notifier<SignUpState> {
  @override
  SignUpState build() => const SignUpState();

  void setName(String value) => state = state.copyWith(name: value);
  void setNickname(String value) => state = state.copyWith(nickname: value);
  void setEmail(String value) => state = state.copyWith(email: value);
  void setVerificationCode(String value) =>
      state = state.copyWith(verificationCode: value);
  void setPassword(String value) => state = state.copyWith(password: value);
  void setConfirmPassword(String value) =>
      state = state.copyWith(confirmPassword: value);

  static final _emailRegex = RegExp(r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,64}$');
  static final _passwordRegex = RegExp(r'^(?=.*[A-Za-z])(?=.*\d).{8,}$');

  Future<void> requestEmailVerification() async {
    if (state.email.isEmpty) {
      state = state.copyWith(
        alertTitle: () => '입력 오류',
        alertMessage: () => '이메일을 입력해주세요.',
      );
      return;
    }
    if (!_emailRegex.hasMatch(state.email)) {
      state = state.copyWith(
        alertTitle: () => '입력 오류',
        alertMessage: () => '올바른 이메일 형식이 아닙니다.',
      );
      return;
    }

    state = state.copyWith(isLoading: true);
    try {
      final authUseCase = ref.read(authUseCaseProvider);
      await authUseCase.requestEmailVerification(email: state.email);
      state = state.copyWith(
        isLoading: false,
        isVerificationCodeSent: true,
        alertTitle: () => '인증 메일 전송',
        alertMessage: () => '인증 코드가 이메일로 전송되었습니다.',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        alertTitle: () => '오류',
        alertMessage: () => e.toString(),
      );
    }
  }

  Future<void> confirmEmailVerification() async {
    if (state.verificationCode.isEmpty) {
      state = state.copyWith(
        alertTitle: () => '입력 오류',
        alertMessage: () => '인증 코드를 입력해주세요.',
      );
      return;
    }

    state = state.copyWith(isLoading: true);
    try {
      final authUseCase = ref.read(authUseCaseProvider);
      await authUseCase.confirmEmailVerification(
        email: state.email,
        verificationCode: state.verificationCode,
      );
      state = state.copyWith(
        isLoading: false,
        isEmailVerified: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        alertTitle: () => '인증 실패',
        alertMessage: () => e.toString(),
      );
    }
  }

  Future<void> signUp() async {
    if (state.name.isEmpty || state.nickname.isEmpty) {
      state = state.copyWith(
        alertTitle: () => '입력 오류',
        alertMessage: () => '이름과 닉네임을 입력해주세요.',
      );
      return;
    }
    if (state.password.isEmpty || state.confirmPassword.isEmpty) {
      state = state.copyWith(
        alertTitle: () => '입력 오류',
        alertMessage: () => '비밀번호를 입력해주세요.',
      );
      return;
    }
    if (!_passwordRegex.hasMatch(state.password)) {
      state = state.copyWith(
        alertTitle: () => '입력 오류',
        alertMessage: () => '비밀번호는 영문, 숫자 포함 8자 이상이어야 합니다.',
      );
      return;
    }
    if (state.password != state.confirmPassword) {
      state = state.copyWith(
        alertTitle: () => '입력 오류',
        alertMessage: () => '비밀번호가 일치하지 않습니다.',
      );
      return;
    }

    state = state.copyWith(isLoading: true);
    try {
      final authUseCase = ref.read(authUseCaseProvider);
      await authUseCase.signUp(
        name: state.name,
        nickname: state.nickname,
        email: state.email,
        password: state.password,
        confirmPassword: state.confirmPassword,
      );
      state = state.copyWith(
        isLoading: false,
        signUpSuccess: true,
        alertTitle: () => '회원가입 완료',
        alertMessage: () => '회원가입이 완료되었습니다. 로그인해주세요.',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        alertTitle: () => '회원가입 실패',
        alertMessage: () => e.toString(),
      );
    }
  }

  void clearAlert() {
    state = state.copyWith(
      alertTitle: () => null,
      alertMessage: () => null,
    );
  }
}

final signUpNotifierProvider =
    NotifierProvider<SignUpNotifier, SignUpState>(SignUpNotifier.new);
