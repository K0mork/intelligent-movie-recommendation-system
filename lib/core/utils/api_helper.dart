import 'package:filmflow/core/constants/app_constants.dart';

/// API関連のユーティリティクラス
class ApiHelper {
  /// TMDb画像URLを構築
  static String buildTMDbImageUrl(String? path, {String size = 'w500'}) {
    if (path == null || path.isEmpty) {
      return '';
    }
    return '${AppConstants.tmdbImageBaseUrl.replaceAll('w500', size)}$path';
  }

  /// エラーメッセージを日本語に変換
  static String translateErrorMessage(String error) {
    if (error.toLowerCase().contains('network')) {
      return AppConstants.networkError;
    }
    if (error.toLowerCase().contains('timeout')) {
      return 'リクエストがタイムアウトしました';
    }
    if (error.toLowerCase().contains('unauthorized')) {
      return 'APIキーが無効です';
    }
    if (error.toLowerCase().contains('not found')) {
      return '要求されたデータが見つかりません';
    }
    if (error.toLowerCase().contains('server')) {
      return 'サーバーエラーが発生しました';
    }
    return AppConstants.unknownError;
  }

  /// ページネーション用のクエリパラメータを構築
  static Map<String, dynamic> buildPaginationParams({
    required int page,
    int? limit,
    Map<String, dynamic>? additionalParams,
  }) {
    final params = <String, dynamic>{
      'page': page,
    };
    
    if (limit != null) {
      params['limit'] = limit;
    }
    
    if (additionalParams != null) {
      params.addAll(additionalParams);
    }
    
    return params;
  }

  /// API レスポンスの成功判定
  static bool isSuccessResponse(int statusCode) {
    return statusCode >= 200 && statusCode < 300;
  }

  /// 検索クエリの正規化
  static String normalizeSearchQuery(String query) {
    return query.trim().toLowerCase();
  }

  /// 安全なAPIキーの取得（先頭と末尾のみ表示）
  static String maskApiKey(String apiKey) {
    if (apiKey.length <= 8) return '***';
    
    final start = apiKey.substring(0, 4);
    final end = apiKey.substring(apiKey.length - 4);
    return '$start***$end';
  }

  /// JSON レスポンスから安全に値を取得
  static T? getSafeValue<T extends Object>(Map<String, dynamic> json, String key) {
    try {
      final value = json[key];
      return value is T ? value : null;
    } catch (e) {
      return null;
    }
  }

  /// 複数のAPIキーから有効なものを選択
  static String? selectValidApiKey(List<String> apiKeys) {
    for (final key in apiKeys) {
      if (key.isNotEmpty && key.length > 10) {
        return key;
      }
    }
    return null;
  }
}