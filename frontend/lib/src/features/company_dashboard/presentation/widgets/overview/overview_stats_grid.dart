import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/widgets/company_workspace_stat_card.dart';

/// Responsive stats grid displayed on the company dashboard overview page.
class OverviewStatsGrid extends StatelessWidget {
  final dynamic summary;

  const OverviewStatsGrid({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = width >= 1180 ? 5 : width >= 760 ? 3 : 2;

        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: columns,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: columns == 2 ? 1 : 1.5,
          children: [
            CompanyWorkspaceStatCard(title: l10n.members, value: '${summary?.members ?? 0}', icon: Iconsax.people, color: Colors.blue),
            CompanyWorkspaceStatCard(title: l10n.orders, value: '${summary?.orders ?? 0}', icon: Iconsax.shopping_cart, color: Colors.green),
            CompanyWorkspaceStatCard(title: l10n.offers, value: '${summary?.offers ?? 0}', icon: Iconsax.document, color: Colors.orange),
            CompanyWorkspaceStatCard(title: l10n.contacts, value: '${summary?.contactsCount ?? 0}', icon: Iconsax.call, color: Colors.purple),
          ],
        );
      },
    );
  }
}
