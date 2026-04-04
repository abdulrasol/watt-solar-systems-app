import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/core/widgets/pre_scaffold.dart';
import 'package:solar_hub/src/features/inventory/presentation/providers/inventory_provider.dart';
import 'package:solar_hub/src/features/inventory/presentation/widgets/product_card.dart';
import 'package:solar_hub/src/utils/app_theme.dart';

class InventoryPage extends ConsumerStatefulWidget {
  const InventoryPage({super.key});

  @override
  ConsumerState<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends ConsumerState<InventoryPage> {
  late InventoryState inventoryState;
  final ScrollController _scrollController = ScrollController();
  late GlobalKey<RefreshIndicatorState> keyRefreshIndicator;
  final TextEditingController _searchController = TextEditingController();
  late final Timer _debounce;

  @override
  void initState() {
    super.initState();
    keyRefreshIndicator = GlobalKey<RefreshIndicatorState>();
    if (keyRefreshIndicator.currentState != null) {
      keyRefreshIndicator.currentState!.show();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.addListener(() {
        if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
          final state = ref.read(inventoryNotifierProvider);
          if (!state.isLoading && !state.isMoreLoading && state.hasMore) {
            ref.read(inventoryNotifierProvider.notifier).nextPage();
          }
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    inventoryState = ref.watch(inventoryNotifierProvider);
    final l10n = AppLocalizations.of(context)!;

    return PreScaffold(
      title: l10n.inventory,
      actions: [
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () {
            context.push('/inventory/add');
          },
        ),
      ],
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // context.push('/inventory/add');
        },
        child: const Icon(Icons.filter),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: l10n.search,
                prefixIcon: const Icon(IonIcons.search, color: AppTheme.primaryDarkColor),
                suffixIcon: ref.watch(inventoryNotifierProvider).filter.search?.isNotEmpty ?? true
                    ? IconButton(
                        icon: const Icon(IonIcons.close_circle),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(inventoryNotifierProvider.notifier).search('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (val) {
                ref.read(inventoryNotifierProvider.notifier).search(_searchController.text);
              },
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: []),
          ),
          inventoryState.products.isEmpty
              ? Expanded(child: wdEmpty())
              : Expanded(
                  child: RefreshIndicator(
                    key: keyRefreshIndicator,
                    onRefresh: () async {
                      await ref.read(inventoryNotifierProvider.notifier).fetchProducts(isRefresh: true);
                    },
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: EdgeInsets.all(16.r),
                      itemCount: inventoryState.products.length,
                      itemBuilder: (context, index) {
                        final product = inventoryState.products[index];

                        return ProdcutCard(product: product);
                      },
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget wdEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          Text('No products found', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Add products to your inventory to get started', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:go_router/go_router.dart';
// import 'package:solar_hub/l10n/app_localizations.dart';
// import 'package:solar_hub/src/utils/app_strings.dart';
// import 'package:solar_hub/src/features/company_dashboard/presentation/providers/dashboard_data_provider.dart';
// import '../providers/inventory_provider.dart';
// // import '../../../../utils/price_format_utils.dart'; // We can safely assume or implement our own extension below if missing.

// class InventoryPage extends ConsumerStatefulWidget {
//   const InventoryPage({super.key});

//   @override
//   ConsumerState<InventoryPage> createState() => _InventoryPageState();
// }

// class _InventoryPageState extends ConsumerState<InventoryPage> {
//   final ScrollController _scrollController = ScrollController();
//   final TextEditingController _searchController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     _scrollController.addListener(_onScroll);
//   }

//   @override
//   void dispose() {
//     _scrollController.dispose();
//     _searchController.dispose();
//     super.dispose();
//   }

//   void _onScroll() {
//     if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
//       final state = ref.read(inventoryNotifierProvider);
//       if (!state.isLoading && !state.isMoreLoading && state.hasMore) {
//         ref.read(inventoryNotifierProvider.notifier).fetchProducts();
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final state = ref.watch(inventoryNotifierProvider);
//

//     // Check role permissions:
//     final dashboardAsync = ref.watch(dashboardDataProvider);
//     final String role = dashboardAsync.value?.role ?? '';
//     final Map<String, String> permissions = dashboardAsync.value?.permissions ?? {};

//     bool canAddProduct = false;
//     if (role == AppStrings.owner || role == 'admin') {
//       canAddProduct = true;
//     } else {
//       canAddProduct = permissions[AppStrings.inventoryPermission] == AppStrings.writePremeission;
//     }

//     return Scaffold(
//       floatingActionButton: canAddProduct
//           ? FloatingActionButton(
//               onPressed: () => context.push('/company-dashboard/inventory/add'),
//               backgroundColor: Theme.of(context).primaryColor,
//               child: const Icon(Icons.add, color: Colors.white),
//             )
//           : null,
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
//             child: Column(
//               children: [
//                 TextField(
//                   controller: _searchController,
//                   decoration: InputDecoration(
//                     hintText: 'Search products...',
//                     prefixIcon: const Icon(Icons.search),
//                     suffixIcon: ref.watch(inventorySearchProvider).isNotEmpty
//                         ? IconButton(
//                             icon: const Icon(Icons.clear),
//                             onPressed: () {
//                               _searchController.clear();
//                               ref.read(inventorySearchProvider.notifier).state = '';
//                             },
//                           )
//                         : null,
//                     border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//                     contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                   ),
//                   onChanged: (val) {
//                     ref.read(inventorySearchProvider.notifier).state = val;
//                   },
//                 ),
//                 const SizedBox(height: 8),
//                 SingleChildScrollView(
//                   scrollDirection: Axis.horizontal,
//                   child: Row(
//                     children: StockFilter.values.map((filter) {
//                       return Padding(
//                         padding: const EdgeInsets.only(right: 8),
//                         child: Consumer(
//                           builder: (context, ref, child) {
//                             final currentFilter = ref.watch(stockFilterProvider);
//                             final isSelected = currentFilter == filter;
//                             return ChoiceChip(
//                               label: Text(_getFilterName(filter, l10n)),
//                               selected: isSelected,
//                               onSelected: (selected) {
//                                 if (selected) {
//                                   ref.read(stockFilterProvider.notifier).state = filter;
//                                 }
//                               },
//                             );
//                           },
//                         ),
//                       );
//                     }).toList(),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Expanded(
//             child: Builder(
//               builder: (context) {
//                 if (state.isLoading && state.products.isEmpty) {
//                   return const Center(child: CircularProgressIndicator());
//                 }

//                 if (state.products.isEmpty && !state.isLoading) {
//                   return Center(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         const Icon(FontAwesomeIcons.boxesStacked, size: 64, color: Colors.grey),
//                         const SizedBox(height: 16),
//                         Text(l10n.no_products_in_stock, style: const TextStyle(fontSize: 16)),
//                         const SizedBox(height: 16),
//                         if (canAddProduct)
//                           ElevatedButton.icon(
//                             icon: const Icon(Icons.add),
//                             label: const Text('Add Product'),
//                             onPressed: () => context.push('/company-dashboard/inventory/add'),
//                           ),
//                       ],
//                     ),
//                   );
//                 }

//                 return ListView.separated(
//                   controller: _scrollController,
//                   padding: const EdgeInsets.all(16),
//                   itemCount: state.products.length + (state.isMoreLoading ? 1 : 0),
//                   separatorBuilder: (context, index) => const SizedBox(height: 12),
//                   itemBuilder: (context, index) {
//                     if (index == state.products.length) {
//                       return const Center(
//                         child: Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator()),
//                       );
//                     }

//                     final product = state.products[index];
//                     final bool isOutOfStock = product.stockQuantity == 0;
//                     final bool isLowStock = product.stockQuantity <= product.minStockAlert && product.stockQuantity > 0;

//                     Color statusColor = Colors.green;
//                     String statusText = 'In Stock';
//                     // String statusText = l10n.in_stock;
//                     if (isOutOfStock) {
//                       statusColor = Colors.red;
//                       statusText = 'Out of Stock';
//                     } else if (isLowStock) {
//                       statusColor = Colors.orange;
//                       statusText = 'Low Stock';
//                     }

//                     return Card(
//                       elevation: 2,
//                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                       clipBehavior: Clip.antiAlias,
//                       child: InkWell(
//                         onTap: () {
//                           // TODO: Route to product details
//                           context.push('/company-dashboard/inventory/product/${product.id}', extra: product);
//                         },
//                         child: Padding(
//                           padding: const EdgeInsets.all(12),
//                           child: Row(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               // Image
//                               Container(
//                                 width: 90,
//                                 height: 90,
//                                 decoration: BoxDecoration(
//                                   color: Colors.grey[100],
//                                   borderRadius: BorderRadius.circular(8),
//                                   image: product.productImages.isNotEmpty
//                                       ? DecorationImage(image: CachedNetworkImageProvider(product.productImages.first), fit: BoxFit.cover)
//                                       : null,
//                                 ),
//                                 child: product.productImages.isEmpty ? const Icon(Icons.image, size: 40, color: Colors.grey) : null,
//                               ),
//                               const SizedBox(width: 16),
//                               // Details
//                               Expanded(
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       product.name,
//                                       style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                                       maxLines: 2,
//                                       overflow: TextOverflow.ellipsis,
//                                     ),
//                                     const SizedBox(height: 4),
//                                     Text('SKU: ${product.sku ?? "N/A"}', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
//                                     const SizedBox(height: 8),
//                                     Wrap(
//                                       spacing: 12,
//                                       runSpacing: 4,
//                                       children: [
//                                         Text(
//                                           'Retail: \$${product.retailPrice.toStringAsFixed(2)}',
//                                           style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green[700]),
//                                         ),
//                                         Text('Cost: \$${product.costPrice.toStringAsFixed(2)}', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
//                                       ],
//                                     ),
//                                     const SizedBox(height: 8),
//                                     Wrap(
//                                       spacing: 8,
//                                       runSpacing: 4,
//                                       children: [
//                                         Container(
//                                           padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//                                           decoration: BoxDecoration(
//                                             color: statusColor.withValues(alpha: 0.1),
//                                             borderRadius: BorderRadius.circular(4),
//                                             border: Border.all(color: statusColor.withValues(alpha: 0.5)),
//                                           ),
//                                           child: Text(
//                                             statusText,
//                                             style: TextStyle(fontSize: 10, color: statusColor, fontWeight: FontWeight.bold),
//                                           ),
//                                         ),
//                                         if (product.category?.name != null)
//                                           Container(
//                                             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//                                             decoration: BoxDecoration(
//                                               color: Colors.blue.withValues(alpha: 0.1),
//                                               borderRadius: BorderRadius.circular(4),
//                                               border: Border.all(color: Colors.blue.withValues(alpha: 0.5)),
//                                             ),
//                                             child: Text(
//                                               product.category!.name,
//                                               style: TextStyle(fontSize: 10, color: Colors.blue[700], fontWeight: FontWeight.bold),
//                                             ),
//                                           ),
//                                       ],
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                               Padding(
//                                 padding: const EdgeInsets.only(top: 4),
//                                 child: Text(
//                                   'Qty: ${product.stockQuantity}',
//                                   style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     );
//                   },
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }

// }
