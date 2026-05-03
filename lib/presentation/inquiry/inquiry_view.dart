import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../data/storage/user_session.dart';
import '../components/labeled_text_field.dart';
import '../components/action_button.dart';
import '../components/loading_dialog.dart';

/// iOS InquiryBottomSheetView.swift 대응
class InquiryView extends ConsumerStatefulWidget {
  const InquiryView({super.key});

  @override
  ConsumerState<InquiryView> createState() => _InquiryViewState();
}

class _InquiryViewState extends ConsumerState<InquiryView> {
  final _emailController = TextEditingController();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final session = ref.read(userSessionProvider);
    _emailController.text = session.email;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  bool get _isSendActive =>
      _titleController.text.isNotEmpty &&
      _contentController.text.isNotEmpty &&
      _emailController.text.isNotEmpty;

  Future<void> _sendInquiry() async {
    if (!_isSendActive) return;

    setState(() => _isLoading = true);
    try {
      final authUseCase = ref.read(authUseCaseProvider);
      await authUseCase.sendInquiry(
        title: _titleController.text,
        content: _contentController.text,
        userEmail: _emailController.text,
      );
      setState(() => _isLoading = false);
      if (mounted) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('문의 완료'),
            content: const Text('문의가 접수되었습니다.\n빠른 시일 내에 답변드리겠습니다.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // dialog
                  Navigator.of(context).pop(); // inquiry view
                },
                child: const Text('확인'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('문의 실패'),
            content: Text(e.toString()),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('확인'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: const Text('문의하기'),
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
          ),
          body: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LabeledTextField(
                          title: '답장 받을 이메일',
                          placeholder: 'example@email.com',
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: 20),
                        LabeledTextField(
                          title: '제목',
                          placeholder: '문의 제목을 입력하세요',
                          controller: _titleController,
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          '문의 내용',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _contentController,
                          maxLines: 8,
                          maxLength: 500,
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(
                            hintText: '문의하실 내용을 자세히 입력해주세요',
                            hintStyle: TextStyle(color: Colors.grey.shade400),
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.all(16),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '• 평일 9:00-18:00 내에 순차적으로 답변드립니다.',
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey.shade600),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: ActionButton(
                          title: '취소',
                          foregroundColor: Colors.grey,
                          backgroundColor: Colors.grey.shade200,
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ActionButton(
                          title: '전송',
                          foregroundColor:
                              _isSendActive ? Colors.white : Colors.grey,
                          backgroundColor: _isSendActive
                              ? AppColors.customBlue1
                              : Colors.grey.shade200,
                          onPressed: _isSendActive ? _sendInquiry : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_isLoading) const LoadingDialog(),
      ],
    );
  }
}
