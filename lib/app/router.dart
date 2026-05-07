import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/storage/user_session.dart';
import '../presentation/main_tab/main_tab_view.dart';
import '../presentation/login/login_view.dart';
import '../presentation/signup/signup_view.dart';
import '../presentation/find_id/find_id_view.dart';
import '../presentation/find_password/find_password_view.dart';
import '../presentation/prayer_detail/prayer_detail_view.dart';

/// 루트 NavigatorKey — 라우터 트리 외부(예: FCM 푸시 핸들러)에서
/// 안전하게 push 호출할 수 있도록 GoRouter에 주입.
/// _MainAppState의 context는 MaterialApp.router의 부모 위치라 Navigator.of(context)가 작동하지 않음.
final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

/// 글로벌 ScaffoldMessengerKey — 라우터 트리 외부(예: FCM onMessage 핸들러)에서
/// 안전하게 SnackBar를 띄우기 위한 핸들. MaterialApp.router에 주입.
/// _MainAppState의 context로 ScaffoldMessenger.of(context)를 찾으면 ancestor를 못 찾아 실패함.
final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>(
  debugLabel: 'scaffoldMessenger',
);

/// 푸시 탭으로 들어온 딥링크 의도를 보관하는 큐.
/// 미로그인 상태에서 푸시 탭 시 redirect로 의도가 유실되는 걸 방지하기 위함.
/// 로그인 성공 후 consume() 호출 → 보관된 location으로 이동.
///
/// 시나리오:
/// 1) 콜드 스타트 + 자동 로그인 미완료 → enqueue → auto-login 완료 시 consume
/// 2) 미로그인 상태 푸시 → enqueue → 사용자가 수동 로그인 시 consume
/// 3) 이미 로그인 상태 → 즉시 push (큐 미사용)
///
/// TTL 5분: 푸시 의도가 너무 오래 살아있어 stale 점프(예: 30분 뒤 백그라운드 복귀)가
/// 일어나는 걸 방지. enqueue 시 timestamp 기록 → consume 시 만료 체크.
class PendingDeepLink {
  static const Duration _ttl = Duration(minutes: 5);

  static String? _location;
  static DateTime? _enqueuedAt;

  /// 큐에 location 보관 + 시각 기록.
  static void enqueue(String location) {
    _location = location;
    _enqueuedAt = DateTime.now();
  }

  /// 큐 비우기 (예: 로그아웃 시 stale 데이터 정리).
  static void clear() {
    _location = null;
    _enqueuedAt = null;
  }

  /// 만료 여부 (외부에서 미리 체크하고 싶을 때).
  static bool get isExpired {
    final at = _enqueuedAt;
    if (at == null) return true;
    return DateTime.now().difference(at) > _ttl;
  }

  /// 보관된 location이 있고 TTL 내라면 push 후 비움.
  /// 만료된 경우엔 push 없이 비우기만 함.
  /// 라우터 마운트 + 로그인 완료 후 호출되어야 함 (redirect 통과 보장).
  static void consume() {
    final location = _location;
    final at = _enqueuedAt;
    if (location == null || at == null) return;

    // 만료 체크 — TTL 초과 시 push 없이 폐기
    if (DateTime.now().difference(at) > _ttl) {
      clear();
      return;
    }

    clear();

    final ctx = rootNavigatorKey.currentContext;
    if (ctx == null) return;
    GoRouter.of(ctx).push(location);
  }
}

/// GoRouter를 Riverpod Provider로 관리
/// ref.watch 대신 ref.listen으로 로그인 상태 변화만 감지하여
/// 세션 내 다른 변경(닉네임 등)으로 라우터가 재생성되지 않도록 함
final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = _RouterNotifier(ref);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
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
      // 푸시 알림 딥링크 또는 인앱 네비게이션으로 진입.
      // 미로그인 상태에서 진입 시 redirect 룰에 의해 /login으로 이동 (PendingDeepLink와 연계).
      GoRoute(
        path: '/prayer/:id',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return PrayerDetailView(prayerRequestId: id);
        },
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
