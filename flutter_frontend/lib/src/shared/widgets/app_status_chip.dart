import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_hub/src/core/theme/app_colors.dart';
import 'package:solar_hub/src/utils/app_theme.dart';

/// Predefined status types used by [AppStatusChip].
enum AppStatusType {
  success,
  warning,
  error,
  info,
  neutral,
  primary,
}

/// A reusable status chip widget for displaying entity states.
class AppStatusChip extends ConsumerWidget {
  final String label;
  final AppStatusType type;
  final IconData? icon;
  final double height;
  final EdgeInsetsGeometry padding;

  const AppStatusChip({
    super.key,
    required this.label,
    this.type = AppStatusType.neutral,
    this.icon,
    this.height = 28,
    this.padding = const EdgeInsets.symmetric(horizontal: 10),
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(appColorsProvider);
    final (background, foreground) = _resolveColors(colors);

    return Container(
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(height / 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: foreground),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: foreground,
            ),
          ),
        ],
      ),
    );
  }

  (Color, Color) _resolveColors(AppColors colors) {
    switch (type) {
      case AppStatusType.success:
        return (colors.success.withValues(alpha: 0.12), colors.success);
      case AppStatusType.warning:
        return (colors.warning.withValues(alpha: 0.12), colors.warning);
      case AppStatusType.error:
        return (colors.error.withValues(alpha: 0.12), colors.error);
      case AppStatusType.info:
        return (colors.info.withValues(alpha: 0.12), colors.info);
      case AppStatusType.primary:
        return (colors.primary.withValues(alpha: 0.12), colors.primary);
      case AppStatusType.neutral:
        return (colors.textSecondary.withValues(alpha: 0.12), colors.textSecondary);
    }
  }
}
