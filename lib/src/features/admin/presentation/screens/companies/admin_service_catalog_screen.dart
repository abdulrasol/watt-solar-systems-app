import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/src/features/admin/domain/models/service_catalog_item.dart';
import 'package:solar_hub/src/features/admin/presentation/controllers/admin_service_catalog_controller.dart';
import 'package:solar_hub/src/features/admin/presentation/forms/service_catalog_form.dart';
import 'package:solar_hub/src/features/admin/presentation/widgets/admin_page_scaffold.dart';
import 'package:solar_hub/src/features/admin/presentation/widgets/admin_widgets.dart';
import 'package:solar_hub/src/features/admin/presentation/widgets/service_catalog_item_card.dart';
import 'package:solar_hub/src/utils/app_theme.dart';

class AdminServiceCatalogScreen extends ConsumerStatefulWidget {
  const AdminServiceCatalogScreen({super.key});

  @override
  ConsumerState<AdminServiceCatalogScreen> createState() =>
      _AdminServiceCatalogScreenState();
}

class _AdminServiceCatalogScreenState
    extends ConsumerState<AdminServiceCatalogScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(adminServiceCatalogProvider.notifier).fetchServiceCatalog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminServiceCatalogProvider);

    return AdminPageScaffold(
      // title: 'Service Catalog',
      // subtitle: 'Catalog entries load only after this route opens.',
      actions: [
        FilledButton.icon(
          onPressed: () => _showServiceForm(context),
          icon: const Icon(Iconsax.add_circle_bold),
          label: const Text('Add Service'),
        ),
      ],
      child: state.isLoading && state.catalog.isEmpty
          ? const AdminLoadingState(
              icon: Iconsax.category_2_bold,
              message: 'Loading service catalog...',
            )
          : _buildContent(context, state),
    );
  }

  Widget _buildContent(
    BuildContext context,
    AdminServiceCatalogState state,
  ) {
    if (state.error != null && state.catalog.isEmpty) {
      return AdminErrorState(
        error: state.error!,
        onRetry: () =>
            ref.read(adminServiceCatalogProvider.notifier).fetchServiceCatalog(),
      );
    }

    if (state.catalog.isEmpty) {
      return const AdminEmptyState(
        icon: Iconsax.category_2_bold,
        title: 'Catalog is empty',
        subtitle: 'Add services that companies can request.',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              const Icon(Iconsax.info_circle_bold, color: AppTheme.primaryColor),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Drag items to reorder the catalog. Order syncs after the drag ends.',
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 13,
                    color: Theme.of(context).hintColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () =>
                ref.read(adminServiceCatalogProvider.notifier).fetchServiceCatalog(),
            child: ReorderableListView.builder(
              itemCount: state.catalog.length,
              onReorder: (oldIndex, newIndex) {
                ref
                    .read(adminServiceCatalogProvider.notifier)
                    .reorderCatalog(oldIndex, newIndex);
              },
              onReorderEnd: (_) {
                ref.read(adminServiceCatalogProvider.notifier).syncCatalogOrder();
              },
              itemBuilder: (context, index) {
                final item = state.catalog[index];
                return Padding(
                  key: ValueKey(item.code),
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ServiceCatalogItemCard(
                    item: item,
                    index: index,
                    onEdit: () => _showServiceForm(context, item: item),
                    onDelete: () => _confirmDelete(context, item),
                    onToggleActive: () => _toggleActive(item),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  void _showServiceForm(BuildContext context, {ServiceCatalogItem? item}) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ServiceCatalogForm(
        item: item,
        onSubmit: (data) {
          if (item == null) {
            ref.read(adminServiceCatalogProvider.notifier).createServiceCatalogEntry(
                  ServiceCatalogItem(
                    id: 0,
                    code: data['code'] as String,
                    name: data['name'] as String,
                    description: data['description'] as String?,
                    category: data['category'] as String?,
                    isActive: data['is_active'] as bool,
                    sortOrder: (data['sort_order'] as int?) ?? 0,
                    route: data['route'] as String?,
                  ),
                );
          } else {
            ref
                .read(adminServiceCatalogProvider.notifier)
                .updateServiceCatalogEntry(item.code, data);
          }
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, ServiceCatalogItem item) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete service?'),
        content: Text('Delete "${item.name}" from the catalog?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref
                  .read(adminServiceCatalogProvider.notifier)
                  .deleteServiceCatalogEntry(item.code);
              Navigator.pop(context);
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: AppTheme.errorColor),
            ),
          ),
        ],
      ),
    );
  }

  void _toggleActive(ServiceCatalogItem item) {
    ref.read(adminServiceCatalogProvider.notifier).updateServiceCatalogEntry(
      item.code,
      {'is_active': !item.isActive},
    );
  }
}
