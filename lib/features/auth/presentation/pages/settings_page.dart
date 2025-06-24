import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/loading_state_widget.dart';
import '../providers/auth_providers.dart';
import '../providers/auth_controller.dart';
import '../widgets/settings_sections.dart';
import '../services/settings_dialog_service.dart';

/// 設定画面（リファクタリング版）
///
/// 責任を分離し、セクション別ウィジェットとサービスクラスを使用して
/// 保守性と再利用性を向上。
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final authController = ref.watch(authControllerProvider);

    return authState.when(
      data: (user) => user != null
          ? _buildSettingsContent(context, ref, user, authController)
          : _buildLoginRequired(context),
      loading: () => _buildLoadingState(),
      error: (error, stackTrace) => _buildErrorState(error),
    );
  }

  Widget _buildSettingsContent(
    BuildContext context,
    WidgetRef ref,
    user,
    authController,
  ) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return SettingsPageLayout(
      title: '設定',
      sections: [
        // プロフィール情報セクション
        ProfileSection(
          user: user,
          onEditProfile: () => SettingsDialogService.showEditProfileDialog(
            context,
            ref,
            user,
          ),
        ),

        // 表示設定セクション
        DisplaySettingsSection(
          isDarkMode: isDarkMode,
          // onDarkModeChanged: null, // 将来実装
        ),

        // 通知設定セクション
        const NotificationSettingsSection(
          newMovieNotifications: true,
          recommendationNotifications: false,
          // onNewMovieNotificationChanged: null, // 将来実装
          // onRecommendationNotificationChanged: null, // 将来実装
        ),

        // データ管理セクション
        DataManagementSection(
          onExportData: () => SettingsDialogService.showDataExportDialog(
            context,
            ref,
          ),
          onDeleteAccount: () => SettingsDialogService.showDeleteAccountDialog(
            context,
            ref,
          ),
        ),

        // アプリ情報セクション
        AppInfoSection(
          onHelp: () => SettingsDialogService.showHelpDialog(context),
          onTermsOfService: () => SettingsDialogService.showTermsDialog(context),
          onPrivacyPolicy: () => SettingsDialogService.showPrivacyPolicyDialog(context),
          appVersion: '1.0.0',
        ),

        // ログアウトセクション
        LogoutSection(
          isLoading: authController.isLoading,
          onLogout: () => SettingsDialogService.showSignOutDialog(context, ref),
        ),
      ],
    );
  }

  Widget _buildLoginRequired(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('設定'),
      ),
      body: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.login, size: 64),
            SizedBox(height: 16),
            Text('ログインが必要です'),
            Text('設定を表示するにはログインが必要です'),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('設定'),
      ),
      body: const LoadingStateWidget.fullScreen(
        message: '設定を読み込み中...',
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('設定'),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 64),
            const SizedBox(height: 16),
            const Text('エラーが発生しました'),
            Text(error.toString()),
          ],
        ),
      ),
    );
  }
}
