import '../entities/user.dart';
import '../interfaces/auth_repository_interface.dart';

/// iOS AuthUseCase.swift 대응
/// Repository의 DTO를 Domain Entity로 변환
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

  /// DTO → Domain Entity 변환 (iOS와 동일)
  Future<User> fetchMyInfo() async {
    final response = await _repository.fetchMyInfo();
    return User(
      name: response.name,
      nickname: response.name,
      email: response.email,
    );
  }

  Future<void> logout() async {
    await _repository.logout();
  }
}
