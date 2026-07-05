import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:solar_hub/src/core/theme/app_colors.dart';
import 'package:solar_hub/src/utils/app_theme.dart';

/// A reusable search bar widget used across list screens.
class AppSearchBar extends ConsumerWidget {
  final TextEditingController? controller;
  final String hint;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;
  final bool autofocus;

  const AppSearchBar({
    super.key,
    this.controller,
    this.hint = 'بحث...',
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(appColorsProvider);

    return TextField(
      controller: controller,
      autofocus: autofocus,
      textDirection: TextDirection.rtl,
      textAlign: TextAlign.right,
      style: TextStyle(
        fontFamily: AppTheme.fontFamily,
        fontSize: 14,
        color: colors.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          fontFamily: AppTheme.fontFamily,
          fontSize: 14,
          color: colors.textTertiary,
        ),
        prefixIcon: Icon(Iconsax.search_normal, color: colors.textTertiary, size: 20),
        suffixIcon: ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller ?? TextEditingController(),
          builder: (context, value, child) {
            if (value.text.isEmpty) return const SizedBox.shrink();
            return IconButton(
              icon: Icon(Iconsax.close_circle, color: colors.textTertiary, size: 20),
              onPressed: () {
                (controller ?? TextEditingController()).clear();
                onChanged?.call('');
                onClear?.call();
              },
            );
          },
        ),
        filled: true,
        fillColor: colors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.primary, width: 1.5),
        ),
      ),
      onChanged: onChanged,
      onSubmitted: onSubmitted,
    );
  }
}
