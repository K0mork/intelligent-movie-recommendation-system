import 'package:flutter/material.dart';
import '../../domain/entities/recommendation.dart';
import 'recommendation_reason_dialog.dart';
import 'feedback_dialog.dart';

class RecommendationCard extends StatefulWidget {
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
  State<RecommendationCard> createState() => _RecommendationCardState();
}

class _RecommendationCardState extends State<RecommendationCard> {
  bool _isProcessing = false;
  String? _errorMessage;

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

          // エラーメッセージ表示
          if (_errorMessage != null) _buildErrorMessage(context),

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
                    widget.recommendation.movieTitle,
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
        image:
            widget.recommendation.posterPath != null
                ? DecorationImage(
                  image: NetworkImage(_getFullPosterUrl()),
                  fit: BoxFit.cover,
                  onError: (error, stackTrace) {
                    // エラー時は何もしない（デフォルトの背景色を表示）
                  },
                )
                : null,
      ),
      child:
          widget.recommendation.posterPath == null
              ? const Icon(Icons.movie, size: 40, color: Colors.grey)
              : null,
    );
  }

  Widget _buildConfidenceScore(BuildContext context) {
    final score = widget.recommendation.confidenceScore;
    final color =
        score >= 0.8
            ? Colors.green
            : score >= 0.6
            ? Colors.orange
            : Colors.red;

    return Row(
      children: [
        Icon(Icons.trending_up, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          '信頼度: ${(score * 100).toInt()}%',
          style: TextStyle(color: color, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildReasonCategories(BuildContext context) {
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children:
          widget.recommendation.reasonCategories.take(3).map((category) {
            return Chip(
              label: Text(category, style: const TextStyle(fontSize: 12)),
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
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            widget.recommendation.reason,
            style: Theme.of(context).textTheme.bodyMedium,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        border: Border.all(color: Colors.red.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _errorMessage!,
              style: TextStyle(color: Colors.red.shade700, fontSize: 14),
            ),
          ),
          IconButton(
            onPressed: () => setState(() => _errorMessage = null),
            icon: Icon(Icons.close, color: Colors.red.shade700, size: 20),
            constraints: const BoxConstraints(),
            padding: EdgeInsets.zero,
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
          if (!widget.isSaved && widget.onSave != null)
            ElevatedButton.icon(
              onPressed: _isProcessing ? null : _handleSave,
              icon: _isProcessing
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.bookmark_add),
              label: Text(_isProcessing ? '保存中...' : '保存'),
            ),
          if (widget.isSaved && widget.onDelete != null)
            ElevatedButton.icon(
              onPressed: _isProcessing ? null : _handleDelete,
              icon: _isProcessing
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.bookmark_remove),
              label: Text(_isProcessing ? '削除中...' : '削除'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),

          // フィードバックボタン
          if (widget.onFeedback != null)
            OutlinedButton.icon(
              onPressed: _isProcessing ? null : () => _showFeedbackDialog(context),
              icon: const Icon(Icons.feedback_outlined),
              label: const Text('評価'),
            ),
        ],
      ),
    );
  }

  Future<void> _handleSave() async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    try {
      widget.onSave?.call();

      // 成功時のフィードバック
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('推薦結果を保存しました'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = '保存に失敗しました: ${e.toString()}';
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _handleDelete() async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    try {
      widget.onDelete?.call();

      // 成功時のフィードバック
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('保存済み推薦結果を削除しました'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = '削除に失敗しました: ${e.toString()}';
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  void _showReasonDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) =>
              RecommendationReasonDialog(recommendation: widget.recommendation),
    );
  }

  void _showFeedbackDialog(BuildContext context) {
    if (widget.onFeedback == null) return;

    showDialog(
      context: context,
      builder:
          (context) => FeedbackDialog(
            movieTitle: widget.recommendation.movieTitle,
            onSubmit: widget.onFeedback!,
          ),
    );
  }

  String _getFullPosterUrl() {
    if (widget.recommendation.posterPath == null) return '';

    if (widget.recommendation.posterPath!.startsWith('http')) {
      return widget.recommendation.posterPath!;
    }

    return 'https://image.tmdb.org/t/p/w500${widget.recommendation.posterPath}';
  }
}
