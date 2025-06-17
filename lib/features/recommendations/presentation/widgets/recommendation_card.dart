import 'package:flutter/material.dart';
import '../../domain/entities/recommendation.dart';
import 'recommendation_reason_dialog.dart';
import 'feedback_dialog.dart';

class RecommendationCard extends StatelessWidget {
  final Recommendation recommendation;
  final bool isSaved;
  final VoidCallback? onSave;
  final VoidCallback? onDelete;
  final Function(bool isHelpful, String? feedback)? onFeedback;

  const RecommendationCard({
    super.key,
    required this.recommendation,
    this.isSaved = false,
    this.onSave,
    this.onDelete,
    this.onFeedback,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 映画ポスター & 基本情報
          _buildMovieHeader(context),
          
          // 推薦理由
          _buildReasonSection(context),
          
          // アクションボタン
          _buildActionSection(context),
        ],
      ),
    );
  }

  Widget _buildMovieHeader(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Row(
        children: [
          // ポスター画像
          _buildPosterImage(),
          
          // 映画情報
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 映画タイトル
                  Text(
                    recommendation.movieTitle,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  
                  // 信頼度スコア
                  _buildConfidenceScore(context),
                  const SizedBox(height: 8),
                  
                  // 推薦カテゴリ
                  _buildReasonCategories(context),
                  
                  const Spacer(),
                  
                  // 詳細表示ボタン
                  TextButton.icon(
                    onPressed: () => _showReasonDialog(context),
                    icon: const Icon(Icons.info_outline),
                    label: const Text('推薦理由を見る'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPosterImage() {
    return Container(
      width: 120,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        image: recommendation.posterPath != null
            ? DecorationImage(
                image: NetworkImage(_getFullPosterUrl()),
                fit: BoxFit.cover,
                onError: (error, stackTrace) {
                  // エラー時は何もしない（デフォルトの背景色を表示）
                },
              )
            : null,
      ),
      child: recommendation.posterPath == null
          ? const Icon(
              Icons.movie,
              size: 40,
              color: Colors.grey,
            )
          : null,
    );
  }

  Widget _buildConfidenceScore(BuildContext context) {
    final score = recommendation.confidenceScore;
    final color = score >= 0.8
        ? Colors.green
        : score >= 0.6
            ? Colors.orange
            : Colors.red;

    return Row(
      children: [
        Icon(
          Icons.trending_up,
          size: 16,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(
          '信頼度: ${(score * 100).toInt()}%',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildReasonCategories(BuildContext context) {
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: recommendation.reasonCategories.take(3).map((category) {
        return Chip(
          label: Text(
            category,
            style: const TextStyle(fontSize: 12),
          ),
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          padding: const EdgeInsets.symmetric(horizontal: 4),
        );
      }).toList(),
    );
  }

  Widget _buildReasonSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '推薦理由',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            recommendation.reason,
            style: Theme.of(context).textTheme.bodyMedium,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildActionSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // 保存/削除ボタン
          if (!isSaved && onSave != null)
            ElevatedButton.icon(
              onPressed: onSave,
              icon: const Icon(Icons.bookmark_add),
              label: const Text('保存'),
            ),
          if (isSaved && onDelete != null)
            ElevatedButton.icon(
              onPressed: onDelete,
              icon: const Icon(Icons.bookmark_remove),
              label: const Text('削除'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
          
          // フィードバックボタン
          if (onFeedback != null)
            OutlinedButton.icon(
              onPressed: () => _showFeedbackDialog(context),
              icon: const Icon(Icons.feedback_outlined),
              label: const Text('評価'),
            ),
        ],
      ),
    );
  }

  void _showReasonDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => RecommendationReasonDialog(
        recommendation: recommendation,
      ),
    );
  }

  void _showFeedbackDialog(BuildContext context) {
    if (onFeedback == null) return;
    
    showDialog(
      context: context,
      builder: (context) => FeedbackDialog(
        movieTitle: recommendation.movieTitle,
        onSubmit: onFeedback!,
      ),
    );
  }

  String _getFullPosterUrl() {
    if (recommendation.posterPath == null) return '';
    
    if (recommendation.posterPath!.startsWith('http')) {
      return recommendation.posterPath!;
    }
    
    return 'https://image.tmdb.org/t/p/w500${recommendation.posterPath}';
  }
}