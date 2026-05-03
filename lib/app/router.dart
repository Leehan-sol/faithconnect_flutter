import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/storage/user_session.dart';
import '../presentation/main_tab/main_tab_view.dart';
import '../presentation/login/login_view.dart';
import '../presentation/signup/signup_view.dart';
import '../presentation/find_id/find_id_view.dart';
import '../presentation/find_password/find_password_view.dart';

/// GoRouter를 Riverpod Provider로 관리
/// ref.watch 대신 ref.listen으로 로그인 상태 변화만 감지하여
/// 세션 내 다른 변경(닉네임 등)으로 라우터가 재생성되지 않도록 함
final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = _RouterNotifier(ref);

  return GoRouter(
    initialLocation: '/login',
    refreshListenable: notifier,
    redirect: (context, state) {
      final isLoggedIn = notifier.isLoggedIn;
      final location = state.matchedLocation;
      final authRoutes = ['/login', '/signup', '/find-id', '/find-password'];

      if (!isLoggedIn && !authRoutes.contains(location)) return '/login';
      if (isLoggedIn && location == '/login') return '/home';

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginView(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignUpView(),
      ),
      GoRoute(
        path: '/find-id',
        builder: (context, state) => const FindIdView(),
      ),
      GoRoute(
        path: '/find-password',
        builder: (context, state) => const FindPasswordView(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const MainTabView(),
      ),
    ],
  );
});

/// 로그인/로그아웃 상태 변화만 감지하는 ChangeNotifier
class _RouterNotifier extends ChangeNotifier {
  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  _RouterNotifier(Ref ref) {
    ref.listen(userSessionProvider, (prev, next) {
      final newLoggedIn = next.isLoggedIn;
      if (_isLoggedIn != newLoggedIn) {
        _isLoggedIn = newLoggedIn;
        notifyListeners();
      }
    });
  }
}
