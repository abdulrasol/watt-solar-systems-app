import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/controllers/company_contacts_controller.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/providers/global_search_provider.dart';
import 'package:solar_hub/src/features/inventory/presentation/providers/inventory_provider.dart';
import 'package:solar_hub/src/features/offers/presentation/providers/offers_provider.dart';
import 'package:solar_hub/src/utils/app_theme.dart';

class SearchResultsContent extends ConsumerWidget {
  const SearchResultsContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchState = ref.watch(globalSearchProvider);

    return Container(
      padding: EdgeInsets.all(24.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Search results for: ',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  fontFamily: AppTheme.fontFamily,
                ),
              ),
              Text(
                '"${searchState.query}"',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primaryColor,
                  fontFamily: AppTheme.fontFamily,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () =>
                    ref.read(globalSearchProvider.notifier).clear(),
                icon: const Icon(Icons.close, size: 18),
                label: const Text('Clear'),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          Expanded(
            child: _buildRealResults(context, ref),
          ),
        ],
      ),
    );
  }

  Widget _buildRealResults(BuildContext context, WidgetRef ref) {
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
            Icon(Iconsax.search_normal_1_bold, size: 64.r, color: Colors.grey.withValues(alpha: 0.3)),
            SizedBox(height: 16.h),
            Text(
              'No results found',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView(
      children: [
        if (products.isNotEmpty) ...[
          _buildSectionHeader(context, 'Inventory'),
          ...products.map((p) => _buildResultTile(
            context,
            icon: Iconsax.box_bold,
            title: p.name,
            subtitle: 'SKU: ${p.sku ?? "N/A"} • Stock: ${p.stockQuantity}',
            onTap: () {}, // Navigate to product details
          )),
          SizedBox(height: 16.h),
        ],
        if (requests.isNotEmpty) ...[
          _buildSectionHeader(context, 'Marketplace Requests'),
          ...requests.map((r) => _buildResultTile(
            context,
            icon: Iconsax.receipt_2_bold,
            title: r.note ?? 'Solar Request #${r.id}',
            subtitle: 'City: ${r.city?.name ?? "N/A"} • Status: ${r.status}',
            onTap: () {}, // Navigate to request details
          )),
          SizedBox(height: 16.h),
        ],
        if (contacts.isNotEmpty) ...[
          _buildSectionHeader(context, 'Contacts'),
          ...contacts.map((c) => _buildResultTile(
            context,
            icon: Iconsax.user_bold,
            title: c.name,
            subtitle: c.email ?? c.phone ?? 'No contact info',
            onTap: () {}, // Navigate to contact details
          )),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w800,
          color: Colors.grey,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildResultTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8.r),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Icon(icon, color: AppTheme.primaryColor, size: 20.sp),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontFamily: AppTheme.fontFamily,
        ),
      ),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
