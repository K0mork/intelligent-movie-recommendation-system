import 'package:flutter/material.dart';

class RecommendationErrorWidget extends StatelessWidget {
  final String error;
  final VoidCallback? onRetry;

  const RecommendationErrorWidget({
    super.key,
    required this.error,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    // インデックス関連のエラーを判定
    final isIndexError =
        error.contains('index') &&
        (error.contains('building') || error.contains('create'));

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // エラーアイコン
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color:
                    isIndexError
                        ? Colors.orange.withValues(alpha: 0.1)
                        : Colors.red.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isIndexError ? Icons.hourglass_empty : Icons.error_outline,
                size: 40,
                color: isIndexError ? Colors.orange : Colors.red,
              ),
            ),
            const SizedBox(height: 24),

            // エラータイトル
            Text(
              isIndexError ? 'データベース準備中...' : 'エラーが発生しました',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: isIndexError ? Colors.orange : Colors.red,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // エラーメッセージ
            Text(
              isIndexError
                  ? 'データベースインデックスを構築中です。数分お待ちください。\nまたは「新しい推薦を生成」ボタンをお試しください。'
                  : error,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),

            // リトライボタン
            if (onRetry != null) ...[
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('再試行'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
