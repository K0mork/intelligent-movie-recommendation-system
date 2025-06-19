import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/recommendation_providers.dart';
import '../controllers/recommendation_controller.dart';
import '../widgets/recommendation_card.dart';
import '../widgets/recommendation_empty_state.dart';
import '../widgets/recommendation_error_widget.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../../core/widgets/breadcrumb_widget.dart';

class RecommendationsPage extends ConsumerStatefulWidget {
  const RecommendationsPage({super.key});

  @override
  ConsumerState<RecommendationsPage> createState() => _RecommendationsPageState();
}

class _RecommendationsPageState extends ConsumerState<RecommendationsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // 初回データ読み込み
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadInitialData() {
    final controller = ref.read(recommendationControllerProvider);
    controller.loadRecommendations();
    controller.loadSavedRecommendations();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final isLoading = ref.watch(recommendationLoadingProvider);

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            'ログインして推薦機能をご利用ください',
            style: TextStyle(fontSize: 18),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('映画推薦'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.recommend),
              text: '推薦結果',
            ),
            Tab(
              icon: Icon(Icons.bookmark),
              text: '保存済み',
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: isLoading ? null : _generateNewRecommendations,
            icon: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh),
            tooltip: '新しい推薦を生成',
          ),
        ],
      ),
      body: Column(
        children: [
          // パンくずナビゲーション
          BreadcrumbWidget(
            items: BreadcrumbHelper.createRecommendationBreadcrumbs(
              context: context,
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildRecommendationsTab(),
                _buildSavedRecommendationsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsTab() {
    final recommendationsAsync = ref.watch(recommendationsProvider);

    return recommendationsAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, stackTrace) => RecommendationErrorWidget(
        error: error.toString(),
        onRetry: () => ref.read(recommendationControllerProvider).loadRecommendations(),
      ),
      data: (recommendations) {
        if (recommendations.isEmpty) {
          return RecommendationEmptyState(
            message: 'まだ推薦結果がありません',
            actionText: '推薦を生成する',
            onAction: _generateNewRecommendations,
          );
        }

        return RefreshIndicator(
          onRefresh: () => ref.read(recommendationControllerProvider).loadRecommendations(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: recommendations.length,
            itemBuilder: (context, index) {
              final recommendation = recommendations[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: RecommendationCard(
                  recommendation: recommendation,
                  onSave: () => _saveRecommendation(recommendation.id),
                  onFeedback: (isHelpful, feedback) => _submitFeedback(
                    recommendation.id,
                    isHelpful,
                    feedback,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildSavedRecommendationsTab() {
    final savedRecommendationsAsync = ref.watch(savedRecommendationsProvider);

    return savedRecommendationsAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, stackTrace) => RecommendationErrorWidget(
        error: error.toString(),
        onRetry: () => ref.read(recommendationControllerProvider).loadSavedRecommendations(),
      ),
      data: (savedRecommendations) {
        if (savedRecommendations.isEmpty) {
          return const RecommendationEmptyState(
            message: '保存済みの推薦結果がありません',
            actionText: '',
          );
        }

        return RefreshIndicator(
          onRefresh: () => ref.read(recommendationControllerProvider).loadSavedRecommendations(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: savedRecommendations.length,
            itemBuilder: (context, index) {
              final recommendation = savedRecommendations[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: RecommendationCard(
                  recommendation: recommendation,
                  isSaved: true,
                  onDelete: () => _deleteSavedRecommendation(recommendation.id),
                  onFeedback: (isHelpful, feedback) => _submitFeedback(
                    recommendation.id,
                    isHelpful,
                    feedback,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _generateNewRecommendations() async {
    try {
      await ref.read(recommendationControllerProvider).generateRecommendations();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('新しい推薦結果を生成しました'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('推薦生成に失敗しました: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveRecommendation(String recommendationId) async {
    try {
      await ref.read(recommendationControllerProvider).saveRecommendation(recommendationId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('推薦結果を保存しました'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('保存に失敗しました: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteSavedRecommendation(String recommendationId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('削除確認'),
        content: const Text('この推薦結果を削除しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('削除'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(recommendationControllerProvider).deleteSavedRecommendation(recommendationId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('推薦結果を削除しました'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('削除に失敗しました: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _submitFeedback(
    String recommendationId,
    bool isHelpful,
    String? feedback,
  ) async {
    try {
      await ref.read(recommendationControllerProvider).submitFeedback(
        recommendationId,
        isHelpful,
        feedback,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('フィードバックを送信しました'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('フィードバック送信に失敗しました: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}