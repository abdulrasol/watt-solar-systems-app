
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_hub/src/features/settings/presentation/providers/settings_provider.dart';

/// Centralized color palette for the SolarHub application.
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
    );
  }
}

/// Provider that exposes the current [AppColors] based on the active theme mode.
final appColorsProvider = Provider<AppColors>((ref) {
  final isDark = ref.watch(settingsProvider).isDark;
  return isDark ? AppColors.dark() : AppColors.light();
});
