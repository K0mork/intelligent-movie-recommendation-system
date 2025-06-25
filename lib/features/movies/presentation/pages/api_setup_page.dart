import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ApiSetupPage extends StatelessWidget {
  const ApiSetupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('API設定が必要です')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.settings, size: 64, color: Colors.orange),
            const SizedBox(height: 16),
            Text(
              'TMDb APIキーが必要です',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            const Text(
              '映画データを取得するために、TMDb（The Movie Database）のAPIキーが必要です。'
              '以下の手順に従ってAPIキーを取得し、設定してください。',
            ),
            const SizedBox(height: 24),
            const Text(
              '手順：',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 12),
            _buildStep(
              '1.',
              'TMDbアカウントを作成',
              'https://www.themoviedb.org/account/signup にアクセスしてアカウントを作成してください。',
              () => _launchUrl('https://www.themoviedb.org/account/signup'),
            ),
            const SizedBox(height: 12),
            _buildStep(
              '2.',
              'API設定ページにアクセス',
              'https://www.themoviedb.org/settings/api にアクセスしてAPIキーを作成してください。',
              () => _launchUrl('https://www.themoviedb.org/settings/api'),
            ),
            const SizedBox(height: 12),
            _buildStep(
              '3.',
              '.envファイルを編集',
              'プロジェクトルートの.envファイルを開き、TMDB_API_KEY=your_api_key_here の部分に取得したAPIキーを入力してください。',
              null,
            ),
            const SizedBox(height: 12),
            _buildStep('4.', 'アプリを再起動', 'アプリを再起動して変更を反映してください。', null),
            const Spacer(),
            const Card(
              color: Colors.blue,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.info, color: Colors.white),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'TMDb APIは無料で利用できます。1日あたり1,000リクエストまで無料です。',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(
    String number,
    String title,
    String description,
    VoidCallback? onTap,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 12,
              child: Text(
                number,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(description),
                  if (onTap != null) ...[
                    const SizedBox(height: 8),
                    ElevatedButton(onPressed: onTap, child: const Text('開く')),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}
