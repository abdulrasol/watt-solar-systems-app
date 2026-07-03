import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/providers/summary_provider.dart';
import 'package:solar_hub/src/utils/app_theme.dart';

class QuickAction {
  final IconData icon;
  final String label;
  final Color color;
  final String route;
  final bool enabled;

  const QuickAction({required this.icon, required this.label, required this.color, required this.route, this.enabled = true});
}

List<QuickAction> buildQuickActions(CompanySummaryState summaryState, AppLocalizations l10n) {
  final services = [...?summaryState.summary?.services];
  final actions = <QuickAction>[];

  final hasInventory = services.any((s) => s.serviceCode == 'inventory' && s.isActive);
  final hasOffers = services.any((s) => s.serviceCode == 'offers' && s.isActive);
  final hasMembers = services.any((s) => s.serviceCode == 'multi_member' && s.isActive);
  final hasStorefrontB2C = services.any((s) => s.serviceCode == 'storefront_b2c' && s.isActive);
  final hasAccounting = services.any((s) => s.serviceCode == 'accounting' && s.isActive);
  final hasStorefrontB2B = services.any((s) => s.serviceCode == 'storefront_b2b' && s.isActive);
  final hasProjects = services.any((s) => s.serviceCode == 'company_work' && s.isActive) && summaryState.hasReadPermission('projects');

  if (hasInventory) {
    actions.add(QuickAction(icon: Iconsax.box_add, label: l10n.add_product, color: Colors.blue, route: '/inventory/add'));
  }
  if (hasOffers) {
    actions.add(QuickAction(icon: Iconsax.document, label: l10n.create_offer, color: Colors.green, route: '/offers'));
  }
  if (hasMembers) {
    actions.add(QuickAction(icon: Iconsax.user_add, label: l10n.invite_member, color: Colors.orange, route: '/companies/dashboard/members'));
  }
  if (hasStorefrontB2C || hasStorefrontB2B) {
    actions.add(QuickAction(icon: Iconsax.shop_add, label: l10n.add_product, color: Colors.pink, route: '/inventory/add'));
  }
  if (hasAccounting) {
    actions.add(QuickAction(icon: Iconsax.receipt_add, label: l10n.create_invoice, color: Colors.purple, route: '/companies/dashboard/accounting'));
  }
  if (hasProjects) {
    actions.add(QuickAction(icon: Iconsax.gallery_add, label: l10n.add_project, color: Colors.teal, route: '/company-work'));
  }

  if (actions.isEmpty) {
    actions.add(QuickAction(icon: Iconsax.box_add, label: l10n.add_product, color: Colors.blue, route: '/inventory/add', enabled: false));
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
