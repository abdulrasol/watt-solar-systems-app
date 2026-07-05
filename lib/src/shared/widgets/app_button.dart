import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_hub/src/core/theme/app_colors.dart';
import 'package:solar_hub/src/utils/app_theme.dart';

/// Predefined button variants used by [AppButton].
enum AppButtonVariant {
  primary,
  secondary,
  outlined,
  text,
  destructive,
}

/// A reusable button widget that centralizes all button styles in the app.
class AppButton extends ConsumerWidget {
  final String? text;
  final Widget? child;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final AppButtonVariant variant;
  final double? width;
  final double height;
  final double borderRadius;
  final EdgeInsetsGeometry padding;

  const AppButton({
    super.key,
    this.text,
    this.child,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.variant = AppButtonVariant.primary,
    this.width,
    this.height = 48,
    this.borderRadius = 12,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
  }) : assert(text != null || child != null, 'Either text or child must be provided');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(appColorsProvider);

    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: _buildStyle(colors),
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(_foregroundColor(colors)),
                ),
              )
            : child ?? _buildContent(colors),
      ),
    );
  }

  Widget _buildContent(AppColors colors) {
    final contentColor = _foregroundColor(colors);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 18, color: contentColor),
          const SizedBox(width: 8),
        ],
        Text(
          text!,
          style: TextStyle(
            fontFamily: AppTheme.fontFamily,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: contentColor,
          ),
        ),
      ],
    );
  }

  ButtonStyle _buildStyle(AppColors colors) {
    final foreground = _foregroundColor(colors);
    final background = _backgroundColor(colors);

    return ButtonStyle(
      elevation: const WidgetStatePropertyAll<double>(0),
      padding: WidgetStatePropertyAll<EdgeInsetsGeometry>(padding),
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return background.withValues(alpha: 0.5);
        }
        return background;
      }),
      foregroundColor: WidgetStatePropertyAll<Color>(foreground),
      overlayColor: WidgetStatePropertyAll<Color>(foreground.withValues(alpha: 0.08)),
      shape: WidgetStatePropertyAll<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          side: _borderSide(colors),
        ),
      ),
    );
  }

  Color _backgroundColor(AppColors colors) {
    switch (variant) {
      case AppButtonVariant.primary:
      case AppButtonVariant.destructive:
        return variant == AppButtonVariant.destructive ? colors.error : colors.primary;
      case AppButtonVariant.secondary:
        return colors.primary.withValues(alpha: 0.08);
      case AppButtonVariant.outlined:
      case AppButtonVariant.text:
        return Colors.transparent;
    }
  }

  Color _foregroundColor(AppColors colors) {
    switch (variant) {
      case AppButtonVariant.primary:
      case AppButtonVariant.destructive:
        return Colors.white;
      case AppButtonVariant.secondary:
        return colors.primary;
      case AppButtonVariant.outlined:
        return colors.primary;
      case AppButtonVariant.text:
        return colors.primary;
    }
  }

  BorderSide _borderSide(AppColors colors) {
    switch (variant) {
      case AppButtonVariant.outlined:
        return BorderSide(color: colors.border);
      default:
        return BorderSide.none;
    }
  }
}
