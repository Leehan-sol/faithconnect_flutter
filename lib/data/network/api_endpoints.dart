/// iOS APIEndPoint.swift 대응
/// 서버 환경 + API 경로 정의
class ApiEndpoints {
  // 환경 설정 (iOS: ServerEnvironment.release.baseURL)
  // Android 에뮬레이터에서 localhost 접근 시 10.0.2.2 사용
  // (에뮬레이터의 localhost는 에뮬레이터 자체를 가리키므로)
  static const String baseUrl = 'http://10.0.2.2:8080';
  static const String _apiPath = '/api/prayer';

  // Auth
  static const String login = '$_apiPath/login';
  static const String signup = '$_apiPath/signup';
  static const String logout = '$_apiPath/logout';
  static const String me = '$_apiPath/me';
  static const String findEmail = '$_apiPath/find-email';
  static const String changePassword = '$_apiPath/change-password';
  static const String passwordResetRequest = '$_apiPath/password-reset/request';
  static const String passwordResetConfirm = '$_apiPath/password-reset/confirm';
  static const String changeNickname = '$_apiPath/me/nickname';
  static const String emailVerificationRequest = '$_apiPath/email-verification/request';
  static const String emailVerificationConfirm = '$_apiPath/email-verification/confirm';
  static const String refreshToken = '$_apiPath/refresh-token';

  // Prayer
  static const String categories = '$_apiPath/categories';
  static const String requests = '$_apiPath/requests';
  static String requestDetail(int id) => '$_apiPath/requests/$id';
  static String requestReport(int id) => '$_apiPath/requests/$id/report';
  static const String responses = '$_apiPath/responses';
  static String responseDetail(int id) => '$_apiPath/responses/$id';
  static String responseReplies(int id) => '$_apiPath/responses/$id/replies';
  static String responseReport(int id) => '$_apiPath/responses/$id/report';
  static const String myRequests = '$_apiPath/my-requests';
  static const String myPrayers = '$_apiPath/my-prayers';
  static String blockUser(int userId) => '$_apiPath/users/$userId/block';
  static const String blocks = '$_apiPath/blocks';

  // Push
  static const String pushToken = '$_apiPath/push-token';

  // Inquiry
  static const String inquiry = '$_apiPath/inquiry';
}
