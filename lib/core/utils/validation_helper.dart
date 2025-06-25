/// バリデーション関連のユーティリティクラス
class ValidationHelper {
  /// メールアドレスの形式をチェック
  static bool isValidEmail(String email) {
    return RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(email);
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

  /// 評価値（0.0-5.0）の有効性をチェック
  static bool isValidRating(double rating) {
    return rating >= 0.0 &&
        rating <= 5.0 &&
        !rating.isNaN &&
        !rating.isInfinite;
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

  /// 入力値のサニタイゼーション
  static String sanitizeInput(String input) {
    // 危険な文字やパターンを除去
    String sanitized = input
        .replaceAll(RegExp(r'<script.*?</script>', caseSensitive: false), '')
        .replaceAll(RegExp(r'javascript:', caseSensitive: false), '')
        .replaceAll(RegExp(r'<.*?>', caseSensitive: false), '') // HTMLタグ全般
        .replaceAll(
          RegExp(r'alert\s*\(.*?\)', caseSensitive: false),
          '',
        ) // alert関数の完全除去
        .replaceAll(RegExp(r'alert', caseSensitive: false), '') // alert文字列の除去
        .replaceAll(RegExp(r'onerror', caseSensitive: false), '')
        .replaceAll(RegExp(r'onload', caseSensitive: false), '')
        .replaceAll("'", "")
        .replaceAll('"', "")
        .replaceAll(";", "")
        .replaceAll("--", "")
        .replaceAll(RegExp(r'DROP', caseSensitive: false), '')
        .replaceAll(RegExp(r'DELETE', caseSensitive: false), '')
        .replaceAll(RegExp(r'UNION', caseSensitive: false), '')
        .replaceAll(RegExp(r'SELECT', caseSensitive: false), '');

    // 長さ制限
    if (sanitized.length > 1000) {
      sanitized = sanitized.substring(0, 1000);
    }

    return sanitized.trim();
  }

  /// 弱いパスワードかどうかをチェック
  static bool isWeakPassword(String password) {
    final weakPasswords = [
      'password',
      '123456',
      'qwerty',
      'admin',
      'password123',
      '111111',
      'abc123',
      'letmein',
      'welcome',
      'monkey',
    ];

    // 弱いパスワードリストにある場合
    if (weakPasswords.contains(password.toLowerCase())) {
      return true;
    }

    // 短すぎる場合
    if (password.length < 8) {
      return true;
    }

    // 同じ文字の繰り返しが多い場合
    if (RegExp(r'(.)\1{3,}').hasMatch(password)) {
      return true;
    }

    return false;
  }

  /// 安全なURLかどうかをチェック
  static bool isSafeUrl(String url) {
    try {
      final uri = Uri.parse(url);

      // 危険なスキームをチェック
      final dangerousSchemes = ['javascript', 'data', 'file', 'ftp'];
      if (dangerousSchemes.contains(uri.scheme?.toLowerCase())) {
        return false;
      }

      // HTTPSのみ許可（HTTP は開発環境を除いて危険）
      if (uri.scheme?.toLowerCase() != 'https') {
        return false;
      }

      // ローカルホストや内部IPアドレスをチェック
      final host = uri.host.toLowerCase();
      if (host.contains('localhost') ||
          host.contains('127.0.0.1') ||
          host.startsWith('192.168.') ||
          host.startsWith('10.0.') ||
          host.startsWith('172.')) {
        return false;
      }

      // パストラバーサル攻撃のチェック
      if (url.contains('../') || url.contains('..\\')) {
        return false;
      }

      return true;
    } catch (e) {
      return false;
    }
  }
}
