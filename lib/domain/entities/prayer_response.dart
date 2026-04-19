/// iOS PrayerResponse (Response.swift) 대응
class PrayerResponse {
  final int id;
  final int prayerRequestId;
  final int userId;
  final String userName;
  String message;
  final String createdAt;
  final bool isMine;
  final int? parentResponseId;
  int replyCount;
  List<PrayerResponse> replies;

  PrayerResponse({
    required this.id,
    required this.prayerRequestId,
    required this.userId,
    required this.userName,
    required this.message,
    required this.createdAt,
    required this.isMine,
    this.parentResponseId,
    this.replyCount = 0,
    List<PrayerResponse>? replies,
  }) : replies = replies ?? [];
}
