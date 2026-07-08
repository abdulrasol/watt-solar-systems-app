import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:watt/src/core/theme/app_colors.dart';

/// A reusable card widget with consistent elevation, border radius,
/// padding, and theming across the application.
class AppCard extends ConsumerWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Color? backgroundColor;
  final double elevation;
  final VoidCallback? onTap;
  final Border? border;
  final EdgeInsetsGeometry? margin;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = 16,
    this.backgroundColor,
    this.elevation = 0,
    this.onTap,
    this.border,
    this.margin,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(appColorsProvider);

    Widget card = Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? colors.surface,
        borderRadius: BorderRadius.circular(borderRadius),
        border: border ?? Border.all(color: colors.border),
      ),
      child: child,
    );

    if (elevation > 0) {
      card = Material(
        color: Colors.transparent,
        elevation: elevation,
        borderRadius: BorderRadius.circular(borderRadius),
        shadowColor: colors.shadow,
        child: card,
      );
    }

    if (onTap != null) {
      card = InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: card,
      );
    }

    return card;
  }
}
