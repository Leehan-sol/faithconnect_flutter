import '../../data/dtos/auth_dtos.dart';

/// iOS AuthRepositoryProtocol.swift 대응
/// Dart에는 protocol이 없으므로 abstract class 사용
/// (면접 포인트: Swift protocol = Dart abstract class)
abstract class AuthRepositoryInterface {
  Future<bool> get hasToken;
  Future<LoginResponse> login({required String email, required String password});
  Future<void> logout();
  Future<FetchMyInfoResponse> fetchMyInfo();
}
