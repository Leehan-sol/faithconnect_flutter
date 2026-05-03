import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../components/category_button.dart';
import '../components/prayer_row.dart';
import '../components/floating_button.dart';
import '../prayer_detail/prayer_detail_view.dart';
import '../prayer_editor/prayer_editor_view.dart';
import 'home_notifier.dart';

/// iOS HomeView 대응
///
/// === SwiftUI vs Flutter 매핑 ===
/// List + .refreshable      → RefreshIndicator + ListView.builder
/// ScrollView(.horizontal)  → SingleChildScrollView(scrollDirection: Axis.horizontal)
/// .onAppear (마지막 아이템) → index 체크로 페이지네이션
/// ZStack { FloatingButton } → Scaffold.floatingActionButton
/// .task { initializeIfNeeded } → initState + addPostFrameCallback
class HomeView extends ConsumerStatefulWidget {
  final ScrollController? scrollController;

  const HomeView({super.key, this.scrollController});

  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(homeNotifierProvider.notifier).initializeIfNeeded();
    });
  }

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeNotifierProvider);
    final notifier = ref.read(homeNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () {
            if (widget.scrollController?.hasClients == true) {
              widget.scrollController!.animateTo(
                0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            }
          },
          child: const Text('기도 모음', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ),
      floatingActionButton: FloatingButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const PrayerEditorView()),
          );
        },
      ),
      body: homeState.prayers.isEmpty && !homeState.isLoading
          ? _emptyStateView(homeState, notifier)
          : _prayerListView(homeState, notifier),
    );
  }

  Widget _emptyStateView(homeState, notifier) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 10, left: 15, bottom: 10),
          child: _categoryScrollView(homeState, notifier),
        ),
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.volunteer_activism,
                  size: 50,
                  color: Colors.grey.shade300,
                ),
                const SizedBox(height: 16),
                Text(
                  '아직 기도가 없어요',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '첫 번째 기도를 작성해보세요',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// RefreshIndicator + ListView.builder
  /// iOS: List + .refreshable + .onAppear(pagination)
  Widget _prayerListView(homeState, notifier) {
    return RefreshIndicator(
      onRefresh: () => notifier.refreshPrayers(),
      child: ListView.builder(
        controller: widget.scrollController,
        primary: widget.scrollController == null,
        itemCount: homeState.prayers.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(top: 10, left: 15, bottom: 20),
              child: _categoryScrollView(homeState, notifier),
            );
          }

          final prayerIndex = index - 1;
          final prayer = homeState.prayers[prayerIndex];

          // 마지막 아이템 → 다음 페이지 로드
          if (prayerIndex == homeState.prayers.length - 1) {
            notifier.loadMorePrayers();
          }

          return Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 16),
            child: PrayerRow(
              prayer: prayer,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        PrayerDetailView(prayerRequestId: prayer.id),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  /// 가로 스크롤 카테고리 필터
  Widget _categoryScrollView(homeState, notifier) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: homeState.categories
            .map<Widget>((category) => Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: CategoryButton(
                    category: category,
                    isSelected: category.id == homeState.selectedCategoryId,
                    onTap: () => notifier.selectCategory(category.id),
                  ),
                ))
            .toList(),
      ),
    );
  }
}
