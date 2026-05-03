import '../../data/dtos/auth_dtos.dart';

/// iOS AuthRepositoryProtocol.swift 대응
abstract class AuthRepositoryInterface {
  Future<bool> get hasToken;
  Future<LoginResponse> login({required String email, required String password});
  Future<void> logout();
  Future<FetchMyInfoResponse> fetchMyInfo();
  Future<void> signUp({
    required String name,
    required String nickname,
    required String email,
    required String password,
    required String confirmPassword,
  });
  Future<void> requestEmailVerification({required String email});
  Future<void> confirmEmailVerification({
    required String email,
    required String verificationCode,
  });
  Future<String> findId({required String name, required String nickname});
  Future<void> requestPasswordReset({required String email});
  Future<void> confirmPasswordReset({
    required String email,
    required String code,
    required String newPassword,
  });
  Future<String> changeNickname({required String nickname});
  Future<void> changePassword({
    required int id,
    required String name,
    required String email,
    required String newPassword,
  });
  Future<void> deleteAccount();
  Future<void> sendInquiry({
    required String title,
    required String content,
    required String userEmail,
  });
}
