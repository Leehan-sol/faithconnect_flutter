import 'prayer_response.dart';

class PrayerPage {
  final List<Prayer> prayers;
  final int currentPage;
  final bool hasNext;

  const PrayerPage({
    required this.prayers,
    required this.currentPage,
    required this.hasNext,
  });
}

class Prayer {
  final int id;
  final int userId;
  final String userName;
  final int categoryId;
  final String categoryName;
  final String title;
  final String content;
  final String createdAt;
  int participationCount;
  List<PrayerResponse>? responses;
  final bool hasParticipated;
  final bool isMine;

  Prayer({
    required this.id,
    required this.userId,
    required this.userName,
    required this.categoryId,
    required this.categoryName,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.participationCount,
    this.responses,
    required this.hasParticipated,
    required this.isMine,
  });

  Prayer copyWith({int? participationCount}) {
    return Prayer(
      id: id,
      userId: userId,
      userName: userName,
      categoryId: categoryId,
      categoryName: categoryName,
      title: title,
      content: content,
      createdAt: createdAt,
      participationCount: participationCount ?? this.participationCount,
      responses: responses,
      hasParticipated: hasParticipated,
      isMine: isMine,
    );
  }
}
