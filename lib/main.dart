import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/router.dart';
import 'core/providers.dart';
import 'data/storage/user_session.dart';
import 'presentation/splash/splash_view.dart';

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

void main() {
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
  }

  /// 저장된 토큰이 있으면 자동 로그인 시도
  Future<void> _tryAutoLogin() async {
    try {
      final authUseCase = ref.read(authUseCaseProvider);
      final hasToken = await authUseCase.hasToken;
      if (!hasToken) return;

      final user = await authUseCase.fetchMyInfo();
      ref.read(userSessionProvider.notifier).login(user);
    } catch (_) {
      // 토큰 만료 등 실패 시 로그인 화면으로
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
