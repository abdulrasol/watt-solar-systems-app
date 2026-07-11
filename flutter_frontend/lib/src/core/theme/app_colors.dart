import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:watt/src/features/settings/presentation/providers/settings_provider.dart';

/// Centralized color palette for the Watt application.
///
/// Follows the same pattern as the reference `meaad` project, adapted to
/// SolarHub's existing teal primary color.
@immutable
class AppColors {
  final Color primary;
  final Color primaryLight;
  final Color primaryDark;
  final Color secondary;
  final Color background;
  final Color surface;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color border;
  final Color divider;
  final Color success;
  final Color warning;
  final Color error;
  final Color info;
  final Color shadow;
  final Color overlay;

  // Order-status tokens (storefront/orders UX pass). Kept separate from the
  // generic success/warning/error/info tokens above because a single order
  // status maps to a specific stage, not a generic severity level.
  final Color orderPending;
  final Color orderProcessing;
  final Color orderShipped;
  final Color orderDelivered;
  final Color orderCancelled;
  final Color orderCompleted;

  // Stock-availability tokens.
  final Color stockInStock;
  final Color stockLowStock;
  final Color stockOutOfStock;

  // B2B / B2C audience accent tints, used to visually separate the two
  // cart/order contexts a company member can have at the same time.
  final Color audienceB2b;
  final Color audienceB2c;

  const AppColors({
    required this.primary,
    required this.primaryLight,
    required this.primaryDark,
    required this.secondary,
    required this.background,
    required this.surface,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.border,
    required this.divider,
    required this.success,
    required this.warning,
    required this.error,
    required this.info,
    required this.shadow,
    required this.overlay,
    required this.orderPending,
    required this.orderProcessing,
    required this.orderShipped,
    required this.orderDelivered,
    required this.orderCancelled,
    required this.orderCompleted,
    required this.stockInStock,
    required this.stockLowStock,
    required this.stockOutOfStock,
    required this.audienceB2b,
    required this.audienceB2c,
  });

  /// Light mode color scheme.
  factory AppColors.light() {
    return const AppColors(
      primary: Color(0xFF00BFA5),
      primaryLight: Color(0xFF5DF2D6),
      primaryDark: Color(0xFF008E76),
      secondary: Color(0xFFFFAB40),
      background: Color(0xFFF8FAFC),
      surface: Color(0xFFFFFFFF),
      textPrimary: Color(0xFF1E293B),
      textSecondary: Color(0xFF64748B),
      textTertiary: Color(0xFF94A3B8),
      border: Color(0xFFE2E8F0),
      divider: Color(0xFFE2E8F0),
      success: Color(0xFF10B981),
      warning: Color(0xFFF59E0B),
      error: Color(0xFFEF4444),
      info: Color(0xFF3B82F6),
      shadow: Color(0x1F000000),
      overlay: Color(0x99000000),
      orderPending: Color(0xFFF59E0B),
      orderProcessing: Color(0xFF3B82F6),
      orderShipped: Color(0xFF8B5CF6),
      orderDelivered: Color(0xFF10B981),
      orderCancelled: Color(0xFFEF4444),
      orderCompleted: Color(0xFF10B981),
      stockInStock: Color(0xFF10B981),
      stockLowStock: Color(0xFFF59E0B),
      stockOutOfStock: Color(0xFFEF4444),
      audienceB2b: Color(0xFF3B82F6),
      audienceB2c: Color(0xFFFFAB40),
    );
  }

  /// Dark mode color scheme.
  factory AppColors.dark() {
    return const AppColors(
      primary: Color(0xFF00BFA5),
      primaryLight: Color(0xFF5DF2D6),
      primaryDark: Color(0xFF008E76),
      secondary: Color(0xFFFFAB40),
      background: Color(0xFF0F172A),
      surface: Color(0xFF1E293B),
      textPrimary: Color(0xFFF8FAFC),
      textSecondary: Color(0xFF94A3B8),
      textTertiary: Color(0xFF64748B),
      border: Color(0xFF334155),
      divider: Color(0xFF334155),
      success: Color(0xFF34D399),
      warning: Color(0xFFFCD34D),
      error: Color(0xFFF87171),
      info: Color(0xFF60A5FA),
      shadow: Color(0x66000000),
      overlay: Color(0xB3000000),
      orderPending: Color(0xFFFCD34D),
      orderProcessing: Color(0xFF60A5FA),
      orderShipped: Color(0xFFA78BFA),
      orderDelivered: Color(0xFF34D399),
      orderCancelled: Color(0xFFF87171),
      orderCompleted: Color(0xFF34D399),
      stockInStock: Color(0xFF34D399),
      stockLowStock: Color(0xFFFCD34D),
      stockOutOfStock: Color(0xFFF87171),
      audienceB2b: Color(0xFF60A5FA),
      audienceB2c: Color(0xFFFFAB40),
    );
  }
}

/// Provider that exposes the current [AppColors] based on the active theme mode.
final appColorsProvider = Provider<AppColors>((ref) {
  final isDark = ref.watch(settingsProvider).isDark;
  return isDark ? AppColors.dark() : AppColors.light();
});
