import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'app/router.dart';
import 'core/providers.dart';
import 'data/storage/user_session.dart';
import 'presentation/splash/splash_view.dart';

/// 라우터/로그인이 준비된 시점에 GoRouter로 location push.
/// addPostFrameCallback으로 첫 빌드 완료 보장 → currentContext가 null인 race 방지.
void _pushDeepLink(String location) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final ctx = rootNavigatorKey.currentContext;
    if (ctx == null) return;
    GoRouter.of(ctx).push(location);
  });
}

/// 백그라운드 메시지 핸들러 (top-level function 필수)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('백그라운드 메시지: ${message.messageId}');
}

/// Android overscroll 효과 완전 제거 (glow + stretch 모두)
class NoOverscrollBehavior extends MaterialScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const ClampingScrollPhysics();
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 릴리즈 빌드에서 debugPrint 출력 차단.
  // Flutter의 debugPrint는 이름과 달리 릴리즈에서도 logcat/console에 그대로 찍힘.
  // FCM 토큰, API 응답, 스택트레이스 등이 운영 단말 logcat에 노출되는 것 방지.
  if (kReleaseMode) {
    debugPrint = (String? message, {int? wrapWidth}) {};
  }

  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(const ProviderScope(child: FaithConnectApp()));
}

class FaithConnectApp extends StatefulWidget {
  const FaithConnectApp({super.key});

  @override
  State<FaithConnectApp> createState() => _FaithConnectAppState();
}

class _FaithConnectAppState extends State<FaithConnectApp> {
  bool _splashDone = false;

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4A90E2)),
      splashFactory: NoSplash.splashFactory,
      appBarTheme: const AppBarTheme(
        titleTextStyle: TextStyle(
          fontSize: 17,
          color: Colors.black,
        ),
      ),
    );

    if (!_splashDone) {
      return MaterialApp(
        title: 'FaithConnect',
        debugShowCheckedModeBanner: false,
        theme: theme,
        home: SplashView(
          onComplete: () => setState(() => _splashDone = true),
        ),
      );
    }

    return _MainApp(theme: theme);
  }
}

class _MainApp extends ConsumerStatefulWidget {
  final ThemeData theme;
  const _MainApp({required this.theme});

  @override
  ConsumerState<_MainApp> createState() => _MainAppState();
}

class _MainAppState extends ConsumerState<_MainApp> {
  @override
  void initState() {
    super.initState();
    // 로그인 상태 전환에 따라 펜딩 딥링크 처리.
    // - false → true (로그인): 5분 TTL 내라면 consume, 만료면 폐기 (PendingDeepLink가 알아서 처리)
    // - true → false (로그아웃): 큐 정리. 빠른 재로그인 시 stale 의도 발화 방지.
    ref.listenManual<UserSessionState>(userSessionProvider, (prev, next) {
      final wasLoggedIn = prev?.isLoggedIn ?? false;
      if (!wasLoggedIn && next.isLoggedIn) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          PendingDeepLink.consume();
        });
      } else if (wasLoggedIn && !next.isLoggedIn) {
        PendingDeepLink.clear();
      }
    });
    _tryAutoLogin();
    _setupFCM();
  }

  Future<void> _tryAutoLogin() async {
    try {
      final authUseCase = ref.read(authUseCaseProvider);
      final hasToken = await authUseCase.hasToken;
      if (!hasToken) return;

      final user = await authUseCase.fetchMyInfo();
      ref.read(userSessionProvider.notifier).login(user);

      // FCM 토큰 등록
      try {
        final fcmToken = await FirebaseMessaging.instance.getToken();
        if (fcmToken != null) {
          await authUseCase.registerPushToken(deviceToken: fcmToken);
        }
      } catch (_) {}
    } catch (_) {}
  }

  Future<void> _setupFCM() async {
    final messaging = FirebaseMessaging.instance;

    // 알림 권한 요청
    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // 포그라운드 메시지 수신
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('포그라운드 메시지: ${message.notification?.title}');
      final notification = message.notification;
      if (notification == null) return;
      // _MainAppState의 context는 MaterialApp.router 부모 → ScaffoldMessenger.of(context) 사용 불가.
      // MaterialApp.router에 주입한 글로벌 scaffoldMessengerKey로 우회.
      // currentState가 null이면(아직 마운트 안 됨) 조용히 무시.
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text(notification.body ?? ''),
          action: SnackBarAction(
            label: '보기',
            onPressed: () => _handleMessageTap(message.data),
          ),
        ),
      );
    });

    // 알림 탭 시 (앱이 백그라운드에서 열릴 때)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleMessageTap(message.data);
    });

    // 앱이 종료된 상태에서 알림 탭으로 열렸을 때
    final initialMessage = await messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleMessageTap(initialMessage.data);
    }
  }

  void _handleMessageTap(Map<String, dynamic> data) {
    final prayerRequestId = data['prayerRequestId'];
    if (prayerRequestId == null) return;
    final id = int.tryParse(prayerRequestId.toString());
    if (id == null) return;

    final location = '/prayer/$id';
    // 로그인 상태에 따라 즉시 push 또는 큐잉.
    // 콜드 스타트 시 _setupFCM과 _tryAutoLogin이 병렬 실행되므로 여기서 isLoggedIn이 false일 수 있음
    // → enqueue 후 로그인 전환 listener가 consume.
    if (ref.read(userSessionProvider).isLoggedIn) {
      _pushDeepLink(location);
    } else {
      PendingDeepLink.enqueue(location);
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      title: 'FaithConnect',
      debugShowCheckedModeBanner: false,
      theme: widget.theme,
      scrollBehavior: NoOverscrollBehavior(),
      routerConfig: router,
      // 글로벌 SnackBar 핸들 — FCM 포그라운드 메시지 등 트리 외부에서 사용.
      scaffoldMessengerKey: scaffoldMessengerKey,
    );
  }
}
