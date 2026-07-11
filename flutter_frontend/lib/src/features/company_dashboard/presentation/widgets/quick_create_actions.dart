import 'package:watt/src/core/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:watt/l10n/app_localizations.dart';
import 'package:watt/src/features/company_dashboard/presentation/providers/summary_provider.dart';
import 'package:watt/src/utils/app_theme.dart';

class QuickAction {
  final IconData icon;
  final String label;
  final Color color;
  final String route;
  final bool enabled;

  const QuickAction({required this.icon, required this.label, required this.color, required this.route, this.enabled = true});
}

List<QuickAction> buildQuickActions(CompanySummaryState summaryState, AppLocalizations l10n) {
  final features = summaryState.summary?.allowedFeatures ?? [];
  final actions = <QuickAction>[];

  final hasStore = features.contains('store');
  final hasOffers = features.contains('offers');
  final hasContacts = features.contains('contacts');
  final hasAccounting = features.contains('accounting');
  final hasAds = features.contains('ads');
  final hasProjects = hasAds && summaryState.hasReadPermission('projects');

  if (hasStore) {
    actions.add(QuickAction(icon: Iconsax.box_add, label: l10n.add_product, color: Colors.blue, route: AppRoutes.companyInventoryAdd));
  }
  if (hasOffers) {
    actions.add(QuickAction(icon: Iconsax.document, label: l10n.create_offer, color: Colors.green, route: '/offers'));
  }
  if (hasContacts) {
    actions.add(QuickAction(icon: Iconsax.user_add, label: l10n.invite_member, color: Colors.orange, route: '/companies/dashboard/members'));
  }
  if (hasAccounting) {
    actions.add(QuickAction(icon: Iconsax.receipt_add, label: l10n.create_invoice, color: Colors.purple, route: '/companies/dashboard/accounting'));
  }
  if (hasProjects) {
    actions.add(QuickAction(icon: Iconsax.gallery_add, label: l10n.add_project, color: Colors.teal, route: '/company-work'));
  }

  if (actions.isEmpty) {
    actions.add(QuickAction(icon: Iconsax.box_add, label: l10n.add_product, color: Colors.blue, route: AppRoutes.companyInventoryAdd, enabled: false));
  }

  return actions;
}

void showQuickCreateSheet(BuildContext context, CompanySummaryState summaryState, AppLocalizations l10n) {
  final actions = buildQuickActions(summaryState, l10n);

  showModalBottomSheet(
    context: context,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (sheetContext) => Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Create',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, fontFamily: AppTheme.fontFamily),
          ),
          const SizedBox(height: 24),
          for (final action in actions)
            ListTile(
              onTap: action.enabled
                  ? () {
                      Navigator.pop(sheetContext);
                      context.push(action.route);
                    }
                  : null,
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: action.color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                child: Icon(action.icon, color: action.color, size: 22),
              ),
              title: Text(
                action.label,
                style: TextStyle(fontWeight: FontWeight.w600, fontFamily: AppTheme.fontFamily),
              ),
              trailing: const Icon(Icons.chevron_right, size: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
        ],
      ),
    ),
  );
}
