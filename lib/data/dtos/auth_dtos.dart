/// iOS AuthDTOs.swift 대응
/// Phase 3에서는 로그인 관련 DTO만 먼저 작성

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

class FetchMyInfoResponse {
  final String name;
  final String email;

  const FetchMyInfoResponse({required this.name, required this.email});

  factory FetchMyInfoResponse.fromJson(Map<String, dynamic> json) =>
      FetchMyInfoResponse(
        name: json['name']?.toString() ?? '',
        email: json['email']?.toString() ?? '',
      );
}

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
