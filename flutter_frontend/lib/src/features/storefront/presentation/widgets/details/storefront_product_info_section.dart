import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:solar_hub/l10n/app_localizations.dart';

class StorefrontProductInfoSection extends StatelessWidget {
  final String companyName;
  final String? categoryLabel;
  final bool isAvailable;

  const StorefrontProductInfoSection({
    super.key,
    required this.companyName,
    required this.categoryLabel,
    required this.isAvailable,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: [
        _InfoChip(label: companyName),
        _InfoChip(label: isAvailable ? l10n.available : l10n.unavailable),
        if ((categoryLabel ?? '').isNotEmpty) _InfoChip(label: categoryLabel!),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;

  const _InfoChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Text(
        label,
        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12.sp),
      ),
    );
  }
}
