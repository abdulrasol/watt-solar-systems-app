import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/widgets/company_management_widgets.dart';
import 'package:solar_hub/src/shared/widgets/shared_widgets.dart';

/// Header shown at the top of the embedded company works list,
/// containing the section title/subtitle and the add action.
class CompanyWorkPageHeader extends StatelessWidget {
  const CompanyWorkPageHeader({
    super.key,
    required this.hasWritePermission,
    this.onAddRoute = '/companies/dashboard/content/works/add',
  });

  final bool hasWritePermission;
  final String onAddRoute;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return CompanySectionIntro(
      title: l10n.company_work_title,
      subtitle: l10n.company_work_subtitle,
      action: hasWritePermission
          ? AppButton(
              text: l10n.company_work_add,
              icon: Iconsax.add_circle,
              onPressed: () => context.push(onAddRoute),
            )
          : const SizedBox.shrink(),
    );
  }
}
