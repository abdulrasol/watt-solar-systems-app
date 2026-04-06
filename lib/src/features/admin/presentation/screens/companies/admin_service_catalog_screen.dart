import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/src/core/widgets/loading_widgets.dart';
import 'package:solar_hub/src/core/widgets/pre_scaffold.dart';
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

    return PreScaffold(
      title: 'Service Catalog',
      actions: [
        IconButton(
          icon: Icon(Iconsax.add_circle_bold, color: AppTheme.primaryColor, size: 26.sp),
          onPressed: () => _showServiceForm(context),
          tooltip: 'Add Service',
        ),
      ],
      child: state.isLoading && state.catalog.isEmpty
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
      return AdminEmptyState(icon: Icons.settings_outlined, title: 'Empty Catalog', subtitle: 'Add services that companies can subscribe to.');
    }

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: Row(
            children: [
              Icon(Icons.info_outline, size: 16.sp, color: AppTheme.primaryColor),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  'Drag to reorder services',
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey, fontFamily: AppTheme.fontFamily),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ReorderableListView.builder(
            padding: EdgeInsets.all(16.w),
            itemCount: state.catalog.length,
            onReorder: (oldIndex, newIndex) {
              ref.read(adminServiceCatalogProvider.notifier).reorderCatalog(oldIndex, newIndex);
            },
            onReorderEnd: (index) {
              ref.read(adminServiceCatalogProvider.notifier).syncCatalogOrder();
            },
            proxyDecorator: (child, index, animation) {
              return Material(elevation: 8, borderRadius: BorderRadius.circular(16.r), color: Colors.transparent, child: child);
            },
            itemBuilder: (context, index) {
              final item = state.catalog[index];
              return Padding(
                key: ValueKey(item.code),
                padding: EdgeInsets.only(bottom: 12.h),
                child: ServiceCatalogItemCard(
                  item: item,
                  index: index,
                  onEdit: () => _showServiceForm(context, item: item),
                  onDelete: () => _confirmDelete(context, item),
                  onToggleActive: () => _toggleActive(context, item),
                ).animate().fadeIn(delay: (index * 50).ms).slideX(begin: 0.1, end: 0),
              );
            },
          ),
        ),
      ],
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
              sortOrder: data['sort_order'] ?? 0,
              route: data['route'],
            );
            ref.read(adminServiceCatalogProvider.notifier).createServiceCatalogEntry(newItem);
          } else {
            ref.read(adminServiceCatalogProvider.notifier).updateServiceCatalogEntry(item.code, data);
          }
          Navigator.pop(context);
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, ServiceCatalogItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Text(
          'Delete Service?',
          style: TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to delete "${item.name}" from the catalog? This action cannot be undone.',
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
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${item.name} deleted successfully'), backgroundColor: AppTheme.errorColor, behavior: SnackBarBehavior.floating),
              );
            },
            child: const Text('DELETE', style: TextStyle(color: AppTheme.errorColor)),
          ),
        ],
      ),
    );
  }

  void _toggleActive(BuildContext context, ServiceCatalogItem item) {
    final notifier = ref.read(adminServiceCatalogProvider.notifier);
    notifier.updateServiceCatalogEntry(item.code, {'is_active': !item.isActive});

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item.name} ${item.isActive ? 'deactivated' : 'activated'}'),
        backgroundColor: AppTheme.primaryColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
