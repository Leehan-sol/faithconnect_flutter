import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../storage/token_storage.dart';
import '../dtos/auth_dtos.dart';
import 'api_endpoints.dart';
import 'api_error.dart';

/// iOS APIClient.swift 대응
/// URLSession → Dio (Flutter 표준 HTTP 클라이언트)
///
/// iOS와 동일한 토큰 관리:
/// 1. 요청 시 Authorization: Bearer {accessToken} 자동 추가
/// 2. 401 에러 시 refreshToken으로 갱신 시도
/// 3. 갱신 실패 시 토큰 삭제 (로그아웃 처리)
class ApiClient {
  final Dio _dio;
  final TokenStorage _tokenStorage;

  ApiClient({required TokenStorage tokenStorage})
      : _tokenStorage = tokenStorage,
        _dio = Dio(BaseOptions(
          baseUrl: ApiEndpoints.baseUrl,
          contentType: 'application/json',
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        )) {
    // 인터셉터로 토큰 자동 관리 (iOS의 수동 헤더 세팅을 자동화)
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: _onRequest,
      onError: _onError,
    ));
  }

  /// 매 요청마다 accessToken을 헤더에 추가
  /// skipAuth 헤더가 있으면 토큰 안 붙임 (iOS auth: .none 대응)
  Future<void> _onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.headers.remove('skipAuth') == true) {
      handler.next(options);
      return;
    }
    final token = await _tokenStorage.accessToken;
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  /// 401 에러 시 토큰 갱신 후 재시도 (iOS retry 로직과 동일)
  Future<void> _onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      try {
        final refreshed = await _refreshToken();
        if (refreshed) {
          // 토큰 갱신 성공 → 원래 요청 재시도
          final retryOptions = err.requestOptions;
          final newToken = await _tokenStorage.accessToken;
          retryOptions.headers['Authorization'] = 'Bearer $newToken';
          final response = await _dio.fetch(retryOptions);
          return handler.resolve(response);
        }
      } catch (_) {
        // 갱신 실패 → 토큰 삭제
        await _tokenStorage.clear();
      }
    }
    handler.next(err);
  }

  /// refreshToken으로 accessToken 갱신
  Future<bool> _refreshToken() async {
    final refresh = await _tokenStorage.refreshToken;
    if (refresh == null) return false;

    try {
      // 인터셉터 우회를 위해 새 Dio 인스턴스 사용
      final response = await Dio().post(
        '${ApiEndpoints.baseUrl}${ApiEndpoints.refreshToken}',
        data: AccessTokenRequest(refreshToken: refresh).toJson(),
        options: Options(contentType: 'application/json'),
      );
      final tokenResponse = AccessTokenResponse.fromJson(response.data);
      await _tokenStorage.save(
        accessToken: tokenResponse.accessToken,
        refreshToken: tokenResponse.refreshToken,
      );
      return true;
    } catch (e) {
      debugPrint('Token refresh failed: $e');
      return false;
    }
  }

  /// POST 요청 (iOS: apiClient.post)
  /// iOS APIClient의 auth 파라미터 대응
  /// auth: true (기본) → 토큰 포함, false → 토큰 제외
  /// iOS: auth: .required / .none
  Future<T> post<T>(
    String path, {
    Map<String, dynamic>? data,
    required T Function(Map<String, dynamic>) fromJson,
    bool auth = true,
  }) async {
    try {
      final options = auth ? null : Options(headers: {'skipAuth': true});
      final response = await _dio.post(path, data: data, options: options);
      debugPrint('POST $path 응답: ${response.data}');
      return fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// POST 요청 (응답 바디 없는 경우)
  Future<void> postEmpty(String path, {Map<String, dynamic>? data, bool auth = true}) async {
    try {
      final options = auth ? null : Options(headers: {'skipAuth': true});
      await _dio.post(path, data: data, options: options);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// GET 요청
  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      return fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// GET 요청 (배열 응답)
  Future<List<T>> getList<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      return (response.data as List)
          .map((e) => fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// DELETE 요청
  Future<void> delete(String path) async {
    try {
      await _dio.delete(path);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// PUT 요청
  Future<T> put<T>(
    String path, {
    Map<String, dynamic>? data,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    try {
      final response = await _dio.put(path, data: data);
      return fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Dio 에러 → ApiError 변환
  ApiError _handleError(DioException e) {
    final data = e.response?.data;
    if (data is Map<String, dynamic> && data.containsKey('errorCode')) {
      final code = data['errorCode'].toString();
      return ApiError(
        message: data['message']?.toString() ?? ApiError.messageFromCode(code),
        errorCode: code,
        statusCode: e.response?.statusCode,
      );
    }
    return ApiError(
      message: e.response?.statusMessage ?? '네트워크 오류가 발생했습니다.',
      statusCode: e.response?.statusCode,
    );
  }
}
