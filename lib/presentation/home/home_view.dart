import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../components/category_button.dart';
import '../components/prayer_row.dart';
import '../components/floating_button.dart';
import '../prayer_detail/prayer_detail_view.dart';
import '../prayer_editor/prayer_editor_view.dart';
import 'home_notifier.dart';

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
      body: Column(
        children: [
          // 카테고리 버튼 — 항상 상단 고정
          Padding(
            padding: const EdgeInsets.only(top: 10, left: 15, bottom: 10),
            child: _categoryScrollView(homeState, notifier),
          ),
          // 기도 목록 또는 빈 상태
          Expanded(
            child: homeState.prayers.isEmpty && !homeState.isLoading
                ? _emptyStateView()
                : _prayerListView(homeState, notifier),
          ),
        ],
      ),
    );
  }

  Widget _emptyStateView() {
    return Center(
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
    );
  }

  Widget _prayerListView(homeState, notifier) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollEndNotification &&
            notification.metrics.extentAfter < 200) {
          notifier.loadMorePrayers();
        }
        return false;
      },
      child: RefreshIndicator(
        onRefresh: () => notifier.refreshPrayers(),
        child: ListView.builder(
          controller: widget.scrollController,
          primary: widget.scrollController == null,
          padding: const EdgeInsets.only(top: 10),
          itemCount: homeState.prayers.length,
          itemBuilder: (context, index) {
            final prayer = homeState.prayers[index];
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
      ),
    );
  }

  Widget _categoryScrollView(homeState, notifier) {
    return Align(
      alignment: Alignment.centerLeft,
      child: SingleChildScrollView(
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
      ),
    );
  }
}
