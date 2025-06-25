import 'package:flutter/material.dart';

/// SnackBar表示のヘルパークラス
class SnackBarHelper {
  /// 情報メッセージを表示
  static void showInfo(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 2),
  }) {
    _showSnackBar(
      context,
      message,
      backgroundColor: Colors.blue,
      duration: duration,
    );
  }

  /// 成功メッセージを表示
  static void showSuccess(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 2),
  }) {
    _showSnackBar(
      context,
      message,
      backgroundColor: Colors.green,
      duration: duration,
    );
  }

  /// エラーメッセージを表示
  static void showError(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    _showSnackBar(
      context,
      message,
      backgroundColor: Colors.red,
      duration: duration,
    );
  }

  /// 警告メッセージを表示
  static void showWarning(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    _showSnackBar(
      context,
      message,
      backgroundColor: Colors.orange,
      duration: duration,
    );
  }

  /// 基本的なSnackBar表示処理
  static void _showSnackBar(
    BuildContext context,
    String message, {
    required Color backgroundColor,
    Duration duration = const Duration(seconds: 2),
  }) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: backgroundColor,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
