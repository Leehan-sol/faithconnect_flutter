import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers.dart';
import '../../data/storage/user_session.dart';
import 'login_state.dart';

/// iOS LoginViewModel 대응 — Phase 3: 실제 API 연동
///
/// Notifier에서 다른 Provider 접근:
/// ref.read(authUseCaseProvider) — build() 또는 메서드 안에서 사용
/// iOS에서 ViewModel에 UseCase를 주입하던 것을 Riverpod이 자동으로 해줌
class LoginNotifier extends Notifier<LoginState> {
  @override
  LoginState build() => const LoginState();

  void setEmail(String value) {
    state = state.copyWith(email: value);
  }

  void setPassword(String value) {
    state = state.copyWith(password: value);
  }

  /// iOS LoginViewModel.login()과 동일한 플로우:
  /// 1. 빈 값 체크 → Alert
  /// 2. API 호출 (로딩 표시)
  /// 3. 성공 → fetchMyInfo → UserSession.login
  /// 4. 실패 → 에러 Alert
  Future<void> login() async {
    if (state.email.isEmpty) {
      state = state.copyWith(
        alertTitle: () => '입력 오류',
        alertMessage: () => '이메일을(를) 입력해주세요.',
      );
      return;
    }
    if (state.password.isEmpty) {
      state = state.copyWith(
        alertTitle: () => '입력 오류',
        alertMessage: () => '비밀번호을(를) 입력해주세요.',
      );
      return;
    }

    state = state.copyWith(isLoading: true);

    try {
      final authUseCase = ref.read(authUseCaseProvider);

      // 1. 로그인 API (토큰 저장은 Repository에서 처리)
      await authUseCase.login(email: state.email, password: state.password);

      // 2. 내 정보 조회
      final user = await authUseCase.fetchMyInfo();

      // 3. 세션에 저장 (iOS: session.login(user: user))
      ref.read(userSessionProvider.notifier).login(user);

      // 4. FCM 토큰 등록
      try {
        final fcmToken = await FirebaseMessaging.instance.getToken();
        if (fcmToken != null) {
          await authUseCase.registerPushToken(deviceToken: fcmToken);
          debugPrint('FCM 토큰 등록 완료');
        }
      } catch (e) {
        debugPrint('FCM 토큰 등록 실패: $e');
      }

      state = state.copyWith(isLoading: false);
    } catch (e, stackTrace) {
      debugPrint('로그인 에러: $e');
      debugPrint('스택트레이스: $stackTrace');
      state = state.copyWith(
        isLoading: false,
        alertTitle: () => '로그인 실패',
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

final loginNotifierProvider =
    NotifierProvider<LoginNotifier, LoginState>(LoginNotifier.new);
