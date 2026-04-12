import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/core/layout/app_breakpoints.dart';
import 'package:solar_hub/src/core/widgets/wd_image_preview.dart';
import 'package:solar_hub/src/shared/domain/company/company.dart';
import 'package:solar_hub/src/utils/app_theme.dart';

class CompanyWorkspaceHeaderCard extends StatelessWidget {
  const CompanyWorkspaceHeaderCard({
    super.key,
    required this.company,
    this.onEditPressed,
  });

  final Company company;
  final VoidCallback? onEditPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isMobile = AppBreakpoints.isMobile(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(isMobile ? 18 : 24),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.12 : 0.05),
            blurRadius: 20,
            offset: const Offset(0, 12),
          ),
        ],
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).cardColor,
            AppTheme.primaryColor.withValues(alpha: 0.06),
          ],
        ),
      ),
      child: Flex(
        direction: isMobile ? Axis.vertical : Axis.horizontal,
        crossAxisAlignment: isMobile
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          WdImagePreview(
            imageUrl: company.logo ?? '',
            size: isMobile ? 72 : 50,
          ),
          SizedBox(width: isMobile ? 0 : 20, height: isMobile ? 16 : 0),
          Expanded(
            flex: isMobile ? 0 : 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    SizedBox(
                      width: isMobile ? null : 460,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            company.name,
                            style: TextStyle(
                              fontFamily: AppTheme.fontFamily,
                              fontSize: isMobile ? 20 : 26,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          if (!isMobile) ...[
                            const SizedBox(height: 8),
                            infoChips(l10n),
                          ],
                        ],
                      ),
                    ),
                    if (onEditPressed != null)
                      FilledButton.icon(
                        onPressed: onEditPressed,
                        icon: const Icon(Iconsax.edit_2_bold),
                        label: Text(l10n.edit_company),
                      ),
                  ],
                ),
                if (isMobile) ...[const SizedBox(height: 8), infoChips(l10n)],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Wrap infoChips(AppLocalizations l10n) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (!company.requiresActivationAttention && company.isActive)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Iconsax.verify_bold, size: 14, color: Colors.green),
                SizedBox(width: 6),
                Text(
                  'Active',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        if (company.requiresActivationAttention)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Iconsax.warning_2_bold,
                  size: 14,
                  color: Colors.orange,
                ),
                const SizedBox(width: 6),
                Text(
                  l10n.company_activation_required_short,
                  style: const TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        _InfoChip(
          icon: Iconsax.building_bold,
          label: company.type ?? l10n.company,
          color: Colors.blue,
        ),
        _InfoChip(
          icon: Iconsax.crown_bold,
          label: company.tier ?? l10n.standard,
          color: Colors.orange,
        ),
        if ((company.city?.name ?? '').isNotEmpty)
          _InfoChip(
            icon: Iconsax.location_bold,
            label: company.city!.name,
            color: AppTheme.primaryColor,
          ),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
