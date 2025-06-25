import 'package:flutter/material.dart';

class FeedbackDialog extends StatefulWidget {
  final String movieTitle;
  final Function(bool isHelpful, String? feedback) onSubmit;

  const FeedbackDialog({
    super.key,
    required this.movieTitle,
    required this.onSubmit,
  });

  @override
  State<FeedbackDialog> createState() => _FeedbackDialogState();
}

class _FeedbackDialogState extends State<FeedbackDialog> {
  bool? _isHelpful;
  final _feedbackController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ヘッダー
            _buildHeader(context),

            // コンテンツ
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 評価質問
                      _buildHelpfulnessSection(context),
                      const SizedBox(height: 24),

                      // コメント欄
                      _buildCommentSection(context),
                    ],
                  ),
                ),
              ),
            ),

            // フッター
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.feedback_outlined,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '推薦の評価',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.movieTitle,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(
              Icons.close,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpfulnessSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'この推薦は役に立ちましたか？',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildHelpfulnessOption(
                context,
                isHelpful: true,
                title: '役に立った',
                subtitle: '好みに合っている',
                icon: Icons.thumb_up_outlined,
                selectedIcon: Icons.thumb_up,
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildHelpfulnessOption(
                context,
                isHelpful: false,
                title: '役に立たなかった',
                subtitle: '好みに合わない',
                icon: Icons.thumb_down_outlined,
                selectedIcon: Icons.thumb_down,
                color: Colors.red,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHelpfulnessOption(
    BuildContext context, {
    required bool isHelpful,
    required String title,
    required String subtitle,
    required IconData icon,
    required IconData selectedIcon,
    required Color color,
  }) {
    final isSelected = _isHelpful == isHelpful;

    return GestureDetector(
      onTap: () {
        setState(() {
          _isHelpful = isHelpful;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? color.withValues(alpha: 0.1)
                  : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                isSelected
                    ? color
                    : Theme.of(
                      context,
                    ).colorScheme.outline.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              isSelected ? selectedIcon : icon,
              color: isSelected ? color : Colors.grey[600],
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: isSelected ? color : null,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'コメント（任意）',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _feedbackController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'この推薦についてのご意見をお聞かせください...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('キャンセル'),
          ),
          const SizedBox(width: 16),
          ElevatedButton(
            onPressed: _isHelpful != null ? _submitFeedback : null,
            child: const Text('送信'),
          ),
        ],
      ),
    );
  }

  void _submitFeedback() {
    if (_isHelpful == null) return;

    final feedback = _feedbackController.text.trim();
    widget.onSubmit(_isHelpful!, feedback.isEmpty ? null : feedback);

    Navigator.of(context).pop();
  }
}
