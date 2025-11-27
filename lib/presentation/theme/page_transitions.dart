import 'package:flutter/material.dart';

/// Custom page route with smooth fade and slide transitions
class FadeSlidePageRoute<T> extends PageRouteBuilder<T> {
  final Widget child;
  final Duration transitionDuration;
  final Offset beginOffset;

  FadeSlidePageRoute({
    required this.child,
    this.transitionDuration = const Duration(milliseconds: 300),
    this.beginOffset = const Offset(0.0, 0.05),
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionDuration: transitionDuration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // Fade transition
            final fadeAnimation = Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeOut,
              ),
            );

            // Slide transition
            final slideAnimation = Tween<Offset>(
              begin: beginOffset,
              end: Offset.zero,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              ),
            );

            return FadeTransition(
              opacity: fadeAnimation,
              child: SlideTransition(
                position: slideAnimation,
                child: child,
              ),
            );
          },
        );
}

/// Custom page route with slide transition (for horizontal navigation)
class SlidePageRoute<T> extends PageRouteBuilder<T> {
  final Widget child;
  final Duration transitionDuration;
  final bool slideFromRight;

  SlidePageRoute({
    required this.child,
    this.transitionDuration = const Duration(milliseconds: 300),
    this.slideFromRight = true,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionDuration: transitionDuration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final slideAnimation = Tween<Offset>(
              begin: slideFromRight ? const Offset(1.0, 0.0) : const Offset(-1.0, 0.0),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              ),
            );

            return SlideTransition(
              position: slideAnimation,
              child: child,
            );
          },
        );
}

/// Helper functions to easily use custom transitions
class AppNavigator {
  /// Push with fade and slide transition
  static Future<T?> pushFadeSlide<T extends Object?>(
    BuildContext context,
    Widget page, {
    Offset beginOffset = const Offset(0.0, 0.05),
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return Navigator.of(context).push(
      FadeSlidePageRoute(
        child: page,
        beginOffset: beginOffset,
        transitionDuration: duration,
      ),
    );
  }

  /// Push with slide transition
  static Future<T?> pushSlide<T extends Object?>(
    BuildContext context,
    Widget page, {
    bool slideFromRight = true,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return Navigator.of(context).push(
      SlidePageRoute(
        child: page,
        slideFromRight: slideFromRight,
        transitionDuration: duration,
      ),
    );
  }

  /// Push replacement with fade and slide transition
  static Future<T?> pushReplacementFadeSlide<T extends Object?, TO extends Object?>(
    BuildContext context,
    Widget page, {
    Offset beginOffset = const Offset(0.0, 0.05),
    Duration duration = const Duration(milliseconds: 300),
    TO? result,
  }) {
    return Navigator.of(context).pushReplacement(
      FadeSlidePageRoute(
        child: page,
        beginOffset: beginOffset,
        transitionDuration: duration,
      ),
      result: result,
    );
  }

  /// Push and remove until with fade and slide transition
  static Future<T?> pushAndRemoveUntilFadeSlide<T extends Object?>(
    BuildContext context,
    Widget page,
    bool Function(Route<dynamic>) predicate, {
    Offset beginOffset = const Offset(0.0, 0.05),
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return Navigator.of(context).pushAndRemoveUntil(
      FadeSlidePageRoute(
        child: page,
        beginOffset: beginOffset,
        transitionDuration: duration,
      ),
      predicate,
    );
  }
}

