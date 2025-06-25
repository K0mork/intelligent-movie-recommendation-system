import 'package:flutter/material.dart';

class TestHelpers {
  /// テスト用のWidgetを作成するヘルパーメソッド
  static Widget createTestWidget({required Widget child, ThemeData? theme}) {
    return MaterialApp(
      theme: theme ?? ThemeData.light(),
      home: Scaffold(body: child),
    );
  }

  /// テスト用のProviderScopeラップWidgetを作成
  static Widget createTestWidgetWithProviders({
    required Widget child,
    ThemeData? theme,
    List<Object>? overrides,
  }) {
    return MaterialApp(
      theme: theme ?? ThemeData.light(),
      home: Scaffold(body: child),
    );
  }
}
