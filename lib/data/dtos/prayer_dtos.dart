/// iOS PrayerDTOs.swift + CategoryDTOs.swift 대응

class CategoryResponse {
  final int categoryId;
  final int categoryCode;
  final String categoryName;

  const CategoryResponse({
    required this.categoryId,
    required this.categoryCode,
    required this.categoryName,
  });

  factory CategoryResponse.fromJson(Map<String, dynamic> json) =>
      CategoryResponse(
        categoryId: json['categoryId'] as int,
        categoryCode: json['categoryCode'] as int,
        categoryName: json['categoryName'] as String,
      );
}

class PrayerListResponse {
  final List<PrayerDetailResponse> prayerRequests;
  final int currentPage;
  final bool hasNext;

  const PrayerListResponse({
    required this.prayerRequests,
    required this.currentPage,
    required this.hasNext,
  });

  factory PrayerListResponse.fromJson(Map<String, dynamic> json) =>
      PrayerListResponse(
        prayerRequests: (json['prayerRequests'] as List)
            .map((e) =>
                PrayerDetailResponse.fromJson(e as Map<String, dynamic>))
            .toList(),
        currentPage: json['currentPage'] as int,
        hasNext: json['hasNext'] as bool,
      );
}

class PrayerDetailResponse {
  final int prayerRequestId;
  final int? prayerUserId;
  final String prayerUserName;
  final int? categoryId;
  final String categoryName;
  final String title;
  final String content;
  final String? createdAt;
  final int participationCount;
  final List<DetailResponseItem>? responses;
  final bool? hasParticipated;
  final bool isMine;

  const PrayerDetailResponse({
    required this.prayerRequestId,
    this.prayerUserId,
    required this.prayerUserName,
    this.categoryId,
    required this.categoryName,
    required this.title,
    required this.content,
    this.createdAt,
    required this.participationCount,
    this.responses,
    this.hasParticipated,
    required this.isMine,
  });

  factory PrayerDetailResponse.fromJson(Map<String, dynamic> json) =>
      PrayerDetailResponse(
        prayerRequestId: json['prayerRequestId'] as int,
        prayerUserId: json['prayerUserId'] as int?,
        prayerUserName: (json['prayerUserName'] ?? '').toString(),
        categoryId: json['categoryId'] as int?,
        categoryName: (json['categoryName'] ?? '').toString(),
        title: (json['title'] ?? '').toString(),
        content: (json['content'] ?? '').toString(),
        createdAt: json['createdAt'] as String?,
        participationCount: json['participationCount'] as int? ?? 0,
        responses: json['responses'] != null
            ? (json['responses'] as List)
                .map((e) =>
                    DetailResponseItem.fromJson(e as Map<String, dynamic>))
                .toList()
            : null,
        hasParticipated: json['hasParticipated'] as bool?,
        isMine: json['isMine'] as bool? ?? false,
      );
}

class DetailResponseItem {
  final int prayerResponseId;
  final int prayerRequestId;
  final int? prayerUserId;
  final String? prayerUserName;
  final String message;
  final String createdAt;
  final bool isMine;
  final int? parentResponseId;
  final int? replyCount;

  const DetailResponseItem({
    required this.prayerResponseId,
    required this.prayerRequestId,
    this.prayerUserId,
    this.prayerUserName,
    required this.message,
    required this.createdAt,
    required this.isMine,
    this.parentResponseId,
    this.replyCount,
  });

  factory DetailResponseItem.fromJson(Map<String, dynamic> json) =>
      DetailResponseItem(
        prayerResponseId: json['prayerResponseId'] as int,
        prayerRequestId: json['prayerRequestId'] as int,
        prayerUserId: json['prayerUserId'] as int?,
        prayerUserName: json['prayerUserName']?.toString(),
        message: (json['message'] ?? '').toString(),
        createdAt: (json['createdAt'] ?? '').toString(),
        isMine: json['isMine'] as bool? ?? false,
        parentResponseId: json['parentResponseId'] as int?,
        replyCount: json['replyCount'] as int?,
      );
}

class PrayerWriteResponse {
  final int prayerRequestId;
  final int prayerUserId;
  final String prayerUserName;
  final int categoryId;
  final String categoryName;
  final String title;
  final String content;
  final String createdAt;
  final int participationCount;
  final bool isMine;

  const PrayerWriteResponse({
    required this.prayerRequestId,
    required this.prayerUserId,
    required this.prayerUserName,
    required this.categoryId,
    required this.categoryName,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.participationCount,
    required this.isMine,
  });

  factory PrayerWriteResponse.fromJson(Map<String, dynamic> json) =>
      PrayerWriteResponse(
        prayerRequestId: json['prayerRequestId'] as int,
        prayerUserId: json['prayerUserId'] as int,
        prayerUserName: (json['prayerUserName'] ?? '').toString(),
        categoryId: json['categoryId'] as int,
        categoryName: (json['categoryName'] ?? '').toString(),
        title: (json['title'] ?? '').toString(),
        content: (json['content'] ?? '').toString(),
        createdAt: (json['createdAt'] ?? '').toString(),
        participationCount: json['participationCount'] as int? ?? 0,
        isMine: json['isMine'] as bool? ?? false,
      );
}
