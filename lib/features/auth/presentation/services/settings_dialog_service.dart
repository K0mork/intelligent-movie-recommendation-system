import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_controller.dart';
import '../../domain/entities/app_user.dart';

/// 設定画面のダイアログ表示を管理するサービスクラス
///
/// settings_page.dartからダイアログロジックを分離し、
/// 再利用可能で保守しやすい形にする。
class SettingsDialogService {
  /// プロフィール編集ダイアログを表示
  static Future<void> showEditProfileDialog(
    BuildContext context,
    WidgetRef ref,
    AppUser user,
  ) async {
    final displayNameController = TextEditingController(
      text: user.displayName ?? '',
    );

    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) =>
              EditProfileDialog(displayNameController: displayNameController),
    );

    displayNameController.dispose();

    if (result == true && context.mounted) {
      // 将来実装: プロフィール更新処理
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('プロフィール更新機能は将来実装予定です')));
    }
  }

  /// ログアウト確認ダイアログを表示
  static Future<void> showSignOutDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (BuildContext context) => AlertDialog(
            title: const Text('ログアウト'),
            content: const Text('本当にログアウトしますか？'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('キャンセル'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('ログアウト'),
              ),
            ],
          ),
    );

    if (confirmed == true && context.mounted) {
      await ref.read(authControllerProvider.notifier).signOut();
      if (context.mounted) {
        Navigator.of(context).pushReplacementNamed('/');
      }
    }
  }

  /// アカウント削除確認ダイアログを表示
  static Future<void> showDeleteAccountDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => const DeleteAccountDialog(),
    );

    if (confirmed == true && context.mounted) {
      // 将来実装: アカウント削除処理
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('アカウント削除機能は将来実装予定です')));
    }
  }

  /// データエクスポート確認ダイアログを表示
  static Future<void> showDataExportDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (BuildContext context) => AlertDialog(
            title: const Text('データエクスポート'),
            content: const Text('あなたのレビューデータをダウンロードしますか？'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('キャンセル'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('ダウンロード'),
              ),
            ],
          ),
    );

    if (confirmed == true && context.mounted) {
      // 将来実装: データエクスポート処理
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('データエクスポート機能は将来実装予定です')));
    }
  }

  /// ヘルプダイアログを表示
  static Future<void> showHelpDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => const HelpDialog(),
    );
  }

  /// 利用規約ダイアログを表示
  static Future<void> showTermsDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => const TermsDialog(),
    );
  }

  /// プライバシーポリシーダイアログを表示
  static Future<void> showPrivacyPolicyDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => const PrivacyPolicyDialog(),
    );
  }
}

/// プロフィール編集ダイアログ
class EditProfileDialog extends StatelessWidget {
  final TextEditingController displayNameController;

  const EditProfileDialog({super.key, required this.displayNameController});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('プロフィール編集'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: displayNameController,
            decoration: const InputDecoration(
              labelText: '表示名',
              border: OutlineInputBorder(),
              helperText: '他のユーザーに表示される名前です',
            ),
            maxLength: 50,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('キャンセル'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('保存'),
        ),
      ],
    );
  }
}

/// アカウント削除確認ダイアログ
class DeleteAccountDialog extends StatelessWidget {
  const DeleteAccountDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.warning, color: Colors.red[700]),
          const SizedBox(width: 8),
          const Text('アカウント削除'),
        ],
      ),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'この操作は取り消すことができません。',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text('削除される内容:'),
          SizedBox(height: 4),
          Text('• アカウント情報'),
          Text('• すべてのレビュー'),
          Text('• 推薦履歴'),
          Text('• 設定情報'),
          SizedBox(height: 16),
          Text(
            '本当にアカウントを削除しますか？',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('キャンセル'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.red,
          ),
          child: const Text('削除'),
        ),
      ],
    );
  }
}

/// ヘルプダイアログ
class HelpDialog extends StatelessWidget {
  const HelpDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('ヘルプ'),
      content: const SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'FilmFlowの使い方',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(height: 16),
            HelpSection(
              title: '映画検索',
              content: '映画タイトルや出演者名で検索できます。年代での絞り込みも可能です。',
            ),
            HelpSection(title: 'レビュー投稿', content: '観た映画に星評価とコメントを付けて記録できます。'),
            HelpSection(
              title: 'AI推薦',
              content: 'あなたのレビュー履歴を分析して、おすすめの映画を提案します。',
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('閉じる'),
        ),
      ],
    );
  }
}

/// 利用規約ダイアログ
class TermsDialog extends StatelessWidget {
  const TermsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('利用規約'),
      content: const SingleChildScrollView(
        child: Text(
          'FilmFlow 利用規約\n\n'
          '第1条（利用規約の適用）\n'
          'この利用規約は、FilmFlowサービスの利用条件を定めるものです。\n\n'
          '第2条（利用登録）\n'
          'サービスの利用には、Googleアカウントでのサインインが必要です。\n\n'
          '第3条（禁止事項）\n'
          '・他の利用者への迷惑行為\n'
          '・著作権を侵害する行為\n'
          '・虚偽の情報の投稿\n\n'
          '第4条（免責事項）\n'
          'サービスの利用に関して生じた損害について、当方は責任を負いません。\n\n'
          '※これは簡略版です。詳細な利用規約は将来実装予定です。',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('閉じる'),
        ),
      ],
    );
  }
}

/// プライバシーポリシーダイアログ
class PrivacyPolicyDialog extends StatelessWidget {
  const PrivacyPolicyDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('プライバシーポリシー'),
      content: const SingleChildScrollView(
        child: Text(
          'FilmFlow プライバシーポリシー\n\n'
          '1. 収集する情報\n'
          '・Googleアカウント情報（名前、メールアドレス）\n'
          '・映画レビュー情報\n'
          '・アプリ利用状況\n\n'
          '2. 情報の利用目的\n'
          '・サービスの提供\n'
          '・映画推薦機能の改善\n'
          '・統計分析\n\n'
          '3. 情報の共有\n'
          '個人情報を第三者と共有することはありません。\n\n'
          '4. データの保護\n'
          '適切なセキュリティ対策を実施しています。\n\n'
          '5. お問い合わせ\n'
          'プライバシーに関するご質問は、設定画面からお問い合わせください。\n\n'
          '※これは簡略版です。詳細なプライバシーポリシーは将来実装予定です。',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('閉じる'),
        ),
      ],
    );
  }
}

/// ヘルプセクション
class HelpSection extends StatelessWidget {
  final String title;
  final String content;

  const HelpSection({super.key, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(content, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}
