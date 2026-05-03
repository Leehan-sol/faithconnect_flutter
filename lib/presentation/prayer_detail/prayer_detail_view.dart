import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/time_ago.dart';
import '../../data/dtos/report_dtos.dart';
import '../../domain/entities/prayer.dart';
import '../../domain/entities/prayer_response.dart' as entity;
import '../components/action_button.dart';
import '../prayer_editor/prayer_editor_view.dart';

class PrayerDetailView extends ConsumerStatefulWidget {
  final int prayerRequestId;
  const PrayerDetailView({super.key, required this.prayerRequestId});

  @override
  ConsumerState<PrayerDetailView> createState() => _PrayerDetailViewState();
}

class _PrayerDetailViewState extends ConsumerState<PrayerDetailView> {
  Prayer? _prayer;
  bool _isLoading = true;
  bool _dataChanged = false;

  // 대댓글 상태
  entity.PrayerResponse? _replyingTo;
  final _replyController = TextEditingController();
  final _replyFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  @override
  void dispose() {
    _replyController.dispose();
    _replyFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadDetail() async {
    try {
      final prayer = await ref
          .read(prayerUseCaseProvider)
          .loadPrayerDetail(widget.prayerRequestId);
      // 대댓글이 있는 댓글에 대해 대댓글 로드
      if (prayer.responses != null) {
        for (final response in prayer.responses!) {
          if (response.replyCount > 0) {
            try {
              final replies = await ref
                  .read(prayerUseCaseProvider)
                  .loadReplies(responseId: response.id, page: 1);
              response.replies = replies;
            } catch (_) {}
          }
        }
      }
      if (mounted) setState(() { _prayer = prayer; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deletePrayer() async {
    try {
      await ref.read(prayerUseCaseProvider).deletePrayer(_prayer!.id);
      _dataChanged = true;
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      _showAlert('삭제 실패', e.toString());
    }
  }

  void _showAlert(String title, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  void _showReportSheet({int? prayerRequestId, int? prayerResponseId}) {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => CupertinoActionSheet(
        title: const Text('신고 사유를 선택해주세요'),
        actions: ReportReasonType.values.map((reason) {
          return CupertinoActionSheetAction(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                final prayerUseCase = ref.read(prayerUseCaseProvider);
                if (prayerRequestId != null) {
                  await prayerUseCase.reportPrayer(
                    prayerRequestId: prayerRequestId,
                    reasonType: reason,
                  );
                } else if (prayerResponseId != null) {
                  await prayerUseCase.reportPrayerResponse(
                    prayerResponseId: prayerResponseId,
                    reasonType: reason,
                  );
                }
                _showAlert('신고 완료', '신고가 접수되었습니다.');
              } catch (e) {
                _showAlert('신고 실패', e.toString());
              }
            },
            child: Text(reason.displayName),
          );
        }).toList(),
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('취소'),
        ),
      ),
    );
  }

  void _showBlockConfirm({required int userId, required String userName}) {
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('사용자 차단'),
        content: Text('$userName님을 차단하시겠습니까?\n차단된 사용자의 게시물은 더 이상 표시되지 않습니다.'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                await ref.read(prayerUseCaseProvider).blockUser(userId);
                _dataChanged = true;
                _showAlert('차단 완료', '$userName님을 차단했습니다.');
              } catch (e) {
                _showAlert('차단 실패', e.toString());
              }
            },
            child: const Text('차단'),
          ),
        ],
      ),
    );
  }

  // ==================== 기도 응답 바텀시트 (iOS 동일) ====================
  void _showResponseSheet({entity.PrayerResponse? editing}) {
    final controller = TextEditingController(text: editing?.message ?? '');
    int wordCount = editing?.message.length ?? 0;
    final isEdit = editing != null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: GestureDetector(
            onTap: () => FocusScope.of(ctx).unfocus(),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 5),
                  Text(isEdit ? '기도 응답 수정' : '기도 응답 보내기',
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),

                  // 기도 제목 컨텍스트
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 40,
                          height: 30,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.customBlue1.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(_prayer!.categoryName,
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.customNavy)),
                        ),
                        const SizedBox(height: 15),
                        Text(_prayer!.title,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 입력 영역
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Stack(
                      children: [
                        TextField(
                          controller: controller,
                          maxLines: null,
                          expands: true,
                          maxLength: 500,
                          textAlignVertical: TextAlignVertical.top,
                          onChanged: (v) =>
                              setSheetState(() => wordCount = v.length),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(16),
                            counterText: '',
                          ),
                        ),
                        if (controller.text.isEmpty)
                          Positioned(
                            top: 16,
                            left: 16,
                            right: 16,
                            child: IgnorePointer(
                              child: Text(
                                '이 기도제목에 응답하는 메세지를 작성해주세요.\n\n익명으로 전송되며, 작성자에게 알림이 전달됩니다.',
                                style: TextStyle(color: Colors.grey.shade400),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // 글자 수
                  Row(
                    children: [
                      Text('따뜻한 격려의 메시지를 보내주세요.',
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade500)),
                      const Spacer(),
                      Text('$wordCount / 500',
                          style: TextStyle(
                              fontSize: 12,
                              color:
                                  wordCount >= 500 ? Colors.red : Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // 취소 + 전송 버튼
                  Row(
                    children: [
                      Expanded(
                        child: ActionButton(
                          title: '취소',
                          foregroundColor: Colors.grey,
                          backgroundColor: Colors.grey.shade100,
                          onPressed: () => Navigator.of(ctx).pop(),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ActionButton(
                          title: isEdit ? '수정' : '전송',
                          foregroundColor:
                              wordCount > 0 ? Colors.white : Colors.grey,
                          backgroundColor: wordCount > 0
                              ? AppColors.customBlue1
                              : Colors.grey.shade100,
                          onPressed: wordCount > 0
                              ? () async {
                                  try {
                                    if (isEdit) {
                                      final updated = await ref
                                          .read(prayerUseCaseProvider)
                                          .updatePrayerResponse(
                                            responseId: editing.id,
                                            message: controller.text.trim(),
                                          );
                                      _dataChanged = true;
                                      setState(() {
                                        final idx = _prayer!.responses!
                                            .indexWhere(
                                                (r) => r.id == editing.id);
                                        if (idx != -1) {
                                          _prayer!.responses![idx].message =
                                              updated.message;
                                        }
                                      });
                                    } else {
                                      final response = await ref
                                          .read(prayerUseCaseProvider)
                                          .writePrayerResponse(
                                            prayerRequestId: _prayer!.id,
                                            message: controller.text.trim(),
                                          );
                                      _dataChanged = true;
                                      setState(() {
                                        _prayer!.responses ??= [];
                                        _prayer!.responses!.add(response);
                                        _prayer!.participationCount += 1;
                                      });
                                    }
                                    if (mounted) Navigator.of(ctx).pop();
                                  } catch (e) {
                                    if (mounted) Navigator.of(ctx).pop();
                                    _showAlert(
                                        isEdit ? '수정 실패' : '작성 실패',
                                        e.toString());
                                  }
                                }
                              : null,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ==================== 더보기 (기도) ====================
  void _showMoreOptions() {
    final actions = _prayer?.isMine == true
        ? [
            CupertinoActionSheetAction(
              onPressed: () async {
                Navigator.of(context).pop();
                final result = await Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => PrayerEditorView(prayer: _prayer)),
                );
                if (result == true) { _dataChanged = true; _loadDetail(); }
              },
              child: const Text('수정'),
            ),
            CupertinoActionSheetAction(
              isDestructiveAction: true,
              onPressed: () {
                Navigator.of(context).pop();
                showCupertinoDialog(
                  context: context,
                  builder: (_) => CupertinoAlertDialog(
                    title: const Text('삭제'),
                    content: const Text('이 기도를 삭제하시겠습니까?'),
                    actions: [
                      CupertinoDialogAction(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('취소')),
                      CupertinoDialogAction(
                          isDestructiveAction: true,
                          onPressed: () {
                            Navigator.of(context).pop();
                            _deletePrayer();
                          },
                          child: const Text('삭제')),
                    ],
                  ),
                );
              },
              child: const Text('삭제'),
            ),
          ]
        : [
            CupertinoActionSheetAction(
                isDestructiveAction: true,
                onPressed: () {
                  Navigator.of(context).pop();
                  _showReportSheet(prayerRequestId: _prayer!.id);
                },
                child: const Text('신고')),
            CupertinoActionSheetAction(
                isDestructiveAction: true,
                onPressed: () {
                  Navigator.of(context).pop();
                  _showBlockConfirm(userId: _prayer!.userId, userName: _prayer!.userName);
                },
                child: const Text('차단')),
          ];

    showCupertinoModalPopup(
      context: context,
      builder: (_) => CupertinoActionSheet(
        actions: actions,
        cancelButton: CupertinoActionSheetAction(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소')),
      ),
    );
  }

  // ==================== 더보기 (댓글) ====================
  void _showCommentOptions(entity.PrayerResponse response) {
    final actions = response.isMine
        ? [
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.of(context).pop();
                _showResponseSheet(editing: response);
              },
              child: const Text('수정'),
            ),
            CupertinoActionSheetAction(
              isDestructiveAction: true,
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  await ref
                      .read(prayerUseCaseProvider)
                      .deletePrayerResponse(response.id, prayerRequestId: _prayer!.id);
                  _dataChanged = true;
                  setState(() {
                    _prayer!.responses!
                        .removeWhere((r) => r.id == response.id);
                    _prayer!.participationCount -= 1;
                  });
                } catch (e) {
                  _showAlert('삭제 실패', e.toString());
                }
              },
              child: const Text('삭제'),
            ),
          ]
        : [
            CupertinoActionSheetAction(
                isDestructiveAction: true,
                onPressed: () {
                  Navigator.of(context).pop();
                  _showReportSheet(prayerResponseId: response.id);
                },
                child: const Text('신고')),
            CupertinoActionSheetAction(
                isDestructiveAction: true,
                onPressed: () {
                  Navigator.of(context).pop();
                  _showBlockConfirm(userId: response.userId, userName: response.userName);
                },
                child: const Text('차단')),
          ];

    showCupertinoModalPopup(
      context: context,
      builder: (_) => CupertinoActionSheet(
        actions: actions,
        cancelButton: CupertinoActionSheetAction(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소')),
      ),
    );
  }

  // ==================== 대댓글 ====================
  void _startReply(entity.PrayerResponse response) {
    setState(() {
      _replyingTo = response;
      _replyController.clear();
    });
    _replyFocusNode.requestFocus();
  }

  void _cancelReply() {
    setState(() {
      _replyingTo = null;
      _replyController.clear();
    });
  }

  Future<void> _sendReply() async {
    if (_replyingTo == null || _replyController.text.trim().isEmpty) return;
    try {
      final reply = await ref.read(prayerUseCaseProvider).writeReply(
            responseId: _replyingTo!.id,
            message: _replyController.text.trim(),
          );
      _dataChanged = true;
      setState(() {
        final idx =
            _prayer!.responses!.indexWhere((r) => r.id == _replyingTo!.id);
        if (idx != -1) {
          _prayer!.responses![idx].replies.add(reply);
          _prayer!.responses![idx].replyCount += 1;
          _prayer!.participationCount += 1;
        }
        _replyingTo = null;
        _replyController.clear();
      });
    } catch (e) {
      _showAlert('답글 작성 실패', e.toString());
    }
  }

  // ==================== BUILD ====================
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) Navigator.of(context).pop(_dataChanged);
      },
      child: Scaffold(
        appBar: AppBar(
          actions: [
            if (_prayer != null)
              IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: _showMoreOptions),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _prayer == null
                ? const Center(child: Text('기도를 불러올 수 없습니다'))
                : Column(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            FocusScope.of(context).unfocus();
                            if (_replyingTo != null) _cancelReply();
                          },
                          child: RefreshIndicator(
                            onRefresh: _loadDetail,
                            child: ListView(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              children: [
                                const SizedBox(height: 10),
                                _buildHeader(),
                                const SizedBox(height: 25),
                                Text(_prayer!.title,
                                    style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(height: 25),
                                Text(_prayer!.content,
                                    style: const TextStyle(
                                        fontSize: 15, height: 1.6)),
                                const Divider(height: 40),
                                Text(
                                  '${_prayer!.participationCount}명이 기도했어요',
                                  style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey.shade700),
                                ),
                                const SizedBox(height: 16),
                                // 댓글 + 대댓글
                                if (_prayer!.responses != null)
                                  ..._prayer!.responses!
                                      .map((r) => _commentSection(r)),
                                const SizedBox(height: 80),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // 대댓글 입력 바
                      if (_replyingTo != null) _replyInputBar(),
                      // 기도 응답하기 버튼
                      if (_replyingTo == null)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
                          child: ActionButton(
                            title: '기도 응답하기',
                            foregroundColor: Colors.white,
                            backgroundColor: AppColors.customBlue1,
                            onPressed: () => _showResponseSheet(),
                          ),
                        ),
                    ],
                  ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 40,
          height: 30,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.customBlue1.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(_prayer!.categoryName,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.customNavy)),
        ),
        const SizedBox(width: 8),
        Text(_prayer!.userName,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
        const SizedBox(width: 8),
        Text(timeAgo(_prayer!.createdAt),
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
        const Spacer(),
      ],
    );
  }

  // ==================== 댓글 섹션 (댓글 + 대댓글) ====================
  Widget _commentSection(entity.PrayerResponse response) {
    return Column(
      children: [
        // 댓글 카드
        _commentCard(response),
        // 대댓글 목록
        if (response.replies.isNotEmpty)
          Column(
            children: response.replies
                .map((reply) => _replyCard(reply, response))
                .toList(),
          ),
        const SizedBox(height: 4),
      ],
    );
  }

  // ==================== 댓글 카드 (iOS CommentRowView) ====================
  Widget _commentCard(entity.PrayerResponse response) {
    final isUnavailable = response.userName.trim().isEmpty;
    final isWithdrawnUser = response.userName == '탈퇴한 사용자';

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 35,
              height: 35,
              decoration: BoxDecoration(
                color: isUnavailable
                    ? Colors.grey.shade400
                    : AppColors.customBlue1.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(Icons.people,
                  size: 18,
                  color: isUnavailable ? Colors.grey : AppColors.customNavy),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: isUnavailable
                  ? Text(response.message,
                      style: TextStyle(
                          fontSize: 14, color: Colors.grey.shade500))
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(response.userName,
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade600)),
                            const Spacer(),
                            if (!isWithdrawnUser)
                              GestureDetector(
                                onTap: () => _showCommentOptions(response),
                                child: Padding(
                                  padding: const EdgeInsets.all(4),
                                  child: Icon(Icons.more_vert,
                                      size: 22, color: Colors.grey.shade500),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(timeAgo(response.createdAt),
                            style: TextStyle(
                                fontSize: 11, color: Colors.grey.shade500)),
                        const SizedBox(height: 8),
                        Text(response.message.trim(),
                            style: const TextStyle(fontSize: 17, height: 1.4)),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: () => _startReply(response),
                            child: Text(
                              response.replyCount > 0
                                  ? '답글 (${response.replyCount})'
                                  : '답글',
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.customBlue1),
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== 대댓글 카드 (iOS ReplyRowView) ====================
  Widget _replyCard(
      entity.PrayerResponse reply, entity.PrayerResponse parent) {
    final isUnavailable = reply.userName.trim().isEmpty;
    final isWithdrawnUser = reply.userName == '탈퇴한 사용자';

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 35,
              height: 35,
              decoration: BoxDecoration(
                color: isUnavailable
                    ? Colors.grey.shade400
                    : AppColors.customBlue1.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(Icons.subdirectory_arrow_right,
                  size: 18,
                  color: isUnavailable
                      ? Colors.grey
                      : AppColors.customNavy.withValues(alpha: 0.5)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: isUnavailable
                  ? Text(reply.message,
                      style: TextStyle(
                          fontSize: 14, color: Colors.grey.shade500))
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(reply.userName,
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade600)),
                            const Spacer(),
                            if (!isWithdrawnUser)
                              GestureDetector(
                                onTap: () => _showCommentOptions(reply),
                                child: Padding(
                                  padding: const EdgeInsets.all(4),
                                  child: Icon(Icons.more_vert,
                                      size: 22, color: Colors.grey.shade500),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(timeAgo(reply.createdAt),
                            style: TextStyle(
                                fontSize: 11, color: Colors.grey.shade500)),
                        const SizedBox(height: 8),
                        Text(reply.message.trim(),
                            style: const TextStyle(fontSize: 17, height: 1.4)),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== 대댓글 입력 바 ====================
  Widget _replyInputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 8, 8, 30),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _replyController,
              focusNode: _replyFocusNode,
              decoration: InputDecoration(
                hintText: '${_replyingTo?.userName ?? ''}님에게 답글 작성...',
                hintStyle: TextStyle(fontSize: 14, color: Colors.grey.shade400),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send, color: AppColors.customBlue1),
            onPressed: _sendReply,
          ),
          IconButton(
            icon: Icon(Icons.close, color: Colors.grey.shade500),
            onPressed: _cancelReply,
          ),
        ],
      ),
    );
  }
}
