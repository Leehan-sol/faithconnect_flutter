import '../network/api_client.dart';
import '../network/api_endpoints.dart';
import '../dtos/prayer_dtos.dart';

/// iOS PrayerRepository.swift 대응
class PrayerRepository {
  final ApiClient _apiClient;

  PrayerRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<List<CategoryResponse>> loadCategories() async {
    return _apiClient.getList(
      ApiEndpoints.categories,
      fromJson: CategoryResponse.fromJson,
    );
  }

  Future<PrayerListResponse> loadPrayers({
    required int categoryId,
    required int page,
  }) async {
    return _apiClient.get(
      ApiEndpoints.requests,
      queryParameters: {'categoryId': categoryId, 'page': page},
      fromJson: PrayerListResponse.fromJson,
    );
  }

  Future<PrayerDetailResponse> loadPrayerDetail(int prayerRequestId) async {
    return _apiClient.get(
      ApiEndpoints.requestDetail(prayerRequestId),
      fromJson: PrayerDetailResponse.fromJson,
    );
  }

  Future<PrayerWriteResponse> writePrayer({
    required int categoryId,
    required String title,
    required String content,
  }) async {
    return _apiClient.post(
      ApiEndpoints.requests,
      data: {'categoryId': categoryId, 'title': title, 'content': content},
      fromJson: PrayerWriteResponse.fromJson,
    );
  }

  Future<PrayerDetailResponse> updatePrayer({
    required int prayerRequestId,
    required int categoryId,
    required String title,
    required String content,
  }) async {
    return _apiClient.put(
      ApiEndpoints.requestDetail(prayerRequestId),
      data: {'categoryId': categoryId, 'title': title, 'content': content},
      fromJson: PrayerDetailResponse.fromJson,
    );
  }

  Future<void> deletePrayer(int prayerRequestId) async {
    await _apiClient.delete(ApiEndpoints.requestDetail(prayerRequestId));
  }

  Future<DetailResponseItem> writePrayerResponse({
    required int prayerRequestId,
    required String message,
  }) async {
    return _apiClient.post(
      ApiEndpoints.responses,
      data: {'prayerRequestId': prayerRequestId, 'message': message},
      fromJson: DetailResponseItem.fromJson,
    );
  }

  Future<DetailResponseItem> updatePrayerResponse({
    required int responseId,
    required String message,
  }) async {
    return _apiClient.put(
      ApiEndpoints.responseDetail(responseId),
      data: {'message': message},
      fromJson: DetailResponseItem.fromJson,
    );
  }

  Future<void> deletePrayerResponse(int responseId) async {
    await _apiClient.delete(ApiEndpoints.responseDetail(responseId));
  }

  Future<DetailResponseItem> writeReply({
    required int responseId,
    required String message,
  }) async {
    return _apiClient.post(
      ApiEndpoints.responseReplies(responseId),
      data: {'message': message},
      fromJson: DetailResponseItem.fromJson,
    );
  }

  Future<Map<String, dynamic>> loadReplies({
    required int responseId,
    required int page,
  }) async {
    return _apiClient.get(
      ApiEndpoints.responseReplies(responseId),
      queryParameters: {'page': page},
      fromJson: (json) => json,
    );
  }

  Future<PrayerListResponse> loadWrittenPrayers({required int page}) async {
    return _apiClient.get(
      ApiEndpoints.myRequests,
      queryParameters: {'page': page},
      fromJson: PrayerListResponse.fromJson,
    );
  }

  Future<Map<String, dynamic>> loadParticipatedPrayers({required int page}) async {
    return _apiClient.get(
      ApiEndpoints.myPrayers,
      queryParameters: {'page': page},
      fromJson: (json) => json,
    );
  }
}
