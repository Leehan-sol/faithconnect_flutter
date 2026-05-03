import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/entities/blocked_user.dart';
import '../../core/utils/time_ago.dart';

/// iOS BlockListView.swift 대응
class BlockListView extends ConsumerStatefulWidget {
  const BlockListView({super.key});

  @override
  ConsumerState<BlockListView> createState() => _BlockListViewState();
}

class _BlockListViewState extends ConsumerState<BlockListView> {
  List<BlockedUser> _blockedUsers = [];
  bool _isLoading = false;
  int _currentPage = 0;
  bool _hasNext = true;

  @override
  void initState() {
    super.initState();
    _loadInitial();
  }

  Future<void> _loadInitial() async {
    _currentPage = 0;
    _hasNext = true;
    _blockedUsers = [];
    await _loadMore();
  }

  Future<void> _loadMore() async {
    if (!_hasNext || _isLoading) return;
    setState(() => _isLoading = true);

    try {
      final prayerUseCase = ref.read(prayerUseCaseProvider);
      final page = await prayerUseCase.loadBlockList(page: _currentPage + 1);
      setState(() {
        _blockedUsers.addAll(page.blockedUsers);
        _currentPage = page.currentPage;
        _hasNext = page.hasNext;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('불러오기 실패: $e')),
        );
      }
    }
  }

  Future<void> _unblock(BlockedUser user) async {
    try {
      final prayerUseCase = ref.read(prayerUseCaseProvider);
      await prayerUseCase.unblockUser(user.userId);
      setState(() {
        _blockedUsers.removeWhere((u) => u.id == user.id);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('차단 해제 실패: $e')),
        );
      }
    }
  }

  void _showUnblockDialog(BlockedUser user) {
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('차단 해제'),
        content: Text('${user.userName}님의 차단을 해제하시겠습니까?'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.of(context).pop();
              _unblock(user);
            },
            child: const Text('해제'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('차단 관리'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _blockedUsers.isEmpty && !_isLoading
          ? Center(
              child: Text(
                '차단한 사용자가 없습니다.',
                style: TextStyle(color: Colors.grey.shade500),
              ),
            )
          : ListView.builder(
              itemCount: _blockedUsers.length + (_hasNext ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _blockedUsers.length) {
                  _loadMore();
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                final user = _blockedUsers[index];
                return ListTile(
                  title: Text(user.userName),
                  subtitle: Text(
                    timeAgo(user.createdAt),
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                  trailing: ElevatedButton(
                    onPressed: () => _showUnblockDialog(user),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.customBlue1,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('해제', style: TextStyle(fontSize: 13)),
                  ),
                );
              },
            ),
    );
  }
}
