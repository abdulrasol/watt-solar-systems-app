import 'package:watt/src/core/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:watt/l10n/app_localizations.dart';
import 'package:watt/src/core/widgets/pre_scaffold.dart';
import 'package:watt/src/features/inventory/presentation/providers/inventory_provider.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:watt/src/core/widgets/branded_empty_state.dart';
import 'package:watt/src/utils/app_theme.dart';
import 'package:watt/src/features/inventory/presentation/widgets/product_card.dart';
import 'package:watt/src/features/inventory/presentation/widgets/inventory_search_bar.dart';
import 'package:watt/src/features/inventory/presentation/widgets/inventory_filter_sheet.dart';

class InventoryPage extends ConsumerStatefulWidget {
  final bool embedded;
  const InventoryPage({super.key, this.embedded = false});

  @override
  ConsumerState<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends ConsumerState<InventoryPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      final state = ref.read(inventoryNotifierProvider);
      if (!state.isLoading && !state.isMoreLoading && state.hasMore) {
        ref.read(inventoryNotifierProvider.notifier).nextPage();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final inventoryState = ref.watch(inventoryNotifierProvider);
    final l10n = AppLocalizations.of(context)!;

    final content = Column(
      children: [
        const InventorySearchBar(),
        Expanded(
          child: inventoryState.isLoading && inventoryState.products.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : inventoryState.products.isEmpty
              ? _buildEmptyState(l10n)
              : RefreshIndicator(
                  onRefresh: () => ref.read(inventoryNotifierProvider.notifier).fetchProducts(isRefresh: true),
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    itemCount: inventoryState.products.length + (inventoryState.hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == inventoryState.products.length) {
                        return const Center(
                          child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()),
                        );
                      }
                      return ProductCard(product: inventoryState.products[index]);
                    },
                  ),
                ),
        ),
      ],
    );

    if (widget.embedded) {
      return content;
    }

    return PreScaffold(
      title: l10n.inventory,
      actions: [IconButton(icon: const Icon(Icons.add), onPressed: () => context.push(AppRoutes.companyInventoryAdd))],
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(context: context, isScrollControlled: true, useSafeArea: true, builder: (context) => const InventoryFilterSheet());
        },
        child: const Icon(Icons.tune),
      ),
      child: content,
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return BrandedEmptyState(
      icon: Iconsax.box,
      title: l10n.noProducts,
      subtitle: 'Start adding products to your inventory to manage stock.',
      action: ElevatedButton.icon(
        onPressed: () => context.push(AppRoutes.companyInventoryAdd),
        icon: const Icon(Iconsax.add, color: Colors.white),
        label: const Text('Add Product', style: TextStyle(color: Colors.white)),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        ),
      ),
    );
  }
}
