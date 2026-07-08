import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_hub/src/core/theme/app_colors.dart';
import 'package:solar_hub/src/utils/app_theme.dart';

/// Reusable section title used on the company dashboard overview page.
class OverviewSectionTitle extends ConsumerWidget {
  final String title;
  final String subtitle;

  const OverviewSectionTitle({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(appColorsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 18, fontWeight: FontWeight.w800, color: colors.textPrimary),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, color: colors.textSecondary),
        ),
      ],
    );
  }
}
