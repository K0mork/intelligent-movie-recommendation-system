import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'scroll_theme.dart';

/// アプリケーション全体のテーマ設定を管理するクラス
class AppTheme {
  /// ライトテーマの設定
  static ThemeData get lightTheme {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      useMaterial3: true,
      scrollbarTheme: AppScrollTheme.lightTheme,
      textTheme: _buildTextTheme(false),
    );
  }

  /// ダークテーマの設定
  static ThemeData get darkTheme {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.deepPurple,
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
      scrollbarTheme: AppScrollTheme.darkTheme,
      textTheme: _buildTextTheme(true),
    );
  }

  /// フォントテーマの構築
  static TextTheme _buildTextTheme(bool isDark) {
    final baseTextTheme =
        isDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme;

    return TextTheme(
      // 大見出し（タイトル用）- SemiBold 600
      displayLarge: GoogleFonts.notoSans(
        textStyle: baseTextTheme.displayLarge,
        fontWeight: FontWeight.w600,
      ),
      displayMedium: GoogleFonts.notoSans(
        textStyle: baseTextTheme.displayMedium,
        fontWeight: FontWeight.w600,
      ),
      displaySmall: GoogleFonts.notoSans(
        textStyle: baseTextTheme.displaySmall,
        fontWeight: FontWeight.w600,
      ),

      // 見出し（タイトル用）- SemiBold 600
      headlineLarge: GoogleFonts.notoSans(
        textStyle: baseTextTheme.headlineLarge,
        fontWeight: FontWeight.w600,
      ),
      headlineMedium: GoogleFonts.notoSans(
        textStyle: baseTextTheme.headlineMedium,
        fontWeight: FontWeight.w600,
      ),
      headlineSmall: GoogleFonts.notoSans(
        textStyle: baseTextTheme.headlineSmall,
        fontWeight: FontWeight.w600,
      ),

      // タイトル（タイトル用）- SemiBold 600
      titleLarge: GoogleFonts.notoSans(
        textStyle: baseTextTheme.titleLarge,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: GoogleFonts.notoSans(
        textStyle: baseTextTheme.titleMedium,
        fontWeight: FontWeight.w600,
      ),
      titleSmall: GoogleFonts.notoSans(
        textStyle: baseTextTheme.titleSmall,
        fontWeight: FontWeight.w600,
      ),

      // 本文（Noto Sans）
      bodyLarge: GoogleFonts.notoSans(
        textStyle: baseTextTheme.bodyLarge,
        fontWeight: FontWeight.normal,
      ),
      bodyMedium: GoogleFonts.notoSans(
        textStyle: baseTextTheme.bodyMedium,
        fontWeight: FontWeight.normal,
      ),
      bodySmall: GoogleFonts.notoSans(
        textStyle: baseTextTheme.bodySmall,
        fontWeight: FontWeight.normal,
      ),

      // ラベル（Noto Sans）
      labelLarge: GoogleFonts.notoSans(
        textStyle: baseTextTheme.labelLarge,
        fontWeight: FontWeight.normal,
      ),
      labelMedium: GoogleFonts.notoSans(
        textStyle: baseTextTheme.labelMedium,
        fontWeight: FontWeight.normal,
      ),
      labelSmall: GoogleFonts.notoSans(
        textStyle: baseTextTheme.labelSmall,
        fontWeight: FontWeight.normal,
      ),
    );
  }

  /// カスタムタイトルスタイル（SemiBold 600）
  static TextStyle titleStyle({
    required BuildContext context,
    double? fontSize,
    Color? color,
  }) {
    return GoogleFonts.notoSans(
      fontSize: fontSize ?? 16,
      fontWeight: FontWeight.w600,
      color: color ?? Theme.of(context).colorScheme.onSurface,
    );
  }

  /// カスタム本文スタイル（Noto Sans）
  static TextStyle bodyStyle({
    required BuildContext context,
    double? fontSize,
    Color? color,
    FontWeight? fontWeight,
  }) {
    return GoogleFonts.notoSans(
      fontSize: fontSize ?? 14,
      fontWeight: fontWeight ?? FontWeight.normal,
      color: color ?? Theme.of(context).colorScheme.onSurface,
    );
  }
}
