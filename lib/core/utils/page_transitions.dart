import 'package:flutter/material.dart';

class SlidePageRoute<T> extends PageRouteBuilder<T> {
  final Widget child;
  final Offset begin;
  final Offset end;
  final Duration duration;

  SlidePageRoute({
    required this.child,
    this.begin = const Offset(1.0, 0.0),
    this.end = Offset.zero,
    this.duration = const Duration(milliseconds: 300),
    RouteSettings? settings,
  }) : super(
         settings: settings,
         transitionDuration: duration,
         pageBuilder: (context, animation, secondaryAnimation) => child,
       );

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: begin,
        end: end,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut)),
      child: child,
    );
  }
}

class FadePageRoute<T> extends PageRouteBuilder<T> {
  final Widget child;
  final Duration duration;

  FadePageRoute({
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    RouteSettings? settings,
  }) : super(
         settings: settings,
         transitionDuration: duration,
         pageBuilder: (context, animation, secondaryAnimation) => child,
       );

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(opacity: animation, child: child);
  }
}

class ScalePageRoute<T> extends PageRouteBuilder<T> {
  final Widget child;
  final Duration duration;

  ScalePageRoute({
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    RouteSettings? settings,
  }) : super(
         settings: settings,
         transitionDuration: duration,
         pageBuilder: (context, animation, secondaryAnimation) => child,
       );

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return ScaleTransition(
      scale: Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.elasticOut)),
      child: child,
    );
  }
}

class SlideFadePageRoute<T> extends PageRouteBuilder<T> {
  final Widget child;
  final Offset begin;
  final Offset end;
  final Duration duration;

  SlideFadePageRoute({
    required this.child,
    this.begin = const Offset(0.0, 0.3),
    this.end = Offset.zero,
    this.duration = const Duration(milliseconds: 400),
    RouteSettings? settings,
  }) : super(
         settings: settings,
         transitionDuration: duration,
         pageBuilder: (context, animation, secondaryAnimation) => child,
       );

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final slideTween = Tween<Offset>(begin: begin, end: end);
    final fadeTween = Tween<double>(begin: 0.0, end: 1.0);

    final curvedAnimation = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
    );

    return SlideTransition(
      position: slideTween.animate(curvedAnimation),
      child: FadeTransition(
        opacity: fadeTween.animate(curvedAnimation),
        child: child,
      ),
    );
  }
}

class PageTransitionHelper {
  static Route<T> slideFromRight<T>(Widget page, {RouteSettings? settings}) {
    return SlidePageRoute<T>(
      child: page,
      begin: const Offset(1.0, 0.0),
      settings: settings,
    );
  }

  static Route<T> slideFromLeft<T>(Widget page, {RouteSettings? settings}) {
    return SlidePageRoute<T>(
      child: page,
      begin: const Offset(-1.0, 0.0),
      settings: settings,
    );
  }

  static Route<T> slideFromBottom<T>(Widget page, {RouteSettings? settings}) {
    return SlidePageRoute<T>(
      child: page,
      begin: const Offset(0.0, 1.0),
      settings: settings,
    );
  }

  static Route<T> slideFromTop<T>(Widget page, {RouteSettings? settings}) {
    return SlidePageRoute<T>(
      child: page,
      begin: const Offset(0.0, -1.0),
      settings: settings,
    );
  }

  static Route<T> fade<T>(Widget page, {RouteSettings? settings}) {
    return FadePageRoute<T>(child: page, settings: settings);
  }

  static Route<T> scale<T>(Widget page, {RouteSettings? settings}) {
    return ScalePageRoute<T>(child: page, settings: settings);
  }

  static Route<T> slideFadeFromBottom<T>(
    Widget page, {
    RouteSettings? settings,
  }) {
    return SlideFadePageRoute<T>(
      child: page,
      begin: const Offset(0.0, 0.3),
      settings: settings,
    );
  }
}
