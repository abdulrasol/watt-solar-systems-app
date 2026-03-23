import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:icons_plus/icons_plus.dart';

import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/providers/company_dashboard_provider.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/widgets/dashboard_sidebar.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/screens/company_dashboard_page.dart';
import 'package:solar_hub/src/features/inventory/presentation/screens/inventory_page.dart';

// import 'package:solar_hub/layouts/company/analytics_page.dart';
// import 'package:solar_hub/layouts/company/inventory_page.dart';
// import 'package:solar_hub/features/accounting/screens/accounting_page.dart';
// import 'package:solar_hub/features/orders/screens/order_list_company.dart';
// import 'package:solar_hub/features/invoices/screens/invoices_page.dart';
// import 'package:solar_hub/layouts/company/requests/offer_requests_page.dart';
// import 'package:solar_hub/layouts/company/members/members_page.dart';
// import 'package:solar_hub/layouts/company/systems/systems_page.dart';
// import 'package:solar_hub/layouts/company/customer_list_page.dart';
// import 'package:solar_hub/features/suppliers/screens/suppliers_page.dart';
// import 'package:solar_hub/features/orders/screens/purchases_company.dart';
// import 'package:solar_hub/layouts/company/subscription/subscription_page.dart';
// import 'package:solar_hub/features/pos/screens/pos_page.dart';
// import 'package:solar_hub/features/store/screens/merchant/delivery_options_page.dart';
// import 'package:solar_hub/layouts/company/notifications/notifications_page.dart'; // Add when migrated

class CompanyDashboardLayout extends ConsumerWidget {
  const CompanyDashboardLayout({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 1024;
        final currentIndex = ref.watch(companyDashboardIndexProvider);
        final title = _getTitle(context, currentIndex);
        final canGoBack = ref.read(companyDashboardControllerProvider.notifier).canGoBack;

        return Scaffold(
          appBar: _buildAppBar(context, ref, showLeading: !isDesktop, title: title, canGoBack: canGoBack),
          drawer: isDesktop ? null : const Drawer(child: DashboardSidebar()),
          body: Row(
            children: [
              if (isDesktop) const DashboardSidebar(),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: KeyedSubtree(key: ValueKey(currentIndex), child: _getBody(currentIndex)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, WidgetRef ref, {required bool showLeading, required String title, required bool canGoBack}) {
    return AppBar(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      centerTitle: false,
      elevation: 0,
      backgroundColor: Theme.of(context).cardColor,
      foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
      leading: canGoBack
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => ref.read(companyDashboardControllerProvider.notifier).goBack(isSubscriptionActive: true /* replace */),
            )
          : (showLeading ? null : null), // null means it will use automaticallyImplyLeading if true
      automaticallyImplyLeading: !canGoBack && showLeading,
      actions: [_buildNotificationBadge(context, ref), const SizedBox(width: 16)],
    );
  }

  Widget _buildNotificationBadge(BuildContext context, WidgetRef ref) {
    // Replace with real notification count provider
    int count = 0;

    return Stack(
      children: [
        IconButton(
          onPressed: () {
            // context.push('/notifications');
          },
          icon: Icon(Iconsax.notification_bing_bold, color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.6)),
          tooltip: AppLocalizations.of(context)!.notifications,
        ),
        if (count > 0)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
              child: Text(
                count > 9 ? '+9' : '$count',
                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
          ),
      ],
    );
  }

  String _getTitle(BuildContext context, int index) {
    final l10n = AppLocalizations.of(context)!;
    switch (index) {
      case 0:
        return l10n.dashboard;
      case 1:
        return l10n.company_profile;
      case 2:
        return l10n.subscription;
      case 3:
        return l10n.offers;
      case 4:
        return l10n.inventory;
      case 5:
        return l10n.pos;
      case 6:
        return l10n.orders;
      case 7:
        return l10n.invoices;
      case 8:
        return l10n.accounting;
      case 9:
        return l10n.analytics;
      case 10:
        return l10n.members;
      case 11:
        return l10n.systems;
      case 12:
        return l10n.customers;
      case 13:
        return l10n.suppliers;
      case 14:
        return l10n.my_purchases;
      case 15:
        return l10n.delivery;
      default:
        return l10n.dashboard;
    }
  }

  Widget _getBody(int index) {
    // In a full implementation, these would be the Riverpod-based clean architecture pages.
    // For now we map to the existing pages where possible or placeholders.
    // We assume the company is always loaded when reaching this layout in this simplified version.

    // int? companyId = 1; // get from real provider

    switch (index) {
      case 0:
        return const CompanyDashboardPage();
      case 1:
        return const Center(child: Text("Profile Page Placeholder"));
      case 2:
        return const Center(child: Text("Subscription Placeholder"));
      case 3:
        return const Center(child: Text("Offer Requests Placeholder"));
      case 4:
        return const InventoryPage();
      case 5:
        return const Center(child: Text("POS Placeholder"));
      case 6:
        return const Center(child: Text("Orders Placeholder"));
      case 7:
        return const Center(child: Text("Invoices Placeholder"));
      case 8:
        return const Center(child: Text("Accounting Placeholder"));
      case 9:
        return const Center(child: Text("Analytics Placeholder"));
      case 10:
        return const Center(child: Text("Members Placeholder"));
      case 11:
        return const Center(child: Text("Systems Placeholder"));
      case 12:
        return const Center(child: Text("Customers Placeholder"));
      case 13:
        return const Center(child: Text("Suppliers Placeholder"));
      case 14:
        return const Center(child: Text("Purchases Placeholder"));
      case 15:
        return const Center(child: Text("Delivery Placeholder"));
      default:
        return const CompanyDashboardPage();
    }
  }
}
