/// iOS ReportDTOs.swift 대응

enum ReportReasonType {
  inappropriateContent,
  spam,
  other;

  String get value {
    switch (this) {
      case ReportReasonType.inappropriateContent:
        return 'INAPPROPRIATE_CONTENT';
      case ReportReasonType.spam:
        return 'SPAM';
      case ReportReasonType.other:
        return 'OTHER';
    }
  }

  String get displayName {
    switch (this) {
      case ReportReasonType.inappropriateContent:
        return '부적절한 내용';
      case ReportReasonType.spam:
        return '스팸/광고/중복게시';
      case ReportReasonType.other:
        return '기타';
    }
  }
}

class ReportPrayerRequest {
  final ReportReasonType reasonType;
  final String? reasonDetail;

  const ReportPrayerRequest({required this.reasonType, this.reasonDetail});

  Map<String, dynamic> toJson() => {
        'reasonType': reasonType.value,
        if (reasonDetail != null) 'reasonDetail': reasonDetail,
      };
}

class ReportResponse {
  final String message;
  final bool? success;

  const ReportResponse({required this.message, this.success});

  factory ReportResponse.fromJson(Map<String, dynamic> json) => ReportResponse(
        message: json['message']?.toString() ?? '',
        success: json['success'] as bool?,
      );
}

class BlockResponse {
  final String message;
  final bool? success;

  const BlockResponse({required this.message, this.success});

  factory BlockResponse.fromJson(Map<String, dynamic> json) => BlockResponse(
        message: json['message']?.toString() ?? '',
        success: json['success'] as bool?,
      );
}

class BlockListResponse {
  final List<BlockItem> blocks;
  final int currentPage;
  final int totalPages;
  final int totalElements;

  const BlockListResponse({
    required this.blocks,
    required this.currentPage,
    required this.totalPages,
    required this.totalElements,
  });

  factory BlockListResponse.fromJson(Map<String, dynamic> json) =>
      BlockListResponse(
        blocks: (json['blocks'] as List?)
                ?.map((e) => BlockItem.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        currentPage: json['currentPage'] as int? ?? 0,
        totalPages: json['totalPages'] as int? ?? 0,
        totalElements: json['totalElements'] as int? ?? 0,
      );
}

class BlockItem {
  final int blockId;
  final int blockedUserId;
  final String blockedUserName;
  final String createdAt;

  const BlockItem({
    required this.blockId,
    required this.blockedUserId,
    required this.blockedUserName,
    required this.createdAt,
  });

  factory BlockItem.fromJson(Map<String, dynamic> json) => BlockItem(
        blockId: json['blockId'] as int? ?? 0,
        blockedUserId: json['blockedUserId'] as int? ?? 0,
        blockedUserName: json['blockedUserName']?.toString() ?? '',
        createdAt: json['createdAt']?.toString() ?? '',
      );
}
