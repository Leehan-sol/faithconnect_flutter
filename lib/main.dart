import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/router.dart';
import 'core/providers.dart';
import 'data/storage/user_session.dart';
import 'presentation/prayer_detail/prayer_detail_view.dart';
import 'presentation/splash/splash_view.dart';

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
      if (message.notification != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message.notification!.body ?? ''),
            action: SnackBarAction(
              label: '보기',
              onPressed: () => _handleMessageTap(message.data),
            ),
          ),
        );
      }
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
    if (prayerRequestId != null) {
      final id = int.tryParse(prayerRequestId.toString());
      if (id != null && mounted) {
        // navigatorKey를 통해 기도 상세로 이동
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => PrayerDetailView(prayerRequestId: id),
              ),
            );
          }
        });
      }
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
    );
  }
}
