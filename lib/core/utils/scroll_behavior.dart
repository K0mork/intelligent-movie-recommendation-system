import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class CustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
      };

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    if (kIsWeb) {
      // Web環境（Mac含む）でのスクロール物理特性
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
      // Web環境でのスクロールバー設定
      return RawScrollbar(
        controller: details.controller,
        thumbVisibility: false,
        trackVisibility: false,
        thickness: 8.0,
        radius: const Radius.circular(4.0),
        child: child,
      );
    }
    return super.buildScrollbar(context, child, details);
  }
}