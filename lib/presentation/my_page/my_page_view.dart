import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../core/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../data/storage/user_session.dart';
import '../block_list/block_list_view.dart';
import '../inquiry/inquiry_view.dart';
import '../policy/policy_web_view.dart';
import '../find_password/find_password_view.dart';

/// iOS MyPageView 대응
class MyPageView extends ConsumerStatefulWidget {
  const MyPageView({super.key});

  @override
  ConsumerState<MyPageView> createState() => _MyPageViewState();
}

class _MyPageViewState extends ConsumerState<MyPageView> {
  String _version = '';

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((info) {
      if (mounted) setState(() => _version = info.version);
    });
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(userSessionProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('마이페이지', style: TextStyle(fontWeight: FontWeight.bold))),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 프로필 카드
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(30),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(Icons.person, size: 30, color: Colors.grey.shade700),
                  const SizedBox(width: 30),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(session.nickname,
                          style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 5),
                      Text(session.email,
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade500)),
                    ],
                  ),
                ],
              ),
            ),

            // 계정 설정
            _sectionTitle('계정 설정'),
            _settingsCard(
              children: [
                _settingsItem(
                  icon: Icons.edit,
                  color: AppColors.customBlue1,
                  title: '닉네임 변경',
                  onTap: () => _showNicknameDialog(context, ref, session.nickname),
                ),
                Divider(height: 1, color: Colors.grey.shade100),
                _settingsItem(
                  icon: Icons.lock,
                  color: AppColors.customBlue1,
                  title: '비밀번호 변경',
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => FindPasswordView(
                        initialEmail: session.email,
                        onResetSuccess: () async {
                          try {
                            await ref.read(authUseCaseProvider).logout();
                          } catch (_) {}
                          ref.read(userSessionProvider.notifier).logout();
                        },
                      ),
                    ));
                  },
                ),
                Divider(height: 1, color: Colors.grey.shade100),
                _settingsItem(
                  icon: Icons.block,
                  color: AppColors.customBlue1,
                  title: '차단 관리',
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => const BlockListView(),
                    ));
                  },
                ),
                Divider(height: 1, color: Colors.grey.shade100),
                _settingsItem(
                  icon: Icons.logout,
                  color: AppColors.customBlue1,
                  title: '로그아웃',
                  onTap: () => _showLogoutDialog(context, ref),
                ),
              ],
            ),

            // 개발자 도구 (DEBUG 전용)
            if (kDebugMode) ...[
              _sectionTitle('개발자 도구'),
              _settingsCard(
                children: [
                  _settingsItem(
                    icon: Icons.notifications_active,
                    color: AppColors.customBlue1,
                    title: '푸시 알림 테스트',
                    onTap: () async {
                      try {
                        final token = await FirebaseMessaging.instance.getToken();
                        if (context.mounted) {
                          showCupertinoDialog(
                            context: context,
                            builder: (dialogContext) => CupertinoAlertDialog(
                              title: const Text('FCM 토큰'),
                              content: SelectableText(token ?? '토큰 없음'),
                              actions: [
                                CupertinoDialogAction(
                                  onPressed: () => Navigator.of(dialogContext).pop(),
                                  child: const Text('확인'),
                                ),
                              ],
                            ),
                          );
                        }
                      } catch (e) {
                        debugPrint('FCM 토큰 조회 실패: $e');
                      }
                    },
                  ),
                ],
              ),
            ],

            // 정보
            _sectionTitle('정보'),
            _settingsCard(
              children: [
                _settingsItem(
                  icon: Icons.description,
                  color: Colors.black,
                  title: '이용약관',
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) =>
                          const PolicyWebView(policyType: PolicyType.terms),
                    ));
                  },
                ),
                Divider(height: 1, color: Colors.grey.shade100),
                _settingsItem(
                  icon: Icons.shield,
                  color: Colors.black,
                  title: '개인정보 처리방침',
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) =>
                          const PolicyWebView(policyType: PolicyType.privacy),
                    ));
                  },
                ),
                Divider(height: 1, color: Colors.grey.shade100),
                _settingsItem(
                  icon: Icons.mail_outline,
                  color: Colors.black,
                  title: '문의하기',
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => const InquiryView(),
                    ));
                  },
                ),
              ],
            ),

            // 버전 + 회원탈퇴
            Padding(
              padding: const EdgeInsets.only(top: 50, bottom: 30),
              child: Column(
                children: [
                  Text('FaithConnect v$_version',
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey.shade500)),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () => _showDeleteAccountDialog(context, ref),
                    child: Text('회원탈퇴',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                          decoration: TextDecoration.underline,
                        )),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
        child: Text(title,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _settingsCard({required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.25),
            blurRadius: 6,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _settingsItem({
    required IconData icon,
    required Color color,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 35,
        height: 35,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 15),
      ),
      title: Text(title, style: const TextStyle(fontSize: 15)),
      trailing:
          Icon(Icons.chevron_right, size: 18, color: Colors.grey.shade600),
      onTap: onTap,
    );
  }

  void _showNicknameDialog(BuildContext context, WidgetRef ref, String current) {
    final controller = TextEditingController(text: current);
    showCupertinoDialog(
      context: context,
      builder: (dialogContext) => CupertinoAlertDialog(
        title: const Text('닉네임 변경'),
        content: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: CupertinoTextField(
            controller: controller,
            placeholder: '새 닉네임을 입력하세요',
          ),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('취소'),
          ),
          CupertinoDialogAction(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              final nickname = controller.text.trim();
              if (nickname.isEmpty) return;
              try {
                final authUseCase = ref.read(authUseCaseProvider);
                final updated = await authUseCase.changeNickname(nickname: nickname);
                ref.read(userSessionProvider.notifier).updateNickname(updated);
              } catch (e) {
                if (context.mounted) {
                  showCupertinoDialog(
                    context: context,
                    builder: (errContext) => CupertinoAlertDialog(
                      title: const Text('닉네임 변경 실패'),
                      content: Text(e.toString()),
                      actions: [
                        CupertinoDialogAction(
                          onPressed: () => Navigator.of(errContext).pop(),
                          child: const Text('확인'),
                        ),
                      ],
                    ),
                  );
                }
              }
            },
            child: const Text('변경'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showCupertinoDialog(
      context: context,
      builder: (dialogContext) => CupertinoAlertDialog(
        title: const Text('로그아웃'),
        content: const Text('로그아웃 하시겠습니까?'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('취소'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              try {
                final authUseCase = ref.read(authUseCaseProvider);
                // FCM 토큰 삭제
                try {
                  final fcmToken = await FirebaseMessaging.instance.getToken();
                  if (fcmToken != null) {
                    await authUseCase.deletePushToken(deviceToken: fcmToken);
                  }
                } catch (_) {}
                await authUseCase.logout();
                ref.read(userSessionProvider.notifier).logout();
              } catch (_) {}
            },
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context, WidgetRef ref) {
    showCupertinoDialog(
      context: context,
      builder: (dialogContext) => CupertinoAlertDialog(
        title: const Text('회원탈퇴'),
        content: const Text('정말 탈퇴하시겠습니까?\n모든 데이터가 삭제됩니다.'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('취소'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              try {
                await ref.read(authUseCaseProvider).deleteAccount();
                ref.read(userSessionProvider.notifier).logout();
              } catch (e) {
                if (context.mounted) {
                  showCupertinoDialog(
                    context: context,
                    builder: (errContext) => CupertinoAlertDialog(
                      title: const Text('회원탈퇴 실패'),
                      content: Text(e.toString()),
                      actions: [
                        CupertinoDialogAction(
                          onPressed: () => Navigator.of(errContext).pop(),
                          child: const Text('확인'),
                        ),
                      ],
                    ),
                  );
                }
              }
            },
            child: const Text('탈퇴'),
          ),
        ],
      ),
    );
  }
}
