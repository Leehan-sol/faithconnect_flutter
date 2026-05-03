class MyResponse {
  final int id;
  final int prayerRequestId;
  final String prayerRequestTitle;
  final int categoryId;
  final String categoryName;
  String message;
  final String createdAt;

  MyResponse({
    required this.id,
    required this.prayerRequestId,
    required this.prayerRequestTitle,
    required this.categoryId,
    required this.categoryName,
    required this.message,
    required this.createdAt,
  });
}

class MyResponsePage {
  final List<MyResponse> responses;
  final int currentPage;
  final bool hasNext;

  const MyResponsePage({
    required this.responses,
    required this.currentPage,
    required this.hasNext,
  });
}
