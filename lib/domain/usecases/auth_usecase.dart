import '../entities/user.dart';
import '../interfaces/auth_repository_interface.dart';

/// iOS AuthUseCase.swift 대응
class AuthUseCase {
  final AuthRepositoryInterface _repository;

  AuthUseCase({required AuthRepositoryInterface repository})
      : _repository = repository;

  Future<bool> get hasToken => _repository.hasToken;

  Future<void> login({
    required String email,
    required String password,
  }) async {
    await _repository.login(email: email, password: password);
  }

  Future<User> fetchMyInfo() async {
    final response = await _repository.fetchMyInfo();
    final nickname =
        (response.nickname?.isEmpty ?? true) ? response.name : response.nickname!;
    return User(
      name: response.name,
      nickname: nickname,
      email: response.email,
    );
  }

  Future<void> logout() async {
    await _repository.logout();
  }

  Future<void> signUp({
    required String name,
    required String nickname,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    await _repository.signUp(
      name: name,
      nickname: nickname,
      email: email,
      password: password,
      confirmPassword: confirmPassword,
    );
  }

  Future<void> requestEmailVerification({required String email}) async {
    await _repository.requestEmailVerification(email: email);
  }

  Future<void> confirmEmailVerification({
    required String email,
    required String verificationCode,
  }) async {
    await _repository.confirmEmailVerification(
      email: email,
      verificationCode: verificationCode,
    );
  }

  Future<String> findId({required String name, required String nickname}) async {
    return _repository.findId(name: name, nickname: nickname);
  }

  Future<void> requestPasswordReset({required String email}) async {
    await _repository.requestPasswordReset(email: email);
  }

  Future<void> confirmPasswordReset({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    await _repository.confirmPasswordReset(
      email: email,
      code: code,
      newPassword: newPassword,
    );
  }

  Future<String> changeNickname({required String nickname}) async {
    return _repository.changeNickname(nickname: nickname);
  }

  Future<void> changePassword({
    required int id,
    required String name,
    required String email,
    required String newPassword,
  }) async {
    await _repository.changePassword(
      id: id,
      name: name,
      email: email,
      newPassword: newPassword,
    );
  }

  Future<void> deleteAccount() async {
    await _repository.deleteAccount();
  }

  Future<void> sendInquiry({
    required String title,
    required String content,
    required String userEmail,
  }) async {
    await _repository.sendInquiry(
      title: title,
      content: content,
      userEmail: userEmail,
    );
  }

  Future<void> registerPushToken({required String deviceToken}) async {
    await _repository.registerPushToken(deviceToken: deviceToken);
  }

  Future<void> deletePushToken({required String deviceToken}) async {
    await _repository.deletePushToken(deviceToken: deviceToken);
  }
}
