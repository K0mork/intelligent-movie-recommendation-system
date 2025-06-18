import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_providers.dart';
import '../providers/auth_controller.dart';
import '../widgets/user_avatar.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final authState = ref.watch(authStateProvider);
    final authController = ref.watch(authControllerProvider);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('設定'),
        backgroundColor: theme.colorScheme.surface,
      ),
      body: authState.when(
        data: (user) {
          if (user == null) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.login,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    '設定を表示するにはログインが必要です',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // プロフィール情報セクション
                _buildSectionHeader('プロフィール', Icons.person_outline),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        UserAvatar(
                          user: user,
                          radius: 30,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.displayName ?? 'ゲストユーザー',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                user.email ?? '',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit_outlined),
                          onPressed: () {
                            _showEditProfileDialog(context, ref, user);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // 表示設定セクション
                _buildSectionHeader('表示設定', Icons.palette_outlined),
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(
                          isDarkMode ? Icons.dark_mode : Icons.light_mode,
                        ),
                        title: const Text('ダークモード'),
                        subtitle: Text(
                          isDarkMode ? '現在ダークモードです' : '現在ライトモードです',
                        ),
                        trailing: Switch(
                          value: isDarkMode,
                          onChanged: (value) {
                            // ダークモード切り替え（将来実装）
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('ダークモード切り替えは将来実装予定です'),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // 通知設定セクション
                _buildSectionHeader('通知設定', Icons.notifications_outlined),
                Card(
                  child: Column(
                    children: [
                      SwitchListTile(
                        secondary: const Icon(Icons.movie_outlined),
                        title: const Text('新作映画通知'),
                        subtitle: const Text('新しい映画が追加されたときに通知'),
                        value: true,
                        onChanged: (value) {
                          // 通知設定（将来実装）
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('通知設定は将来実装予定です'),
                            ),
                          );
                        },
                      ),
                      SwitchListTile(
                        secondary: const Icon(Icons.recommend_outlined),
                        title: const Text('おすすめ通知'),
                        subtitle: const Text('新しいおすすめ映画が利用可能になったときに通知'),
                        value: false,
                        onChanged: (value) {
                          // 通知設定（将来実装）
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('通知設定は将来実装予定です'),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // データ管理セクション
                _buildSectionHeader('データ管理', Icons.storage_outlined),
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.download_outlined),
                        title: const Text('データエクスポート'),
                        subtitle: const Text('あなたのレビューデータをダウンロード'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          // データエクスポート（将来実装）
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('データエクスポート機能は将来実装予定です'),
                            ),
                          );
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.delete_outline, color: Colors.red),
                        title: const Text('アカウント削除', style: TextStyle(color: Colors.red)),
                        subtitle: const Text('アカウントとすべてのデータを削除'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          _showDeleteAccountDialog(context, ref);
                        },
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // アプリ情報セクション
                _buildSectionHeader('アプリ情報', Icons.info_outline),
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.help_outline),
                        title: const Text('ヘルプ'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          // ヘルプ画面（将来実装）
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('ヘルプ機能は将来実装予定です'),
                            ),
                          );
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.description_outlined),
                        title: const Text('利用規約'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          // 利用規約（将来実装）
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('利用規約は将来実装予定です'),
                            ),
                          );
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.privacy_tip_outlined),
                        title: const Text('プライバシーポリシー'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          // プライバシーポリシー（将来実装）  
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('プライバシーポリシーは将来実装予定です'),
                            ),
                          );
                        },
                      ),
                      const ListTile(
                        leading: Icon(Icons.info),
                        title: Text('バージョン'),
                        subtitle: Text('1.0.0'),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // ログアウトボタン
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: authController.isLoading 
                        ? null 
                        : () => _showSignOutDialog(context, ref),
                    icon: authController.isLoading 
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.logout),
                    label: Text(authController.isLoading ? 'ログアウト中...' : 'ログアウト'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: theme.colorScheme.error,
                      backgroundColor: theme.colorScheme.errorContainer,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
              ],
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text('エラーが発生しました: $error'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context, WidgetRef ref, user) {
    final displayNameController = TextEditingController(
      text: user.displayName ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('プロフィール編集'),
        content: TextField(
          controller: displayNameController,
          decoration: const InputDecoration(
            labelText: '表示名',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () {
              // プロフィール更新（将来実装）
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('プロフィール更新機能は将来実装予定です'),
                ),
              );
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  void _showSignOutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ログアウト'),
        content: const Text('本当にログアウトしますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await ref.read(authControllerProvider.notifier).signOut();
              if (context.mounted) {
                Navigator.of(context).pushReplacementNamed('/');
              }
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.red,
            ),
            child: const Text('ログアウト'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('アカウント削除'),
        content: const Text(
          'この操作は取り消すことができません。\n'
          'アカウントとすべてのデータが完全に削除されます。\n'
          '本当に削除しますか？',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // アカウント削除（将来実装）
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('アカウント削除機能は将来実装予定です'),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.red,
            ),
            child: const Text('削除'),
          ),
        ],
      ),
    );
  }
}