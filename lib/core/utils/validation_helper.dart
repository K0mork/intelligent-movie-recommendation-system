/// バリデーション関連のユーティリティクラス
class ValidationHelper {
  /// メールアドレスの形式をチェック
  static bool isValidEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(email);
  }

  /// パスワードの強度をチェック（最低8文字）
  static bool isValidPassword(String password) {
    return password.length >= 8;
  }

  /// 映画タイトルの有効性をチェック
  static bool isValidMovieTitle(String title) {
    return title.trim().isNotEmpty && title.trim().length >= 2;
  }

  /// レビューテキストの有効性をチェック
  static bool isValidReviewText(String review) {
    return review.trim().isNotEmpty && review.trim().length >= 10;
  }

  /// 評価値（0.0-10.0）の有効性をチェック
  static bool isValidRating(double rating) {
    return rating >= 0.0 && rating <= 10.0;
  }

  /// URLの有効性をチェック
  static bool isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  /// 画像URLの有効性をチェック
  static bool isValidImageUrl(String url) {
    if (!isValidUrl(url)) return false;
    
    final supportedExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp'];
    final lowercaseUrl = url.toLowerCase();
    
    return supportedExtensions.any((ext) => lowercaseUrl.contains(ext));
  }

  /// 年の有効性をチェック（映画リリース年として妥当か）
  static bool isValidReleaseYear(int year) {
    final currentYear = DateTime.now().year;
    return year >= 1888 && year <= currentYear + 5; // 映画史の始まりから未来5年まで
  }

  /// 文字列が空でないかチェック
  static bool isNotEmpty(String? value) {
    return value != null && value.trim().isNotEmpty;
  }

  /// 文字列の長さが指定範囲内かチェック
  static bool isLengthInRange(String value, int min, int max) {
    final length = value.trim().length;
    return length >= min && length <= max;
  }
}