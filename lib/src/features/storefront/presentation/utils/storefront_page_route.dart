import 'package:flutter/material.dart';

Route<T> buildStorefrontRoute<T>({
  required BuildContext context,
  required Widget page,
  RouteSettings? settings,
}) {
  final isRtl = Directionality.of(context) == TextDirection.rtl;
  final beginOffset = Offset(isRtl ? -0.08 : 0.08, 0);

  return PageRouteBuilder<T>(
    settings: settings,
    pageBuilder: (pageContext, animation, secondaryAnimation) =>
        FadeTransition(opacity: animation, child: page),
    transitionDuration: const Duration(milliseconds: 260),
    reverseTransitionDuration: const Duration(milliseconds: 220),
    transitionsBuilder:
        (transitionContext, animation, secondaryAnimation, child) {
          final slide = Tween<Offset>(begin: beginOffset, end: Offset.zero)
              .animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
              );

          return SlideTransition(
            position: slide,
            child: FadeTransition(opacity: animation, child: child),
          );
        },
  );
}
