import 'package:flutter/material.dart';
import '../../domain/entities/app_user.dart';
import 'user_avatar.dart';
import '../../../../core/utils/snack_bar_helper.dart';

/// 設定画面のセクション別ウィジェット群
///
/// settings_page.dartから責任を分離し、
/// セクションごとに独立したウィジェットとして管理。

/// セクションヘッダーウィジェット
class SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final EdgeInsets padding;

  const SectionHeader({
    super.key,
    required this.title,
    required this.icon,
    this.padding = const EdgeInsets.only(bottom: 8),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
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
}

/// プロフィール情報セクション
class ProfileSection extends StatelessWidget {
  final AppUser user;
  final VoidCallback onEditProfile;

  const ProfileSection({
    super.key,
    required this.user,
    required this.onEditProfile,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'プロフィール',
          icon: Icons.person_outline,
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                UserAvatar(
                  user: user,
                  size: 60,
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
                  onPressed: onEditProfile,
                  tooltip: 'プロフィール編集',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// 表示設定セクション
class DisplaySettingsSection extends StatelessWidget {
  final bool isDarkMode;
  final ValueChanged<bool>? onDarkModeChanged;

  const DisplaySettingsSection({
    super.key,
    required this.isDarkMode,
    this.onDarkModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: '表示設定',
          icon: Icons.palette_outlined,
        ),
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
                  onChanged: onDarkModeChanged ?? (_) => _showComingSoonMessage(context),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showComingSoonMessage(BuildContext context) {
    SnackBarHelper.showInfo(
      context,
      'ダークモード切り替えは将来実装予定です',
    );
  }
}

/// 通知設定セクション
class NotificationSettingsSection extends StatelessWidget {
  final bool newMovieNotifications;
  final bool recommendationNotifications;
  final ValueChanged<bool>? onNewMovieNotificationChanged;
  final ValueChanged<bool>? onRecommendationNotificationChanged;

  const NotificationSettingsSection({
    super.key,
    required this.newMovieNotifications,
    required this.recommendationNotifications,
    this.onNewMovieNotificationChanged,
    this.onRecommendationNotificationChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: '通知設定',
          icon: Icons.notifications_outlined,
        ),
        Card(
          child: Column(
            children: [
              SwitchListTile(
                secondary: const Icon(Icons.movie_outlined),
                title: const Text('新作映画通知'),
                subtitle: const Text('新しい映画が追加されたときに通知'),
                value: newMovieNotifications,
                onChanged: onNewMovieNotificationChanged ??
                    (_) => _showComingSoonMessage(context),
              ),
              SwitchListTile(
                secondary: const Icon(Icons.recommend_outlined),
                title: const Text('おすすめ通知'),
                subtitle: const Text('新しいおすすめ映画が利用可能になったときに通知'),
                value: recommendationNotifications,
                onChanged: onRecommendationNotificationChanged ??
                    (_) => _showComingSoonMessage(context),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showComingSoonMessage(BuildContext context) {
    SnackBarHelper.showInfo(
      context,
      '通知設定は将来実装予定です',
    );
  }
}

/// データ管理セクション
class DataManagementSection extends StatelessWidget {
  final VoidCallback onExportData;
  final VoidCallback onDeleteAccount;

  const DataManagementSection({
    super.key,
    required this.onExportData,
    required this.onDeleteAccount,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'データ管理',
          icon: Icons.storage_outlined,
        ),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.download_outlined),
                title: const Text('データエクスポート'),
                subtitle: const Text('あなたのレビューデータをダウンロード'),
                trailing: const Icon(Icons.chevron_right),
                onTap: onExportData,
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text('アカウント削除', style: TextStyle(color: Colors.red)),
                subtitle: const Text('アカウントとすべてのデータを削除'),
                trailing: const Icon(Icons.chevron_right),
                onTap: onDeleteAccount,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// アプリ情報セクション
class AppInfoSection extends StatelessWidget {
  final VoidCallback onHelp;
  final VoidCallback onTermsOfService;
  final VoidCallback onPrivacyPolicy;
  final String appVersion;

  const AppInfoSection({
    super.key,
    required this.onHelp,
    required this.onTermsOfService,
    required this.onPrivacyPolicy,
    this.appVersion = '1.0.0',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'アプリ情報',
          icon: Icons.info_outline,
        ),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.help_outline),
                title: const Text('ヘルプ'),
                trailing: const Icon(Icons.chevron_right),
                onTap: onHelp,
              ),
              ListTile(
                leading: const Icon(Icons.description_outlined),
                title: const Text('利用規約'),
                trailing: const Icon(Icons.chevron_right),
                onTap: onTermsOfService,
              ),
              ListTile(
                leading: const Icon(Icons.privacy_tip_outlined),
                title: const Text('プライバシーポリシー'),
                trailing: const Icon(Icons.chevron_right),
                onTap: onPrivacyPolicy,
              ),
              ListTile(
                leading: const Icon(Icons.info),
                title: const Text('バージョン'),
                subtitle: Text(appVersion),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// ログアウトセクション
class LogoutSection extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onLogout;

  const LogoutSection({
    super.key,
    required this.isLoading,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : onLogout,
        icon: isLoading
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.logout),
        label: Text(isLoading ? 'ログアウト中...' : 'ログアウト'),
        style: ElevatedButton.styleFrom(
          foregroundColor: theme.colorScheme.error,
          backgroundColor: theme.colorScheme.errorContainer,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}

/// 設定ページの共通レイアウト
class SettingsPageLayout extends StatelessWidget {
  final String title;
  final List<Widget> sections;
  final EdgeInsets padding;

  const SettingsPageLayout({
    super.key,
    required this.title,
    required this.sections,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: theme.colorScheme.surface,
      ),
      body: SingleChildScrollView(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _buildSectionsWithSpacing(),
        ),
      ),
    );
  }

  List<Widget> _buildSectionsWithSpacing() {
    final spacedSections = <Widget>[];

    for (int i = 0; i < sections.length; i++) {
      spacedSections.add(sections[i]);

      // 最後の要素以外にスペースを追加
      if (i < sections.length - 1) {
        spacedSections.add(const SizedBox(height: 24));
      }
    }

    return spacedSections;
  }
}

/// 設定項目の共通設定
class SettingsDefaults {
  static const double sectionSpacing = 24.0;
  static const double itemSpacing = 16.0;
  static const EdgeInsets padding = EdgeInsets.all(16.0);
  static const EdgeInsets cardPadding = EdgeInsets.all(16.0);

  static void showComingSoonSnackBar(BuildContext context, String feature) {
    SnackBarHelper.showInfo(
      context,
      '$feature機能は将来実装予定です',
    );
  }
}
