import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/result_state.dart';
import 'loading_state_widget.dart';
import 'error_widgets.dart';

/// ResultState に基づいてUIを構築するウィジェット
/// 
/// 統一されたエラーハンドリングとローディング状態の表示により、
/// 一貫したユーザーエクスペリエンスを提供する。
class ResultStateWidget<T> extends StatelessWidget {
  final ResultState<T> state;
  final Widget Function(T data) builder;
  final Widget Function()? initialBuilder;
  final Widget Function(String? message)? loadingBuilder;
  final Widget Function(String message, Object? error, StackTrace? stackTrace)? errorBuilder;
  final VoidCallback? onRetry;
  final bool showDebugInfo;

  const ResultStateWidget({
    super.key,
    required this.state,
    required this.builder,
    this.initialBuilder,
    this.loadingBuilder,
    this.errorBuilder,
    this.onRetry,
    this.showDebugInfo = false,
  });

  @override
  Widget build(BuildContext context) {
    return state.when(
      success: builder,
      initial: () => initialBuilder?.call() ?? _buildDefaultInitial(),
      loading: (message) => loadingBuilder?.call(message) ?? _buildDefaultLoading(message),
      onError: (message, error, stackTrace) =>
          errorBuilder?.call(message, error, stackTrace) ??
          _buildDefaultError(message, error, stackTrace),
    );
  }

  Widget _buildDefaultInitial() {
    return const EmptyStateWidget(
      title: '準備中',
      message: 'データを準備しています',
      icon: Icons.hourglass_empty,
    );
  }

  Widget _buildDefaultLoading(String? message) {
    return LoadingStateWidget.fullScreen(
      message: message ?? '読み込み中...',
    );
  }

  Widget _buildDefaultError(String message, Object? error, StackTrace? stackTrace) {
    return ErrorDisplay(
      message: message,
      onRetry: onRetry,
      showDetails: showDebugInfo,
      details: showDebugInfo ? '$error\n\n$stackTrace' : null,
    );
  }
}

/// スライバー版のResultStateWidget
class SliverResultStateWidget<T> extends StatelessWidget {
  final ResultState<T> state;
  final Widget Function(T data) builder;
  final Widget Function()? initialBuilder;
  final Widget Function(String? message)? loadingBuilder;
  final Widget Function(String message, Object? error, StackTrace? stackTrace)? errorBuilder;
  final VoidCallback? onRetry;

  const SliverResultStateWidget({
    super.key,
    required this.state,
    required this.builder,
    this.initialBuilder,
    this.loadingBuilder,
    this.errorBuilder,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final widget = state.when(
      success: builder,
      initial: () => initialBuilder?.call() ?? _buildDefaultInitial(),
      loading: (message) => loadingBuilder?.call(message) ?? _buildDefaultLoading(message),
      onError: (message, error, stackTrace) =>
          errorBuilder?.call(message, error, stackTrace) ??
          _buildDefaultError(message, error, stackTrace),
    );

    return SliverToBoxAdapter(child: widget);
  }

  Widget _buildDefaultInitial() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32.0),
        child: Text('データを準備中...'),
      ),
    );
  }

  Widget _buildDefaultLoading(String? message) {
    return LoadingStateWidget.fullScreen(
      message: message ?? '読み込み中...',
    );
  }

  Widget _buildDefaultError(String message, Object? error, StackTrace? stackTrace) {
    return ErrorDisplay(
      message: message,
      onRetry: onRetry,
    );
  }
}

/// RefreshIndicator付きのResultStateWidget
class RefreshableResultStateWidget<T> extends StatelessWidget {
  final ResultState<T> state;
  final Widget Function(T data) builder;
  final Future<void> Function() onRefresh;
  final Widget Function()? initialBuilder;
  final Widget Function(String? message)? loadingBuilder;
  final Widget Function(String message, Object? error, StackTrace? stackTrace)? errorBuilder;

  const RefreshableResultStateWidget({
    super.key,
    required this.state,
    required this.builder,
    required this.onRefresh,
    this.initialBuilder,
    this.loadingBuilder,
    this.errorBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ResultStateWidget<T>(
        state: state,
        builder: (data) => builder(data),
        initialBuilder: initialBuilder,
        loadingBuilder: loadingBuilder,
        errorBuilder: errorBuilder,
        onRetry: onRefresh,
      ),
    );
  }
}

/// リスト用のResultStateWidget
class ListResultStateWidget<T> extends StatelessWidget {
  final ResultState<List<T>> state;
  final Widget Function(List<T> data) builder;
  final Widget? emptyWidget;
  final Widget Function()? initialBuilder;
  final Widget Function(String? message)? loadingBuilder;
  final Widget Function(String message, Object? error, StackTrace? stackTrace)? errorBuilder;
  final VoidCallback? onRetry;

  const ListResultStateWidget({
    super.key,
    required this.state,
    required this.builder,
    this.emptyWidget,
    this.initialBuilder,
    this.loadingBuilder,
    this.errorBuilder,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return state.when(
      success: (data) {
        if (data.isEmpty) {
          return emptyWidget ?? _buildDefaultEmpty();
        }
        return builder(data);
      },
      initial: () => initialBuilder?.call() ?? _buildDefaultInitial(),
      loading: (message) => loadingBuilder?.call(message) ?? _buildDefaultLoading(message),
      onError: (message, error, stackTrace) =>
          errorBuilder?.call(message, error, stackTrace) ??
          _buildDefaultError(message, error, stackTrace),
    );
  }

  Widget _buildDefaultEmpty() {
    return const EmptyStateWidget(
      title: 'データがありません',
      message: '表示するアイテムがありません',
      icon: Icons.inbox_outlined,
    );
  }

  Widget _buildDefaultInitial() {
    return const EmptyStateWidget(
      title: '準備中',
      message: 'データを準備しています',
      icon: Icons.hourglass_empty,
    );
  }

  Widget _buildDefaultLoading(String? message) {
    return LoadingStateWidget.fullScreen(
      message: message ?? '読み込み中...',
    );
  }

  Widget _buildDefaultError(String message, Object? error, StackTrace? stackTrace) {
    return ErrorDisplay(
      message: message,
      onRetry: onRetry,
    );
  }
}

/// ページネーション付きのResultStateWidget
class PaginatedResultStateWidget<T> extends StatelessWidget {
  final ResultState<List<T>> state;
  final Widget Function(List<T> data) builder;
  final VoidCallback? onLoadMore;
  final bool hasNextPage;
  final bool isLoadingMore;
  final Widget? emptyWidget;
  final VoidCallback? onRetry;

  const PaginatedResultStateWidget({
    super.key,
    required this.state,
    required this.builder,
    this.onLoadMore,
    this.hasNextPage = false,
    this.isLoadingMore = false,
    this.emptyWidget,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return state.when(
      success: (data) {
        if (data.isEmpty) {
          return emptyWidget ?? _buildDefaultEmpty();
        }
        
        return Column(
          children: [
            Expanded(child: builder(data)),
            if (hasNextPage) _buildLoadMoreButton(),
          ],
        );
      },
      initial: () => _buildDefaultInitial(),
      loading: (message) => LoadingStateWidget.fullScreen(
        message: message ?? '読み込み中...',
      ),
      onError: (message, error, stackTrace) => ErrorDisplay(
        message: message,
        onRetry: onRetry,
      ),
    );
  }

  Widget _buildDefaultEmpty() {
    return const EmptyStateWidget(
      title: 'データがありません',
      message: '表示するアイテムがありません',
      icon: Icons.inbox_outlined,
    );
  }

  Widget _buildDefaultInitial() {
    return const EmptyStateWidget(
      title: '準備中',
      message: 'データを準備しています',
      icon: Icons.hourglass_empty,
    );
  }

  Widget _buildLoadMoreButton() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: isLoadingMore
          ? const LoadingStateWidget.inline()
          : ElevatedButton(
              onPressed: onLoadMore,
              child: const Text('さらに読み込む'),
            ),
    );
  }
}

/// ResultState用のConsumerWidget拡張
mixin ResultStateConsumerMixin<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  Widget buildResultState<R>({
    required ResultState<R> state,
    required Widget Function(R data) builder,
    VoidCallback? onRetry,
    Widget Function()? initialBuilder,
    Widget Function(String? message)? loadingBuilder,
    Widget Function(String message, Object? error, StackTrace? stackTrace)? errorBuilder,
  }) {
    return ResultStateWidget<R>(
      state: state,
      builder: builder,
      onRetry: onRetry,
      initialBuilder: initialBuilder,
      loadingBuilder: loadingBuilder,
      errorBuilder: errorBuilder,
    );
  }

  Widget buildListResultState<R>({
    required ResultState<List<R>> state,
    required Widget Function(List<R> data) builder,
    Widget? emptyWidget,
    VoidCallback? onRetry,
  }) {
    return ListResultStateWidget<R>(
      state: state,
      builder: builder,
      emptyWidget: emptyWidget,
      onRetry: onRetry,
    );
  }
}