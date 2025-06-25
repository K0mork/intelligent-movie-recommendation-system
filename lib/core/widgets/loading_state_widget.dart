import 'package:flutter/material.dart';

/// ローディング状態表示の統一ウィジェット
///
/// プロジェクト内で重複していたローディング表示を統一し、
/// 一貫したUI/UXと保守性を向上させる。
class LoadingStateWidget extends StatelessWidget {
  final String? message;
  final LoadingType type;
  final double? size;
  final Color? color;
  final EdgeInsets padding;

  const LoadingStateWidget({
    super.key,
    this.message,
    this.type = LoadingType.circular,
    this.size,
    this.color,
    this.padding = const EdgeInsets.all(24.0),
  });

  /// 画面全体のローディング
  const LoadingStateWidget.fullScreen({
    super.key,
    this.message = '読み込み中...',
    this.type = LoadingType.circular,
    this.size,
    this.color,
  }) : padding = const EdgeInsets.all(24.0);

  /// リスト内のローディング
  const LoadingStateWidget.listItem({
    super.key,
    this.message,
    this.type = LoadingType.linear,
    this.size,
    this.color,
  }) : padding = const EdgeInsets.all(16.0);

  /// 小さなインライン ローディング
  const LoadingStateWidget.inline({
    super.key,
    this.message,
    this.type = LoadingType.circular,
    this.size = 16.0,
    this.color,
  }) : padding = const EdgeInsets.all(8.0);

  /// ボタン内のローディング
  const LoadingStateWidget.button({
    super.key,
    this.message,
    this.type = LoadingType.circular,
    this.size = 16.0,
    this.color,
  }) : padding = EdgeInsets.zero;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor = color ?? theme.colorScheme.primary;

    return Padding(
      padding: padding,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLoadingIndicator(effectiveColor),
            if (message != null) ...[
              const SizedBox(height: 16),
              Text(
                message!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator(Color color) {
    switch (type) {
      case LoadingType.circular:
        return SizedBox(
          width: size ?? 32.0,
          height: size ?? 32.0,
          child: CircularProgressIndicator.adaptive(
            valueColor: AlwaysStoppedAnimation<Color>(color),
            strokeWidth: 2.0,
          ),
        );

      case LoadingType.linear:
        return SizedBox(
          width: size ?? 200.0,
          child: LinearProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        );

      case LoadingType.pulse:
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.5, end: 1.0),
          duration: const Duration(milliseconds: 800),
          builder:
              (context, value, child) => Transform.scale(
                scale: value,
                child: Opacity(
                  opacity: value,
                  child: Container(
                    width: size ?? 32.0,
                    height: size ?? 32.0,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
        );

      case LoadingType.fade:
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.3, end: 1.0),
          duration: const Duration(milliseconds: 1000),
          builder:
              (context, value, child) => Opacity(
                opacity: value,
                child: Container(
                  width: size ?? 32.0,
                  height: size ?? 32.0,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
        );

      case LoadingType.spin:
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(seconds: 1),
          builder:
              (context, value, child) => Transform.rotate(
                angle: value * 2.0 * 3.14159,
                child: Icon(Icons.refresh, size: size ?? 32.0, color: color),
              ),
        );

      case LoadingType.skeleton:
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.3, end: 0.7),
          duration: const Duration(milliseconds: 1000),
          builder:
              (context, value, child) => Container(
                width: size ?? 200.0,
                height: 20.0,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: value),
                  borderRadius: BorderRadius.circular(4.0),
                ),
              ),
        );
    }
  }
}

/// ローディングの種類
enum LoadingType { circular, linear, pulse, fade, spin, skeleton }

/// 複数の要素を持つローディング状態
class LoadingStateList extends StatelessWidget {
  final int itemCount;
  final LoadingType type;
  final double spacing;
  final EdgeInsets padding;

  const LoadingStateList({
    super.key,
    required this.itemCount,
    this.type = LoadingType.skeleton,
    this.spacing = 8.0,
    this.padding = const EdgeInsets.all(16.0),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Column(
        children: List.generate(
          itemCount,
          (index) => Padding(
            padding: EdgeInsets.only(bottom: spacing),
            child: LoadingStateWidget(type: type, padding: EdgeInsets.zero),
          ),
        ),
      ),
    );
  }
}

/// 条件付きローディング表示
class ConditionalLoadingWidget extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final Widget? loadingWidget;
  final String? loadingMessage;
  final LoadingType loadingType;

  const ConditionalLoadingWidget({
    super.key,
    required this.isLoading,
    required this.child,
    this.loadingWidget,
    this.loadingMessage,
    this.loadingType = LoadingType.circular,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return loadingWidget ??
          LoadingStateWidget(message: loadingMessage, type: loadingType);
    }
    return child;
  }
}

/// ローディングオーバーレイ
class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? message;
  final Color? backgroundColor;
  final LoadingType type;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
    this.backgroundColor,
    this.type = LoadingType.circular,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Positioned.fill(
            child: Container(
              color: backgroundColor ?? Colors.black.withValues(alpha: 0.5),
              child: LoadingStateWidget(message: message, type: type),
            ),
          ),
      ],
    );
  }
}

/// ローディング状態管理のためのミックスイン
mixin LoadingStateMixin<T extends StatefulWidget> on State<T> {
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  void setLoading(bool loading) {
    if (mounted) {
      setState(() {
        _isLoading = loading;
      });
    }
  }

  Future<void> executeWithLoading(Future<void> Function() action) async {
    setLoading(true);
    try {
      await action();
    } finally {
      setLoading(false);
    }
  }

  Widget buildWithLoadingState({
    required Widget child,
    String? loadingMessage,
    LoadingType loadingType = LoadingType.circular,
  }) {
    return ConditionalLoadingWidget(
      isLoading: _isLoading,
      loadingMessage: loadingMessage,
      loadingType: loadingType,
      child: child,
    );
  }
}
