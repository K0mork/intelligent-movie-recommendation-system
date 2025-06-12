import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// アプリ全体のスクロール動作を統一するためのカスタムScrollBehavior
/// Web環境（Mac含む）での最適なスクロール体験を提供
class AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
      };

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    if (kIsWeb) {
      // Web環境（Mac Safari含む）でのスクロール物理特性
      return const ClampingScrollPhysics();
    }
    return super.getScrollPhysics(context);
  }

  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    if (kIsWeb) {
      return Scrollbar(
        controller: details.controller,
        thumbVisibility: false,
        trackVisibility: false,
        thickness: 8.0,
        radius: const Radius.circular(4.0),
        interactive: true,
        child: child,
      );
    }
    return super.buildScrollbar(context, child, details);
  }
}