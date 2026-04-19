import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/entities/prayer.dart';
import '../../domain/entities/prayer_category.dart';
import '../components/category_button.dart';
import '../components/labeled_text_field.dart';

/// iOS PrayerEditorView + PrayerEditorViewModel 대응
class PrayerEditorView extends ConsumerStatefulWidget {
  final Prayer? prayer; // null이면 새 작성, 있으면 수정

  const PrayerEditorView({super.key, this.prayer});

  @override
  ConsumerState<PrayerEditorView> createState() => _PrayerEditorViewState();
}

class _PrayerEditorViewState extends ConsumerState<PrayerEditorView> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  List<PrayerCategory> _categories = [];
  int _selectedCategoryId = 0;
  bool get _isEditMode => widget.prayer != null;

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      _titleController.text = widget.prayer!.title;
      _contentController.text = widget.prayer!.content;
      _selectedCategoryId = widget.prayer!.categoryId;
    }
    _fetchCategories();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _fetchCategories() async {
    try {
      final categories =
          await ref.read(prayerUseCaseProvider).loadCategories();
      setState(() {
        // categoryCode 1 (전체) 제외 — iOS와 동일
        _categories = categories.where((c) => c.categoryCode != 1).toList();
      });
    } catch (e) {
      _showAlert('오류', e.toString());
    }
  }

  Future<void> _savePrayer() async {
    if (_selectedCategoryId == 0) {
      _showAlert('입력 오류', '카테고리를 선택해 주세요.');
      return;
    }
    if (_titleController.text.isEmpty) {
      _showAlert('입력 오류', '제목을(를) 입력해주세요.');
      return;
    }
    if (_contentController.text.isEmpty) {
      _showAlert('입력 오류', '내용을(를) 입력해주세요.');
      return;
    }

    try {
      final useCase = ref.read(prayerUseCaseProvider);
      if (_isEditMode) {
        await useCase.updatePrayer(
          prayerRequestId: widget.prayer!.id,
          categoryId: _selectedCategoryId,
          title: _titleController.text,
          content: _contentController.text,
        );
      } else {
        await useCase.writePrayer(
          categoryId: _selectedCategoryId,
          title: _titleController.text,
          content: _contentController.text,
        );
      }
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      final failTitle = _isEditMode ? '기도 수정 실패' : '기도 작성 실패';
      _showAlert(failTitle, e.toString());
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
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? '기도 수정' : '새 기도'),
        centerTitle: true,
        leading: TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('취소',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        ),
        actions: [
          TextButton(
            onPressed: _savePrayer,
            child: const Text('완료',
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // 카테고리
              const Text('카테고리',
                  style:
                      TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _categories
                      .map((c) => Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: CategoryButton(
                              category: c,
                              isSelected: c.id == _selectedCategoryId,
                              onTap: () =>
                                  setState(() => _selectedCategoryId = c.id),
                            ),
                          ))
                      .toList(),
                ),
              ),
              const SizedBox(height: 30),

              // 제목
              LabeledTextField(
                title: '제목',
                placeholder: '기도 제목을 입력하세요',
                controller: _titleController,
              ),
              const SizedBox(height: 30),

              // 내용
              const Text('내용',
                  style:
                      TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Container(
                height: 250,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  controller: _contentController,
                  maxLines: null,
                  expands: true,
                  maxLength: 2000,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: InputDecoration(
                    hintText: '기도 내용을 입력하세요',
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(16),
                    counterText: '',
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 안내 박스
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.customBlue1.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('• 기도제목은 익명으로 공유됩니다.',
                        style: TextStyle(
                            fontSize: 13, color: AppColors.customNavy)),
                    const SizedBox(height: 4),
                    Text('• 이름과 연락처 등 개인정보는 작성하지 말아주세요.',
                        style: TextStyle(
                            fontSize: 13, color: AppColors.customNavy)),
                    const SizedBox(height: 4),
                    Text('• 모든 성도들이 함께 기도할 수 있도록 진솔하게 작성해 주세요.',
                        style: TextStyle(
                            fontSize: 13, color: AppColors.customNavy)),
                  ],
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
