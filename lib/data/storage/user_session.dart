import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/user.dart';

/// iOS UserSession.swift 대응
/// iOS: @MainActor class UserSession: ObservableObject { @Published var user, isLoggedIn }
/// Flutter: Riverpod Notifier — 앱 전역에서 로그인 상태 공유
class UserSessionState {
  final User? user;
  final bool isLoggedIn;

  const UserSessionState({this.user, this.isLoggedIn = false});

  String get name => user?.name ?? '';
  String get nickname => user?.nickname ?? '';
  String get email => user?.email ?? '';

  UserSessionState copyWith({User? Function()? user, bool? isLoggedIn}) {
    return UserSessionState(
      user: user != null ? user() : this.user,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
    );
  }
}

class UserSessionNotifier extends Notifier<UserSessionState> {
  @override
  UserSessionState build() => const UserSessionState();

  void login(User user) {
    state = UserSessionState(user: user, isLoggedIn: true);
  }

  void updateNickname(String nickname) {
    if (state.user == null) return;
    state = state.copyWith(
      user: () => User(
        name: state.user!.name,
        nickname: nickname,
        email: state.user!.email,
      ),
    );
  }

  void logout() {
    state = const UserSessionState();
  }
}

final userSessionProvider =
    NotifierProvider<UserSessionNotifier, UserSessionState>(
        UserSessionNotifier.new);
