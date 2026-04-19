/// 로그인 화면의 상태를 담는 불변 클래스
///
/// === SwiftUI 비교 ===
/// iOS: LoginViewModel 안에 @Published var email, password, isLoading 등을 개별 프로퍼티로 관리
/// Flutter/Riverpod: 상태를 하나의 불변 객체로 묶어서 관리 (copyWith 패턴)
///
/// 왜 불변(immutable)?
/// - Riverpod은 state가 바뀌었는지를 == 비교로 판단
/// - 새 객체를 만들어야 "상태가 바뀌었다"고 인식 → UI 리빌드
/// - SwiftUI의 @Published는 자동으로 변경 감지하지만, Riverpod은 이 패턴을 사용
class LoginState {
  final String email;
  final String password;
  final bool isLoading;
  /// Alert 다이얼로그용 (iOS alertType 대응)
  final String? alertTitle;
  final String? alertMessage;

  const LoginState({
    this.email = '',
    this.password = '',
    this.isLoading = false,
    this.alertTitle,
    this.alertMessage,
  });

  LoginState copyWith({
    String? email,
    String? password,
    bool? isLoading,
    String? Function()? alertTitle,
    String? Function()? alertMessage,
  }) {
    return LoginState(
      email: email ?? this.email,
      password: password ?? this.password,
      isLoading: isLoading ?? this.isLoading,
      alertTitle: alertTitle != null ? alertTitle() : this.alertTitle,
      alertMessage: alertMessage != null ? alertMessage() : this.alertMessage,
    );
  }
}
