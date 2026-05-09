import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../data/storage/user_session.dart';
import '../components/action_button.dart';
import '../login/login_notifier.dart';

class DeleteAccountView extends ConsumerStatefulWidget {
  const DeleteAccountView({super.key});

  @override
  ConsumerState<DeleteAccountView> createState() => _DeleteAccountViewState();
}

class _DeleteAccountViewState extends ConsumerState<DeleteAccountView> {
  static const _reasons = [
    '자주 사용하지 않아요',
    '서비스가 불만족스러워요',
    '기타',
  ];

  String? _selectedReason;
  bool _agreedToTerms = false;
  bool _isLoading = false;

  bool get _isDeleteButtonActive => _selectedReason != null && _agreedToTerms;

  Future<void> _deleteAccount() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(authUseCaseProvider).deleteAccount();
      if (!mounted) return;
      setState(() => _isLoading = false);
      showCupertinoDialog(
        context: context,
        builder: (_) => CupertinoAlertDialog(
          title: const Text('탈퇴 완료'),
          content: const Text('그동안 이용해 주셔서 감사합니다.'),
          actions: [
            CupertinoDialogAction(
              onPressed: () {
                Navigator.of(context).pop();
                ref.read(userSessionProvider.notifier).logout();
                ref.invalidate(loginNotifierProvider);
              },
              child: const Text('확인'),
            ),
          ],
        ),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      showCupertinoDialog(
        context: context,
        builder: (_) => CupertinoAlertDialog(
          title: const Text('회원탈퇴 실패'),
          content: Text(e.toString()),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('확인'),
            ),
          ],
        ),
      );
    }
  }

  void _showDeleteConfirm() {
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('회원탈퇴'),
        content: const Text('정말 탈퇴하시겠습니까?\n탈퇴 시 모든 데이터가 삭제됩니다.'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.of(context).pop();
              _deleteAccount();
            },
            child: const Text('탈퇴'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('회원탈퇴'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 안내 박스
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.error_outline,
                                    color: Colors.red, size: 20),
                                const SizedBox(width: 8),
                                const Text('탈퇴 전 꼭 확인해주세요',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red)),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const Text('• 작성한 모든 기도제목은 삭제되지 않습니다',
                                style: TextStyle(color: Colors.red, fontSize: 13)),
                            const SizedBox(height: 4),
                            const Text('• 받은 응답 내역이 모두 사라집니다',
                                style: TextStyle(color: Colors.red, fontSize: 13)),
                            const SizedBox(height: 4),
                            const Text('• 계정 정보는 복구할 수 없습니다',
                                style: TextStyle(color: Colors.red, fontSize: 13)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),

                      // 탈퇴 사유
                      const Text('탈퇴 사유를 알려주세요',
                          style: TextStyle(
                              fontSize: 17, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('더 나은 서비스를 위해 소중한 의견을 들려주세요.',
                          style: TextStyle(
                              fontSize: 14, color: Colors.grey.shade600)),
                      const SizedBox(height: 16),

                      ...(_reasons.map((reason) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: GestureDetector(
                              onTap: () =>
                                  setState(() => _selectedReason = reason),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: _selectedReason == reason
                                        ? AppColors.customBlue1
                                        : Colors.grey.shade200,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Text(reason,
                                        style:
                                            const TextStyle(fontSize: 15)),
                                    const Spacer(),
                                    Icon(
                                      _selectedReason == reason
                                          ? Icons.radio_button_checked
                                          : Icons.radio_button_off,
                                      color: _selectedReason == reason
                                          ? Colors.black
                                          : Colors.grey.shade400,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ))),

                      const SizedBox(height: 8),

                      // 동의 체크
                      GestureDetector(
                        onTap: () =>
                            setState(() => _agreedToTerms = !_agreedToTerms),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              _agreedToTerms
                                  ? Icons.check_box
                                  : Icons.check_box_outline_blank,
                              color: _agreedToTerms
                                  ? Colors.black
                                  : Colors.grey.shade300,
                            ),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Text(
                                '위 안내사항을 모두 확인했으며, 회원 탈퇴에 동의합니다.',
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 하단 버튼
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                child: Column(
                  children: [
                    ActionButton(
                      title: '회원 탈퇴',
                      foregroundColor:
                          _isDeleteButtonActive ? Colors.white : Colors.grey,
                      backgroundColor: _isDeleteButtonActive
                          ? AppColors.customBlue1
                          : Colors.grey.shade200,
                      onPressed:
                          _isDeleteButtonActive ? _showDeleteConfirm : null,
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('계정 유지하기',
                          style: TextStyle(
                              fontSize: 14, color: AppColors.customBlue1)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_isLoading)
            Container(
              color: Colors.black12,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
