import '../../domain/entities/prayer.dart';
import '../../domain/entities/prayer_category.dart';

/// iOS HomeViewModel의 @Published 프로퍼티들 대응
class HomeState {
  final List<PrayerCategory> categories;
  final List<Prayer> prayers;
  final int selectedCategoryId;
  final bool isLoading;
  final bool isRefreshing;
  final int currentPage;
  final bool hasNext;
  final String? errorMessage;

  const HomeState({
    this.categories = const [],
    this.prayers = const [],
    this.selectedCategoryId = 0,
    this.isLoading = false,
    this.isRefreshing = false,
    this.currentPage = 1,
    this.hasNext = true,
    this.errorMessage,
  });

  HomeState copyWith({
    List<PrayerCategory>? categories,
    List<Prayer>? prayers,
    int? selectedCategoryId,
    bool? isLoading,
    bool? isRefreshing,
    int? currentPage,
    bool? hasNext,
    String? Function()? errorMessage,
  }) {
    return HomeState(
      categories: categories ?? this.categories,
      prayers: prayers ?? this.prayers,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      currentPage: currentPage ?? this.currentPage,
      hasNext: hasNext ?? this.hasNext,
      errorMessage:
          errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }
}
