import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/time_ago.dart';
import '../../domain/entities/prayer.dart';
import '../../domain/entities/my_response.dart';
import '../components/prayer_row.dart';
import '../prayer_detail/prayer_detail_view.dart';

/// iOS MyPrayerView 대응
/// 내가 쓴 기도 + 내가 기도한 기도 (각 상위 3개 표시)
class MyPrayerView extends ConsumerStatefulWidget {
  const MyPrayerView({super.key});

  @override
  ConsumerState<MyPrayerView> createState() => _MyPrayerViewState();
}

class _MyPrayerViewState extends ConsumerState<MyPrayerView> {
  List<Prayer> _writtenPrayers = [];
  List<MyResponse> _participatedPrayers = [];
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initialize());
  }

  Future<void> _initialize() async {
    if (_initialized) return;
    _initialized = true;
    await _refresh();
  }

  Future<void> _refresh() async {
    try {
      final useCase = ref.read(prayerUseCaseProvider);
      final written = await useCase.loadWrittenPrayers(page: 1);
      final participated = await useCase.loadParticipatedPrayers(page: 1);
      if (mounted) {
        setState(() {
          _writtenPrayers = written.prayers;
          _participatedPrayers = participated.responses;
        });
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('내 기도', style: TextStyle(fontWeight: FontWeight.bold))),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          children: [
            // 내가 올린 기도 제목
            _sectionHeader('내가 올린 기도 제목', onMore: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => _FullListView(
                    title: '내가 올린 기도 제목',
                    type: _ListType.written,
                  ),
                ),
              ).then((_) => _refresh());
            }),
            if (_writtenPrayers.isEmpty)
              _emptyView('아직 기도가 없어요', '첫 번째 기도를 작성해보세요')
            else
              ..._writtenPrayers.take(3).map((prayer) => Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 8),
                    child: Dismissible(
                      key: Key('prayer_${prayer.id}'),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        color: Colors.red,
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (_) async {
                        try {
                          await ref
                              .read(prayerUseCaseProvider)
                              .deletePrayer(prayer.id);
                          setState(() =>
                              _writtenPrayers.removeWhere((p) => p.id == prayer.id));
                        } catch (_) {}
                      },
                      child: PrayerRow(
                        prayer: prayer,
                        cellType: PrayerCellType.mine,
                        onTap: () => _navigateToDetail(prayer.id),
                      ),
                    ),
                  )),

            const SizedBox(height: 16),

            // 내가 기도한 기도 제목
            _sectionHeader('내가 기도한 기도 제목', onMore: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => _FullListView(
                    title: '내가 기도한 기도 제목',
                    type: _ListType.participated,
                  ),
                ),
              ).then((_) => _refresh());
            }),
            if (_participatedPrayers.isEmpty)
              _emptyView('아직 함께한 기도가 없어요', '다른 사람의 기도에 함께 기도해보세요')
            else
              ..._participatedPrayers.take(3).map((response) => Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 8),
                    child: Dismissible(
                      key: Key('response_${response.id}'),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        color: Colors.red,
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (_) async {
                        try {
                          await ref
                              .read(prayerUseCaseProvider)
                              .deletePrayerResponse(response.id);
                          setState(() => _participatedPrayers
                              .removeWhere((r) => r.id == response.id));
                        } catch (_) {}
                      },
                      child: _responseRow(response),
                    ),
                  )),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, {VoidCallback? onMore}) {
    return GestureDetector(
      onTap: onMore,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
        child: Row(
          children: [
            Text(title,
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            if (onMore != null) ...[
              const SizedBox(width: 4),
              Icon(Icons.chevron_right,
                  size: 20, color: Colors.grey.shade500),
            ],
            const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _emptyView(String title, String subtitle) {
    return SizedBox(
      height: 180,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.volunteer_activism,
                size: 40, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text(title,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
            const SizedBox(height: 4),
            Text(subtitle,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }

  /// iOS MyResponseRowView 대응
  Widget _responseRow(MyResponse response) {
    return GestureDetector(
      onTap: () => _navigateToDetail(response.prayerRequestId),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('"${response.prayerRequestTitle}"',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 13, color: Colors.grey.shade600)),
            const SizedBox(height: 15),
            Text(response.message,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            Text(timeAgo(response.createdAt),
                style: TextStyle(
                    fontSize: 11, color: Colors.grey.shade500)),
          ],
        ),
      ),
    );
  }

  void _navigateToDetail(int prayerRequestId) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PrayerDetailView(prayerRequestId: prayerRequestId),
      ),
    );
    if (result == true) _refresh();
  }
}

// iOS MyPrayerListView 대응 — 전체 리스트 (페이지네이션)
enum _ListType { written, participated }

class _FullListView extends ConsumerStatefulWidget {
  final String title;
  final _ListType type;

  const _FullListView({required this.title, required this.type});

  @override
  ConsumerState<_FullListView> createState() => _FullListViewState();
}

class _FullListViewState extends ConsumerState<_FullListView> {
  final List<dynamic> _items = [];
  int _currentPage = 1;
  bool _hasNext = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadMore();
  }

  Future<void> _loadMore() async {
    if (_isLoading || !_hasNext) return;
    _isLoading = true;

    try {
      final useCase = ref.read(prayerUseCaseProvider);
      if (widget.type == _ListType.written) {
        final page = await useCase.loadWrittenPrayers(page: _currentPage);
        setState(() {
          _items.addAll(page.prayers);
          _hasNext = page.hasNext;
          _currentPage++;
        });
      } else {
        final page = await useCase.loadParticipatedPrayers(page: _currentPage);
        setState(() {
          _items.addAll(page.responses);
          _hasNext = page.hasNext;
          _currentPage++;
        });
      }
    } catch (_) {}
    _isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: _items.length,
        itemBuilder: (context, index) {
          if (index == _items.length - 1) _loadMore();

          final item = _items[index];
          if (widget.type == _ListType.written) {
            final prayer = item as Prayer;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: PrayerRow(
                prayer: prayer,
                onTap: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          PrayerDetailView(prayerRequestId: prayer.id),
                    ),
                  );
                },
              ),
            );
          } else {
            final response = item as MyResponse;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: GestureDetector(
                onTap: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => PrayerDetailView(
                          prayerRequestId: response.prayerRequestId),
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('"${response.prayerRequestTitle}"',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 13, color: Colors.grey.shade600)),
                      const SizedBox(height: 15),
                      Text(response.message,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 15),
                      Text(timeAgo(response.createdAt),
                          style: TextStyle(
                              fontSize: 11, color: Colors.grey.shade500)),
                    ],
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
