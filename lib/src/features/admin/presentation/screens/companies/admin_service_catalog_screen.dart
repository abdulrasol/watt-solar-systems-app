import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/src/core/widgets/loading_widgets.dart';
import 'package:solar_hub/src/features/admin/domain/models/service_catalog_item.dart';
import 'package:solar_hub/src/features/admin/presentation/controllers/admin_service_catalog_controller.dart';
import 'package:solar_hub/src/features/admin/presentation/forms/service_catalog_form.dart';
import 'package:solar_hub/src/features/admin/presentation/widgets/admin_widgets.dart';
import 'package:solar_hub/src/features/admin/presentation/widgets/service_catalog_item_card.dart';
import 'package:solar_hub/src/utils/app_theme.dart';

class AdminServiceCatalogScreen extends ConsumerStatefulWidget {
  const AdminServiceCatalogScreen({super.key});

  @override
  ConsumerState<AdminServiceCatalogScreen> createState() => _AdminServiceCatalogScreenState();
}

class _AdminServiceCatalogScreenState extends ConsumerState<AdminServiceCatalogScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(adminServiceCatalogProvider.notifier).fetchServiceCatalog());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminServiceCatalogProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Service Catalog',
          style: TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.bold, fontSize: 18.sp),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Iconsax.add_circle_bold, color: AppTheme.primaryColor, size: 24.sp),
            onPressed: () => _showServiceForm(context),
          ),
        ],
      ),
      body: state.isLoading && state.catalog.isEmpty
          ? _buildLoadingState()
          : RefreshIndicator(
              onRefresh: () => ref.read(adminServiceCatalogProvider.notifier).fetchServiceCatalog(),
              color: AppTheme.primaryColor,
              child: _buildContent(state),
            ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LoadingWidget.widget(context: context, size: 30),
          SizedBox(height: 16.h),
          Text(
            'Loading Catalog...',
            style: TextStyle(fontSize: 14.sp, color: Colors.grey, fontFamily: AppTheme.fontFamily),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(AdminServiceCatalogState state) {
    if (state.catalog.isEmpty && !state.isLoading) {
      return AdminEmptyState(icon: Iconsax.setting_2_bold, title: 'Empty Catalog', subtitle: 'Add services that companies can subscribe to.');
    }

    return ReorderableListView.builder(
      padding: EdgeInsets.all(20.w),
      itemCount: state.catalog.length,
      onReorder: (oldIndex, newIndex) {
        ref.read(adminServiceCatalogProvider.notifier).reorderCatalog(oldIndex, newIndex);
        // Note: In the future, this would call an API to sync updated sort_orders to the server
      },
      proxyDecorator: (child, index, animation) {
        return Material(elevation: 8, borderRadius: BorderRadius.circular(16.r), color: Colors.transparent, child: child);
      },
      itemBuilder: (context, index) {
        final item = state.catalog[index];
        return Padding(
          key: ValueKey(item.id),
          padding: EdgeInsets.only(bottom: 16.h),
          child: ServiceCatalogItemCard(
            item: item,
            index: index,
            onEdit: () => _showServiceForm(context, item: item),
            onDelete: () => _confirmDelete(context, item),
          ).animate().fadeIn(delay: (index * 50).ms).slideX(begin: 0.1, end: 0),
        );
      },
    );
  }

  void _showServiceForm(BuildContext context, {ServiceCatalogItem? item}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ServiceCatalogForm(
        item: item,
        onSubmit: (data) {
          if (item == null) {
            final newItem = ServiceCatalogItem(
              id: 0,
              code: data['code'],
              name: data['name'],
              description: data['description'],
              category: data['category'],
              isActive: data['is_active'],
              sortOrder: data['sort_order'],
              route: data['route'],
            );
            ref.read(adminServiceCatalogProvider.notifier).createServiceCatalogEntry(newItem);
          } else {
            ref.read(adminServiceCatalogProvider.notifier).updateServiceCatalogEntry(item.code, data);
          }
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, ServiceCatalogItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete Service?',
          style: TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to delete "${item.name}" from the catalog? This cannot be undone.',
          style: TextStyle(fontFamily: AppTheme.fontFamily),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              ref.read(adminServiceCatalogProvider.notifier).deleteServiceCatalogEntry(item.code);
              Navigator.pop(context);
            },
            child: const Text('DELETE', style: TextStyle(color: AppTheme.errorColor)),
          ),
        ],
      ),
    );
  }
}
