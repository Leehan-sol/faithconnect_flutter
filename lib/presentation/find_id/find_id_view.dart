import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/providers.dart';
import '../components/labeled_text_field.dart';
import '../components/action_button.dart';
import '../components/loading_dialog.dart';

/// iOS FindIDView.swift + FindIDResultView.swift 대응
class FindIdView extends ConsumerStatefulWidget {
  const FindIdView({super.key});

  @override
  ConsumerState<FindIdView> createState() => _FindIdViewState();
}

class _FindIdViewState extends ConsumerState<FindIdView> {
  final _nameController = TextEditingController();
  final _nicknameController = TextEditingController();
  bool _isLoading = false;
  String? _foundEmail;

  @override
  void dispose() {
    _nameController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  Future<void> _findId() async {
    final name = _nameController.text.trim();
    final nickname = _nicknameController.text.trim();

    if (name.isEmpty || nickname.isEmpty) {
      _showAlert('입력 오류', '이름과 닉네임을 모두 입력해주세요.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final authUseCase = ref.read(authUseCaseProvider);
      final email = await authUseCase.findId(name: name, nickname: nickname);
      setState(() {
        _isLoading = false;
        _foundEmail = email;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showAlert('찾기 실패', e.toString());
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

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: const Text('이메일 찾기'),
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
          ),
          body: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: _foundEmail != null ? _buildResult() : _buildForm(),
          ),
        ),
        if (_isLoading) const LoadingDialog(),
      ],
    );
  }

  Widget _buildForm() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '가입 시 입력한 이름과 닉네임으로\n이메일을 찾을 수 있습니다',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 20),
          LabeledTextField(
            title: '이름',
            placeholder: '이름을 입력하세요',
            controller: _nameController,
          ),
          const SizedBox(height: 10),
          LabeledTextField(
            title: '닉네임',
            placeholder: '닉네임을 입력하세요',
            controller: _nicknameController,
          ),
          const SizedBox(height: 20),
          ActionButton(
            title: '이메일 찾기',
            foregroundColor: Colors.white,
            backgroundColor: AppColors.customBlue1,
            onPressed: _findId,
          ),
        ],
      ),
    );
  }

  Widget _buildResult() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(40),
            ),
            child: const Icon(Icons.check, size: 40, color: Colors.green),
          ),
          const SizedBox(height: 30),
          const Text('이메일을 찾았습니다',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('입력하신 정보와 일치하는 이메일입니다',
              style: TextStyle(color: Colors.grey.shade600)),
          const SizedBox(height: 40),
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
                Text('등록된 이메일',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                const SizedBox(height: 10),
                Text(_foundEmail!,
                    style: const TextStyle(fontSize: 16)),
              ],
            ),
          ),
          const SizedBox(height: 40),
          ActionButton(
            title: '로그인하기',
            foregroundColor: Colors.white,
            backgroundColor: AppColors.customBlue1,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}
