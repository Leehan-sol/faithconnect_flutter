class SignUpState {
  final String name;
  final String nickname;
  final String email;
  final String verificationCode;
  final String password;
  final String confirmPassword;
  final bool isEmailVerified;
  final bool isVerificationCodeSent;
  final bool isLoading;
  final String? alertTitle;
  final String? alertMessage;
  final bool signUpSuccess;

  const SignUpState({
    this.name = '',
    this.nickname = '',
    this.email = '',
    this.verificationCode = '',
    this.password = '',
    this.confirmPassword = '',
    this.isEmailVerified = false,
    this.isVerificationCodeSent = false,
    this.isLoading = false,
    this.alertTitle,
    this.alertMessage,
    this.signUpSuccess = false,
  });

  SignUpState copyWith({
    String? name,
    String? nickname,
    String? email,
    String? verificationCode,
    String? password,
    String? confirmPassword,
    bool? isEmailVerified,
    bool? isVerificationCodeSent,
    bool? isLoading,
    String? Function()? alertTitle,
    String? Function()? alertMessage,
    bool? signUpSuccess,
  }) {
    return SignUpState(
      name: name ?? this.name,
      nickname: nickname ?? this.nickname,
      email: email ?? this.email,
      verificationCode: verificationCode ?? this.verificationCode,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isVerificationCodeSent: isVerificationCodeSent ?? this.isVerificationCodeSent,
      isLoading: isLoading ?? this.isLoading,
      alertTitle: alertTitle != null ? alertTitle() : this.alertTitle,
      alertMessage: alertMessage != null ? alertMessage() : this.alertMessage,
      signUpSuccess: signUpSuccess ?? this.signUpSuccess,
    );
  }
}
