import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers.dart';
import 'home_state.dart';

/// iOS HomeViewModel 대응
class HomeNotifier extends Notifier<HomeState> {
  bool _hasInitialized = false;

  @override
  HomeState build() => const HomeState();

  /// iOS: initializeIfNeeded()
  Future<void> initializeIfNeeded() async {
    if (_hasInitialized) return;
    _hasInitialized = true;

    try {
      final prayerUseCase = ref.read(prayerUseCaseProvider);
      final categories = await prayerUseCase.loadCategories();
      if (categories.isEmpty) return;

      state = state.copyWith(
        categories: categories,
        selectedCategoryId: categories.first.id,
      );

      await _loadPrayers(categoryId: categories.first.id, reset: true);
    } catch (e) {
      state = state.copyWith(errorMessage: () => e.toString());
    }
  }

  /// iOS: selectCategory(categoryID:)
  Future<void> selectCategory(int categoryId) async {
    if (state.isLoading) return;

    if (state.selectedCategoryId == categoryId) {
      await refreshPrayers();
    } else {
      state = state.copyWith(selectedCategoryId: categoryId);
      await _loadPrayers(categoryId: categoryId, reset: true);
    }
  }

  /// iOS: refreshPrayers()
  Future<void> refreshPrayers() async {
    if (state.isRefreshing) return;
    state = state.copyWith(isRefreshing: true);
    try {
      await _loadPrayers(
        categoryId: state.selectedCategoryId,
        reset: true,
      );
    } catch (e) {
      state = state.copyWith(errorMessage: () => e.toString());
    }
    state = state.copyWith(isRefreshing: false);
  }

  /// iOS: loadMorePrayers()
  Future<void> loadMorePrayers() async {
    if (state.isLoading || !state.hasNext) return;
    try {
      await _loadPrayers(
        categoryId: state.selectedCategoryId,
        reset: false,
      );
    } catch (e) {
      state = state.copyWith(errorMessage: () => e.toString());
    }
  }

  /// iOS: loadPrayers(categoryID:reset:)
  Future<void> _loadPrayers({
    required int categoryId,
    required bool reset,
  }) async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true);

    try {
      final prayerUseCase = ref.read(prayerUseCaseProvider);
      final pageToLoad = reset ? 1 : state.currentPage + 1;

      final prayerPage = await prayerUseCase.loadPrayers(
        categoryId: categoryId,
        page: pageToLoad,
      );

      // 카테고리가 바뀌었으면 무시 (iOS guard categoryID == self.selectedCategoryId)
      if (categoryId != state.selectedCategoryId) return;

      if (reset) {
        state = state.copyWith(
          prayers: prayerPage.prayers,
          currentPage: 1,
          hasNext: prayerPage.hasNext,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          prayers: [...state.prayers, ...prayerPage.prayers],
          currentPage: pageToLoad,
          hasNext: prayerPage.hasNext,
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: () => e.toString(),
      );
    }
  }

  void clearError() {
    state = state.copyWith(errorMessage: () => null);
  }
}

final homeNotifierProvider =
    NotifierProvider<HomeNotifier, HomeState>(HomeNotifier.new);
