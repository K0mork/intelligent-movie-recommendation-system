/// 日付関連のユーティリティクラス
class DateHelper {
  /// 日付文字列を日本語フォーマットに変換
  static String formatJapaneseDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return '不明';
    }

    try {
      final date = DateTime.parse(dateString);
      return '${date.year}年${date.month}月${date.day}日';
    } catch (e) {
      return dateString;
    }
  }

  /// 日付文字列から年を抽出
  static int? extractYear(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;

    try {
      return DateTime.parse(dateString).year;
    } catch (e) {
      return null;
    }
  }

  /// 現在の日付から指定日数前の日付を取得
  static DateTime getDaysAgo(int days) {
    return DateTime.now().subtract(Duration(days: days));
  }

  /// 日付が今日かどうかを判定
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
           date.month == now.month &&
           date.day == now.day;
  }

  /// 相対的な時間表示（例：2時間前、3日前）
  static String getRelativeTimeString(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}日前';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}時間前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分前';
    } else {
      return 'たった今';
    }
  }
}
