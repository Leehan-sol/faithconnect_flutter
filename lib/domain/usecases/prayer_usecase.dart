import '../entities/prayer.dart';
import '../entities/prayer_category.dart';
import '../entities/prayer_response.dart';
import '../entities/my_response.dart';
import '../entities/blocked_user.dart';
import '../../data/repositories/prayer_repository.dart';
import '../../data/dtos/prayer_dtos.dart';
import '../../data/dtos/report_dtos.dart';

/// iOS PrayerUseCase.swift 대응
class PrayerUseCase {
  final PrayerRepository _repository;

  PrayerUseCase({required PrayerRepository repository})
      : _repository = repository;

  Future<List<PrayerCategory>> loadCategories() async {
    final dtos = await _repository.loadCategories();
    return dtos
        .map((dto) => PrayerCategory(
              id: dto.categoryId,
              categoryCode: dto.categoryCode,
              categoryName: dto.categoryName,
            ))
        .toList();
  }

  Future<PrayerPage> loadPrayers({
    required int categoryId,
    required int page,
  }) async {
    final dto = await _repository.loadPrayers(
      categoryId: categoryId,
      page: page,
    );
    return PrayerPage(
      prayers: dto.prayerRequests.map(_prayerFromDto).toList(),
      currentPage: dto.currentPage,
      hasNext: dto.hasNext,
    );
  }

  Future<Prayer> loadPrayerDetail(int prayerRequestId) async {
    final dto = await _repository.loadPrayerDetail(prayerRequestId);
    return _prayerFromDetailDto(dto);
  }

  Future<Prayer> writePrayer({
    required int categoryId,
    required String title,
    required String content,
  }) async {
    final dto = await _repository.writePrayer(
      categoryId: categoryId,
      title: title,
      content: content,
    );
    return Prayer(
      id: dto.prayerRequestId,
      userId: dto.prayerUserId,
      userName: dto.prayerUserName,
      categoryId: dto.categoryId,
      categoryName: dto.categoryName,
      title: dto.title,
      content: dto.content,
      createdAt: dto.createdAt,
      participationCount: dto.participationCount,
      hasParticipated: false,
      isMine: dto.isMine,
    );
  }

  Future<Prayer> updatePrayer({
    required int prayerRequestId,
    required int categoryId,
    required String title,
    required String content,
  }) async {
    final dto = await _repository.updatePrayer(
      prayerRequestId: prayerRequestId,
      categoryId: categoryId,
      title: title,
      content: content,
    );
    return _prayerFromDetailDto(dto);
  }

  Future<void> deletePrayer(int prayerRequestId) async {
    await _repository.deletePrayer(prayerRequestId);
  }

  Future<PrayerResponse> writePrayerResponse({
    required int prayerRequestId,
    required String message,
  }) async {
    final dto = await _repository.writePrayerResponse(
      prayerRequestId: prayerRequestId,
      message: message,
    );
    return _responseFromDto(dto);
  }

  Future<PrayerResponse> updatePrayerResponse({
    required int responseId,
    required String message,
  }) async {
    final dto = await _repository.updatePrayerResponse(
      responseId: responseId,
      message: message,
    );
    return _responseFromDto(dto);
  }

  Future<void> deletePrayerResponse(int responseId) async {
    await _repository.deletePrayerResponse(responseId);
  }

  Future<PrayerResponse> writeReply({
    required int responseId,
    required String message,
  }) async {
    final dto = await _repository.writeReply(
      responseId: responseId,
      message: message,
    );
    return _responseFromDto(dto);
  }

  Future<List<PrayerResponse>> loadReplies({
    required int responseId,
    required int page,
  }) async {
    final json = await _repository.loadReplies(
      responseId: responseId,
      page: page,
    );
    final replies = (json['replies'] as List?)
            ?.map((e) => _responseFromDto(
                DetailResponseItem.fromJson(e as Map<String, dynamic>)))
            .toList() ??
        [];
    return replies;
  }

  Future<PrayerPage> loadWrittenPrayers({required int page}) async {
    final dto = await _repository.loadWrittenPrayers(page: page);
    return PrayerPage(
      prayers: dto.prayerRequests.map(_prayerFromDto).toList(),
      currentPage: dto.currentPage,
      hasNext: dto.hasNext,
    );
  }

  Future<MyResponsePage> loadParticipatedPrayers({required int page}) async {
    final json = await _repository.loadParticipatedPrayers(page: page);
    final responses = (json['responses'] as List?)
            ?.map((e) => MyResponse(
                  id: e['prayerResponseId'] as int,
                  prayerRequestId: e['prayerRequestId'] as int,
                  prayerRequestTitle: (e['prayerRequestTitle'] ?? '').toString(),
                  categoryId: e['categoryId'] as int? ?? 0,
                  categoryName: (e['categoryName'] ?? '').toString(),
                  message: (e['message'] ?? '').toString(),
                  createdAt: (e['createdAt'] ?? '').toString(),
                ))
            .toList() ??
        [];
    return MyResponsePage(
      responses: responses,
      currentPage: json['currentPage'] as int? ?? 1,
      hasNext: json['hasNext'] as bool? ?? false,
    );
  }

  // DTO → Entity 변환 헬퍼
  Prayer _prayerFromDto(PrayerDetailResponse dto) {
    return Prayer(
      id: dto.prayerRequestId,
      userId: dto.prayerUserId ?? 0,
      userName: dto.prayerUserName,
      categoryId: dto.categoryId ?? 0,
      categoryName: dto.categoryName,
      title: dto.title,
      content: dto.content,
      createdAt: dto.createdAt ?? '',
      participationCount: dto.participationCount,
      hasParticipated: dto.hasParticipated ?? false,
      isMine: dto.isMine,
    );
  }

  Prayer _prayerFromDetailDto(PrayerDetailResponse dto) {
    final prayer = _prayerFromDto(dto);
    prayer.responses = dto.responses?.map(_responseFromDto).toList();
    return prayer;
  }

  PrayerResponse _responseFromDto(DetailResponseItem dto) {
    return PrayerResponse(
      id: dto.prayerResponseId,
      prayerRequestId: dto.prayerRequestId,
      userId: dto.prayerUserId ?? 0,
      userName: dto.prayerUserName ?? '',
      message: dto.message,
      createdAt: dto.createdAt,
      isMine: dto.isMine,
      parentResponseId: dto.parentResponseId,
      replyCount: dto.replyCount ?? 0,
    );
  }

  // 신고/차단
  Future<void> reportPrayer({
    required int prayerRequestId,
    required ReportReasonType reasonType,
    String? reasonDetail,
  }) async {
    await _repository.reportPrayer(
      prayerRequestId: prayerRequestId,
      reasonType: reasonType,
      reasonDetail: reasonDetail,
    );
  }

  Future<void> reportPrayerResponse({
    required int prayerResponseId,
    required ReportReasonType reasonType,
    String? reasonDetail,
  }) async {
    await _repository.reportPrayerResponse(
      prayerResponseId: prayerResponseId,
      reasonType: reasonType,
      reasonDetail: reasonDetail,
    );
  }

  Future<void> blockUser(int userId) async {
    await _repository.blockUser(userId);
  }

  Future<BlockedUserPage> loadBlockList({required int page}) async {
    final result = await _repository.loadBlockList(page: page);
    return BlockedUserPage(
      blockedUsers: result.blocks
          .map((dto) => BlockedUser(
                id: dto.blockId,
                userId: dto.blockedUserId,
                userName: dto.blockedUserName,
                createdAt: dto.createdAt,
              ))
          .toList(),
      currentPage: result.currentPage,
      hasNext: result.currentPage < result.totalPages,
    );
  }

  Future<void> unblockUser(int userId) async {
    await _repository.unblockUser(userId);
  }
}
