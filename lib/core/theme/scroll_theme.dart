import 'package:flutter/material.dart';

class AppScrollTheme {
  static ScrollbarThemeData getScrollbarTheme(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return ScrollbarThemeData(
      thickness: WidgetStateProperty.all(8.0),
      thumbVisibility: WidgetStateProperty.all(false),
      trackVisibility: WidgetStateProperty.all(false),
      interactive: true,
      radius: const Radius.circular(4.0),
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.hovered)) {
          return isDark ? Colors.white54 : Colors.black45;
        }
        return isDark ? Colors.white38 : Colors.black26;
      }),
      trackColor: WidgetStateProperty.all(Colors.transparent),
      trackBorderColor: WidgetStateProperty.all(Colors.transparent),
      crossAxisMargin: 0.0,
      mainAxisMargin: 0.0,
      minThumbLength: 48.0,
    );
  }
}