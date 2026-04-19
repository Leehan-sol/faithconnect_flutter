import '../network/api_client.dart';
import '../network/api_endpoints.dart';
import '../storage/token_storage.dart';
import '../dtos/auth_dtos.dart';
import '../../domain/interfaces/auth_repository_interface.dart';

/// iOS AuthRepository.swift 대응
/// APIClient를 래핑하여 UseCase에 제공
class AuthRepository implements AuthRepositoryInterface {
  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  AuthRepository({
    required ApiClient apiClient,
    required TokenStorage tokenStorage,
  })  : _apiClient = apiClient,
        _tokenStorage = tokenStorage;

  @override
  Future<bool> get hasToken => _tokenStorage.hasToken;

  @override
  Future<LoginResponse> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.login,
      data: LoginRequest(email: email, password: password).toJson(),
      fromJson: LoginResponse.fromJson,
      auth: false, // iOS: auth: .none — 로그인에는 토큰 불필요
    );
    // 토큰 저장 (iOS: APIClient 내에서 처리)
    await _tokenStorage.save(
      accessToken: response.accessToken,
      refreshToken: response.refreshToken,
    );
    return response;
  }

  @override
  Future<void> logout() async {
    await _apiClient.postEmpty(ApiEndpoints.logout);
    await _tokenStorage.clear();
  }

  @override
  Future<FetchMyInfoResponse> fetchMyInfo() async {
    return _apiClient.get(
      ApiEndpoints.me,
      fromJson: FetchMyInfoResponse.fromJson,
    );
  }
}
