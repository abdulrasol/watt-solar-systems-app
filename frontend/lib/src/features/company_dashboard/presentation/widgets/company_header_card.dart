import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/core/layout/app_breakpoints.dart';
import 'package:solar_hub/src/core/widgets/wd_image_preview.dart';
import 'package:solar_hub/src/shared/domain/company/company.dart';
import 'package:solar_hub/src/utils/app_theme.dart';

class CompanyHeaderCard extends StatelessWidget {
  final Company company;

  const CompanyHeaderCard({super.key, required this.company});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isMobile = AppBreakpoints.isMobile(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: AppTheme.primaryColor.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 10))],
        gradient: LinearGradient(
          colors: [Theme.of(context).cardColor, AppTheme.primaryColor.withValues(alpha: 0.03)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Flex(
        direction: isMobile ? Axis.vertical : Axis.horizontal,
        crossAxisAlignment: isMobile ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          WdImagePreview(imageUrl: company.logo ?? '', size: 80, shape: BoxShape.circle),
          SizedBox(width: isMobile ? 0 : 20, height: isMobile ? 16 : 0),
          if (isMobile)
            _buildDetails(context, l10n, crossAxisAlignment: CrossAxisAlignment.start)
          else
            Expanded(child: _buildDetails(context, l10n, crossAxisAlignment: CrossAxisAlignment.start)),
        ],
      ),
    );
  }

  Widget _buildDetails(BuildContext context, AppLocalizations l10n, {required CrossAxisAlignment crossAxisAlignment}) {
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                company.name,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, fontFamily: AppTheme.fontFamily),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: 8),
            if (company.status.toLowerCase() == 'active') Icon(Iconsax.verify, color: Colors.blue, size: 20),
          ],
        ),
        SizedBox(height: 4),
        Text(
          company.description ?? l10n.solar_solutions_provider,
          style: TextStyle(fontSize: 13, color: Colors.grey, fontFamily: AppTheme.fontFamily),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildChip(context, label: company.tier ?? l10n.standard, icon: Iconsax.crown, color: Colors.orange),
            _buildChip(context, label: company.type ?? l10n.company, icon: Iconsax.building, color: Colors.blue),
          ],
        ),
      ],
    );
  }

  Widget _buildChip(BuildContext context, {required String label, required IconData icon, required Color color}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.bold, fontFamily: AppTheme.fontFamily),
          ),
        ],
      ),
    );
  }
}
