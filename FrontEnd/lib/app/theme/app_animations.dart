import 'package:flutter/material.dart';

abstract final class AppAnimations {
  // Durations
  static const fast = Duration(milliseconds: 150);
  static const normal = Duration(milliseconds: 300);
  static const slow = Duration(milliseconds: 500);
  static const verySlow = Duration(milliseconds: 800);
  
  // Curves
  static const standard = Curves.easeInOut;
  static const decelerate = Curves.easeOut;
  static const accelerate = Curves.easeIn;
  static const elastic = Curves.elasticOut;
  static const bounce = Curves.bounceOut;
  
  // Semantic animations
  static const pageTransition = normal;
  static const modalTransition = normal;
  static const buttonPress = fast;
  static const listItem = normal;
  static const shimmer = slow;
  static const hero = normal;
  static const snackbar = normal;
  static const tooltip = fast;
  static const progress = slow;
  
  // Helper for creating animations
  static Animation<double> createAnimation({
    required AnimationController controller,
    Curve curve = standard,
  }) {
    return Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: curve,
      ),
    );
  }
  
  // Page transition builder
  static PageRouteBuilder<T> pageRoute<T>({
    required Widget page,
    RouteSettings? settings,
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;
        
        var tween = Tween(begin: begin, end: end).animate(
          CurvedAnimation(
            parent: animation,
            curve: curve,
          ),
        );
        
        return SlideTransition(
          position: tween,
          child: child,
        );
      },
      transitionDuration: pageTransition,
    );
  }
  
  // Modal transition builder
  static Route<T> modalRoute<T>({
    required WidgetBuilder builder,
    RouteSettings? settings,
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) {
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          ),
          child: ScaleTransition(
            scale: Tween<double>(
              begin: 0.9,
              end: 1.0,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeOut,
              ),
            ),
            child: builder(context),
          ),
        );
      },
    );
  }
}
