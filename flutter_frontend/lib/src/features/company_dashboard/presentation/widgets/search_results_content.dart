import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:watt/l10n/app_localizations.dart';
import 'package:watt/src/features/company_dashboard/presentation/controllers/company_contacts_controller.dart';
import 'package:watt/src/features/company_dashboard/presentation/providers/global_search_provider.dart';
import 'package:watt/src/features/inventory/presentation/providers/inventory_provider.dart';
import 'package:watt/src/features/offers/presentation/providers/offers_provider.dart';
import 'package:watt/src/utils/app_theme.dart';

class SearchResultsContent extends ConsumerWidget {
  const SearchResultsContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final searchState = ref.watch(globalSearchProvider);

    return Container(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                l10n.search_results_for,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, fontFamily: AppTheme.fontFamily),
              ),
              Text(
                '"${searchState.query}"',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.primaryColor, fontFamily: AppTheme.fontFamily),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () => ref.read(globalSearchProvider.notifier).clear(),
                icon: const Icon(Icons.close, size: 18),
                label: Text(l10n.clear),
              ),
            ],
          ),
          SizedBox(height: 24),
          Expanded(child: _buildRealResults(context, ref, l10n)),
        ],
      ),
    );
  }

  Widget _buildRealResults(BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    final inventoryState = ref.watch(inventoryNotifierProvider);
    final offersState = ref.watch(offersProvider);
    final contactsState = ref.watch(companyContactsProvider);

    final isLoading = inventoryState.isLoading || offersState.isLoading || contactsState.isLoading;

    if (isLoading && inventoryState.products.isEmpty && offersState.availableRequests.isEmpty && contactsState.contacts.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final products = inventoryState.products;
    final requests = offersState.availableRequests;
    final contacts = contactsState.contacts;

    if (products.isEmpty && requests.isEmpty && contacts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Iconsax.search_normal_1, size: 64, color: Colors.grey.withValues(alpha: 0.3)),
            SizedBox(height: 16),
            Text(
              l10n.no_results_found,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView(
      children: [
        if (products.isNotEmpty) ...[
          _buildSectionHeader(context, l10n.inventory),
          ...products.map(
            (p) => _buildResultTile(
              context,
              icon: Iconsax.box,
              title: p.name,
              subtitle: 'SKU: ${p.sku ?? "N/A"} • Stock: ${p.stockQuantity}',
              onTap: () => context.push('/inventory'),
            ),
          ),
            SizedBox(height: 16),
        ],
        if (requests.isNotEmpty) ...[
          _buildSectionHeader(context, l10n.marketplace_requests),
          ...requests.map(
            (r) => _buildResultTile(
              context,
              icon: Iconsax.receipt_2,
              title: r.note ?? 'Solar Request #${r.id}',
              subtitle: 'City: ${r.city?.name ?? "N/A"} • Status: ${r.status}',
              onTap: () => context.push('/offers'),
            ),
          ),
          SizedBox(height: 16),
        ],
        if (contacts.isNotEmpty) ...[
          _buildSectionHeader(context, l10n.contacts),
          ...contacts.map(
            (c) => _buildResultTile(
              context,
              icon: Iconsax.user,
              title: c.name,
              subtitle: c.email ?? c.phone ?? l10n.no_contact_info,
              onTap: () => context.push('/companies/dashboard/contacts'),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.grey, letterSpacing: 1.2),
      ),
    );
  }

  Widget _buildResultTile(BuildContext context, {required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(color: AppTheme.primaryColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: AppTheme.primaryColor, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.bold, fontFamily: AppTheme.fontFamily),
      ),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
