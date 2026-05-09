import '../network/api_client.dart';
import '../network/api_endpoints.dart';
import '../storage/token_storage.dart';
import '../dtos/auth_dtos.dart';
import '../dtos/inquiry_dtos.dart';
import '../../domain/interfaces/auth_repository_interface.dart';

/// iOS AuthRepository.swift 대응
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
      auth: false,
    );
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

  @override
  Future<void> signUp({
    required String name,
    required String nickname,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    await _apiClient.post(
      ApiEndpoints.signup,
      data: SignUpRequest(
        name: name,
        nickname: nickname,
        email: email,
        password: password,
        confirmPassword: confirmPassword,
      ).toJson(),
      fromJson: SignUpResponse.fromJson,
      auth: false,
    );
  }

  @override
  Future<void> requestEmailVerification({required String email}) async {
    await _apiClient.post(
      ApiEndpoints.emailVerificationRequest,
      data: EmailVerificationRequest(email: email).toJson(),
      fromJson: EmailVerificationResponse.fromJson,
      auth: false,
    );
  }

  @override
  Future<void> confirmEmailVerification({
    required String email,
    required String verificationCode,
  }) async {
    await _apiClient.post(
      ApiEndpoints.emailVerificationConfirm,
      data: EmailVerificationConfirmRequest(
        email: email,
        verificationCode: verificationCode,
      ).toJson(),
      fromJson: EmailVerificationConfirmResponse.fromJson,
      auth: false,
    );
  }

  @override
  Future<String> findId({required String name, required String nickname}) async {
    final response = await _apiClient.post(
      ApiEndpoints.findEmail,
      data: FindIdRequest(name: name, nickname: nickname).toJson(),
      fromJson: FindIdResponse.fromJson,
      auth: false,
    );
    return response.email;
  }

  @override
  Future<void> requestPasswordReset({required String email}) async {
    await _apiClient.post(
      ApiEndpoints.passwordResetRequest,
      data: PasswordResetRequestDto(email: email).toJson(),
      fromJson: PasswordResetResponse.fromJson,
      auth: false,
    );
  }

  @override
  Future<void> confirmPasswordReset({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    await _apiClient.post(
      ApiEndpoints.passwordResetConfirm,
      data: PasswordResetConfirmRequest(
        email: email,
        code: code,
        newPassword: newPassword,
      ).toJson(),
      fromJson: PasswordResetConfirmResponse.fromJson,
      auth: false,
    );
  }

  @override
  Future<String> changeNickname({required String nickname}) async {
    final response = await _apiClient.put(
      ApiEndpoints.changeNickname,
      data: ChangeNicknameRequest(nickname: nickname).toJson(),
      fromJson: ChangeNicknameResponse.fromJson,
    );
    return response.nickname ?? nickname;
  }

  @override
  Future<void> changePassword({
    required int id,
    required String name,
    required String email,
    required String newPassword,
  }) async {
    await _apiClient.post(
      ApiEndpoints.changePassword,
      data: ChangePasswordRequest(
        name: name,
        churchMemberId: id,
        email: email,
        newPassword: newPassword,
      ).toJson(),
      fromJson: ChangePasswordResponse.fromJson,
    );
  }

  @override
  Future<void> deleteAccount() async {
    await _apiClient.delete(ApiEndpoints.me);
    await _tokenStorage.clear();
  }

  @override
  Future<void> sendInquiry({
    required String title,
    required String content,
    required String userEmail,
  }) async {
    await _apiClient.post(
      ApiEndpoints.inquiry,
      data: InquiryRequest(
        title: title,
        content: content,
        userEmail: userEmail,
      ).toJson(),
      fromJson: InquiryResponse.fromJson,
    );
  }

  @override
  Future<void> registerPushToken({required String deviceToken}) async {
    await _apiClient.postEmpty(
      ApiEndpoints.pushToken,
      data: {'deviceToken': deviceToken},
    );
  }

  @override
  Future<void> deletePushToken({required String deviceToken}) async {
    await _apiClient.delete(ApiEndpoints.pushToken);
  }
}
