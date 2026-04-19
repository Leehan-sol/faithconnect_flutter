/// iOS APIError.swift + APIErrorCode.swift 대응
class ApiError implements Exception {
  final String message;
  final String? errorCode;
  final int? statusCode;

  const ApiError({
    required this.message,
    this.errorCode,
    this.statusCode,
  });

  /// 서버에서 내려주는 에러 코드 → 한글 메시지
  /// iOS APIErrorCode.swift와 동일
  static String messageFromCode(String code) {
    switch (code) {
      case 'EXPIRED_ACCESS_TOKEN':
        return '액세스 토큰 만료 (갱신 시도 예정)';
      case 'EXPIRED_REFRESH_TOKEN':
        return '리프레시 토큰 만료 (다시 로그인 필요)';
      case 'REFRESH_TOKEN_NOT_FOUND':
        return '리프레시 토큰을 찾을 수 없음';
      case 'USER_NOT_FOUND':
        return '사용자를 찾을 수 없습니다.';
      case 'PASSWORD_MISMATCH':
        return '비밀번호가 일치하지 않습니다.';
      case 'USER_EXIST_BY_EMAIL':
        return '이미 사용중인 이메일입니다.';
      case 'CATEGORY_NOT_FOUND':
        return '해당 카테고리를 찾을 수 없습니다.';
      case 'PRAYER_NOT_FOUND':
        return '해당 기도를 찾을 수 없습니다.';
      case 'ONLY_AUTHOR_CAN_DELETE_PRAYER':
        return '본인이 작성한 기도제목만 삭제할 수 있습니다.';
      default:
        return '알 수 없는 오류가 발생했습니다.';
    }
  }

  @override
  String toString() => message;
}
