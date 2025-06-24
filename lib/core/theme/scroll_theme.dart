import 'package:flutter/material.dart';

/// スクロールバーのテーマとスタイル定数を管理するクラス
class AppScrollTheme {
  // スクロールバーの定数
  static const double scrollbarThickness = 8.0;
  static const double scrollbarRadius = 4.0;
  static const double minThumbLength = 48.0;

  /// ライトテーマ用のスクロールバーテーマデータを取得
  static ScrollbarThemeData get lightTheme => ScrollbarThemeData(
    thickness: WidgetStateProperty.all(scrollbarThickness),
    thumbVisibility: WidgetStateProperty.all(false),
    trackVisibility: WidgetStateProperty.all(false),
    interactive: true,
    radius: const Radius.circular(scrollbarRadius),
    thumbColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.hovered)) {
        return Colors.black45;
      }
      return Colors.black26;
    }),
    trackColor: WidgetStateProperty.all(Colors.transparent),
    trackBorderColor: WidgetStateProperty.all(Colors.transparent),
    crossAxisMargin: 0.0,
    mainAxisMargin: 0.0,
    minThumbLength: minThumbLength,
  );

  /// ダークテーマ用のスクロールバーテーマデータを取得
  static ScrollbarThemeData get darkTheme => ScrollbarThemeData(
    thickness: WidgetStateProperty.all(scrollbarThickness),
    thumbVisibility: WidgetStateProperty.all(false),
    trackVisibility: WidgetStateProperty.all(false),
    interactive: true,
    radius: const Radius.circular(scrollbarRadius),
    thumbColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.hovered)) {
        return Colors.white54;
      }
      return Colors.white38;
    }),
    trackColor: WidgetStateProperty.all(Colors.transparent),
    trackBorderColor: WidgetStateProperty.all(Colors.transparent),
    crossAxisMargin: 0.0,
    mainAxisMargin: 0.0,
    minThumbLength: minThumbLength,
  );

  /// コンテキストに基づいて適切なスクロールバーテーマを取得
  static ScrollbarThemeData getScrollbarTheme(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? darkTheme : lightTheme;
  }
}
