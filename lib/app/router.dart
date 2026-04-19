import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/storage/user_session.dart';
import '../presentation/main_tab/main_tab_view.dart';
import '../presentation/login/login_view.dart';

/// GoRouter를 Riverpod Provider로 관리
///
/// 스플래시는 라우터 밖에서 처리 (main.dart에서 초기 로딩 후 라우터 시작)
/// 로그인 상태 변화 시 redirect로 자동 화면 분기
final appRouterProvider = Provider<GoRouter>((ref) {
  final session = ref.watch(userSessionProvider);

  return GoRouter(
    // TODO: 개발 끝나면 '/login'으로 되돌리고 redirect 주석 해제
    initialLocation: '/home',
    // redirect: (context, state) {
    //   final isLoggedIn = session.isLoggedIn;
    //   final isOnLogin = state.matchedLocation == '/login';
    //
    //   if (!isLoggedIn && !isOnLogin) return '/login';
    //   if (isLoggedIn && isOnLogin) return '/home';
    //
    //   return null;
    // },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginView(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const MainTabView(),
      ),
    ],
  );
});
