/// iOS AuthDTOs.swift 대응

// MARK: - 회원가입
class SignUpRequest {
  final String name;
  final String nickname;
  final String email;
  final String password;
  final String confirmPassword;

  const SignUpRequest({
    required this.name,
    required this.nickname,
    required this.email,
    required this.password,
    required this.confirmPassword,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'nickname': nickname,
        'email': email,
        'password': password,
        'confirmPassword': confirmPassword,
      };
}

class SignUpResponse {
  final String message;
  final bool? success;

  const SignUpResponse({required this.message, this.success});

  factory SignUpResponse.fromJson(Map<String, dynamic> json) => SignUpResponse(
        message: json['message']?.toString() ?? '',
        success: json['success'] as bool?,
      );
}

// MARK: - 로그인
class LoginRequest {
  final String email;
  final String password;

  const LoginRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
      };
}

class LoginResponse {
  final String accessToken;
  final String refreshToken;
  final String? errorCode;
  final int? status;

  const LoginResponse({
    required this.accessToken,
    required this.refreshToken,
    this.errorCode,
    this.status,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
        accessToken: json['accessToken'] as String,
        refreshToken: json['refreshToken'] as String,
        errorCode: json['errorCode']?.toString(),
        status: json['status'] as int?,
      );
}

// MARK: - 내 정보
class FetchMyInfoResponse {
  final String name;
  final String? nickname;
  final String email;

  const FetchMyInfoResponse({
    required this.name,
    this.nickname,
    required this.email,
  });

  factory FetchMyInfoResponse.fromJson(Map<String, dynamic> json) =>
      FetchMyInfoResponse(
        name: json['name']?.toString() ?? '',
        nickname: json['nickname']?.toString(),
        email: json['email']?.toString() ?? '',
      );
}

// MARK: - 아이디 찾기
class FindIdRequest {
  final String name;
  final String nickname;

  const FindIdRequest({required this.name, required this.nickname});

  Map<String, dynamic> toJson() => {'name': name, 'nickname': nickname};
}

class FindIdResponse {
  final String email;
  final bool success;

  const FindIdResponse({required this.email, required this.success});

  factory FindIdResponse.fromJson(Map<String, dynamic> json) => FindIdResponse(
        email: json['email']?.toString() ?? '',
        success: json['success'] as bool? ?? false,
      );
}

// MARK: - 비밀번호 재설정 요청
class PasswordResetRequestDto {
  final String email;

  const PasswordResetRequestDto({required this.email});

  Map<String, dynamic> toJson() => {'email': email};
}

class PasswordResetResponse {
  final String? message;
  final bool success;

  const PasswordResetResponse({this.message, required this.success});

  factory PasswordResetResponse.fromJson(Map<String, dynamic> json) =>
      PasswordResetResponse(
        message: json['message']?.toString(),
        success: json['success'] as bool? ?? false,
      );
}

// MARK: - 비밀번호 재설정 확인
class PasswordResetConfirmRequest {
  final String email;
  final String code;
  final String newPassword;

  const PasswordResetConfirmRequest({
    required this.email,
    required this.code,
    required this.newPassword,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'code': code,
        'newPassword': newPassword,
      };
}

class PasswordResetConfirmResponse {
  final String? message;
  final bool success;

  const PasswordResetConfirmResponse({this.message, required this.success});

  factory PasswordResetConfirmResponse.fromJson(Map<String, dynamic> json) =>
      PasswordResetConfirmResponse(
        message: json['message']?.toString(),
        success: json['success'] as bool? ?? false,
      );
}

// MARK: - 닉네임 변경
class ChangeNicknameRequest {
  final String nickname;

  const ChangeNicknameRequest({required this.nickname});

  Map<String, dynamic> toJson() => {'nickname': nickname};
}

class ChangeNicknameResponse {
  final String message;
  final bool? success;
  final String? nickname;

  const ChangeNicknameResponse({
    required this.message,
    this.success,
    this.nickname,
  });

  factory ChangeNicknameResponse.fromJson(Map<String, dynamic> json) =>
      ChangeNicknameResponse(
        message: json['message']?.toString() ?? '',
        success: json['success'] as bool?,
        nickname: json['nickname']?.toString(),
      );
}

// MARK: - 비밀번호 변경 (로그인 상태)
class ChangePasswordRequest {
  final String name;
  final int churchMemberId;
  final String email;
  final String newPassword;

  const ChangePasswordRequest({
    required this.name,
    required this.churchMemberId,
    required this.email,
    required this.newPassword,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'churchMemberId': churchMemberId,
        'email': email,
        'newPassword': newPassword,
      };
}

class ChangePasswordResponse {
  final String message;
  final bool success;

  const ChangePasswordResponse({required this.message, required this.success});

  factory ChangePasswordResponse.fromJson(Map<String, dynamic> json) =>
      ChangePasswordResponse(
        message: json['message']?.toString() ?? '',
        success: json['success'] as bool? ?? false,
      );
}

// MARK: - 이메일 인증 요청
class EmailVerificationRequest {
  final String email;

  const EmailVerificationRequest({required this.email});

  Map<String, dynamic> toJson() => {'email': email};
}

class EmailVerificationResponse {
  final String message;
  final bool? success;

  const EmailVerificationResponse({required this.message, this.success});

  factory EmailVerificationResponse.fromJson(Map<String, dynamic> json) =>
      EmailVerificationResponse(
        message: json['message']?.toString() ?? '',
        success: json['success'] as bool?,
      );
}

// MARK: - 이메일 인증 확인
class EmailVerificationConfirmRequest {
  final String email;
  final String verificationCode;

  const EmailVerificationConfirmRequest({
    required this.email,
    required this.verificationCode,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'verificationCode': verificationCode,
      };
}

class EmailVerificationConfirmResponse {
  final String message;
  final bool? success;

  const EmailVerificationConfirmResponse({required this.message, this.success});

  factory EmailVerificationConfirmResponse.fromJson(
          Map<String, dynamic> json) =>
      EmailVerificationConfirmResponse(
        message: json['message']?.toString() ?? '',
        success: json['success'] as bool?,
      );
}

// MARK: - 회원탈퇴
class DeleteAccountResponse {
  final String message;
  final bool? success;

  const DeleteAccountResponse({required this.message, this.success});

  factory DeleteAccountResponse.fromJson(Map<String, dynamic> json) =>
      DeleteAccountResponse(
        message: json['message']?.toString() ?? '',
        success: json['success'] as bool?,
      );
}

// MARK: - 토큰 갱신
class AccessTokenRequest {
  final String refreshToken;

  const AccessTokenRequest({required this.refreshToken});

  Map<String, dynamic> toJson() => {'refreshToken': refreshToken};
}

class AccessTokenResponse {
  final String accessToken;
  final String refreshToken;

  const AccessTokenResponse({
    required this.accessToken,
    required this.refreshToken,
  });

  factory AccessTokenResponse.fromJson(Map<String, dynamic> json) =>
      AccessTokenResponse(
        accessToken: json['accessToken'] as String,
        refreshToken: json['refreshToken'] as String,
      );
}
