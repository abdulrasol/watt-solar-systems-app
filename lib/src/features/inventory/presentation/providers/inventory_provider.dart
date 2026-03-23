import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_hub/src/core/cashe/cashe_interface.dart';
import 'package:solar_hub/src/core/di/get_it.dart';
import 'package:solar_hub/src/features/inventory/domain/entities/filter.dart';
import 'package:solar_hub/src/features/inventory/domain/entities/product.dart';
import 'package:solar_hub/src/features/inventory/domain/repositories/inventory_repository.dart';

class InventoryState {
  final List<Product> products;
  final bool isLoading;
  final bool isMoreLoading;
  final bool hasMore;
  final String? error;
  final ProductsFilter filter;

  const InventoryState({this.products = const [], this.isLoading = false, this.isMoreLoading = false, this.hasMore = true, this.error, required this.filter});

  InventoryState copyWith({List<Product>? products, bool? isLoading, bool? isMoreLoading, bool? hasMore, String? error, ProductsFilter? filter}) {
    return InventoryState(
      products: products ?? this.products,
      isLoading: isLoading ?? this.isLoading,
      isMoreLoading: isMoreLoading ?? this.isMoreLoading,
      hasMore: hasMore ?? this.hasMore,
      error: error ?? this.error,
      filter: filter ?? this.filter,
    );
  }
}

class InventoryProviderNotifier extends Notifier<InventoryState> {
  final InventoryRepository _repository = getIt<InventoryRepository>();

  @override
  InventoryState build() {
    Future.microtask(() => fetchProducts(isRefresh: true));
    return InventoryState(filter: ProductsFilter(), isLoading: true);
  }

  Future<void> fetchProducts({bool isRefresh = false}) async {
    final filter = isRefresh ? state.filter.copyWith(page: 1) : state.filter;

    final products = await _repository.getProducts(getIt<CasheInterface>().user()!.company!.id, filter: filter);

    state = state.copyWith(
      products: isRefresh ? products : [...state.products, ...products],
      isLoading: false,
      isMoreLoading: false,
      hasMore: products.isNotEmpty,
      filter: filter,
    );
  }

  Future<void> nextPage() async {
    if (state.isMoreLoading || !state.hasMore) return;

    state = state.copyWith(isMoreLoading: true, filter: state.filter.copyWith(page: state.filter.page + 1));

    await fetchProducts();
  }

  void addPorodcut(Product product, {bool isUpdate = false}) {
    if (isUpdate) {
      state = state.copyWith(products: state.products.map((e) => e.id == product.id ? product : e).toList());
    } else {
      state = state.copyWith(products: [...state.products, product]);
    }
  }

  Future search(String query) async {
    state = state.copyWith(filter: state.filter.copyWith(search: query));
    fetchProducts(isRefresh: true);
  }

  Future deleteProduct(int productId) async {
    await _repository.deleteProduct(getIt<CasheInterface>().user()!.company!.id, productId);
    state = state.copyWith(products: state.products.where((e) => e.id != productId).toList());
  }
}

final inventoryNotifierProvider = NotifierProvider<InventoryProviderNotifier, InventoryState>(InventoryProviderNotifier.new);
// class InventoryNotifier extends StateNotifier<InventoryState> {
//   final Ref ref;
//   late InventoryRepository _repository;

//   InventoryNotifier(this.ref) : super(const InventoryState()) {
//     _repository = getIt<InventoryRepository>();

//     // Listen to changes in filter or search to trigger a refresh
//     ref.listen(stockFilterProvider, (previous, next) {
//       fetchProducts(isRefresh: true);
//     });
//     ref.listen(inventorySearchProvider, (previous, next) {
//       fetchProducts(isRefresh: true);
//     });

//     // Initial fetch
//     Future.microtask(() => fetchProducts(isRefresh: true));
//   }

//   Future<void> fetchProducts({bool isRefresh = false}) async {
//     if (isRefresh) {
//       state = state.copyWith(isLoading: true, page: 1, hasMore: true, error: null);
//     } else {
//       if (!state.hasMore || state.isMoreLoading || state.isLoading) return;
//       state = state.copyWith(isMoreLoading: true, error: null);
//     }

//     try {
//       final companyId = ref.read(authProvider).company?.id;
//       if (companyId == null) {
//         state = state.copyWith(isLoading: false, isMoreLoading: false, error: "No company selected");
//         return;
//       }

//       final filter = ref.read(stockFilterProvider);

//       int? maxStock;
//       int? minStock;

//       switch (filter) {
//         case StockFilter.inStock:
//           minStock = 1;
//           break;
//         case StockFilter.outOfStock:
//           maxStock = 0;
//           break;
//         case StockFilter.lowStock:
//           maxStock = 5;
//           minStock = 1;
//           break;
//         case StockFilter.all:
//       }

//       final results = await _repository.getProducts(
//         companyId,
//         page: state.page,
//         minStock: minStock,
//         maxStock: maxStock,
//         search: search.isEmpty ? null : search,
//       );

//       if (isRefresh) {
//         state = state.copyWith(products: results, isLoading: false, hasMore: results.isNotEmpty);
//       } else {
//         state = state.copyWith(products: [...state.products, ...results], isMoreLoading: false, page: state.page + 1, hasMore: results.isNotEmpty);
//       }
//     } catch (e) {
//       state = state.copyWith(isLoading: false, isMoreLoading: false, error: e.toString());
//     }
//   }

//   Future<bool> deleteProduct(int productId) async {
//     try {
//       final companyId = ref.read(authProvider).company?.id;
//       if (companyId == null) return false;
//       await _repository.deleteProduct(companyId, productId);
//       // Remove from list
//       state = state.copyWith(products: state.products.where((p) => p.id != productId).toList());
//       return true;
//     } catch (e) {
//       return false;
//     }
//   }
// }

// final inventoryNotifierProvider = StateNotifierProvider.autoDispose<InventoryNotifier, InventoryState>((ref) {
//   return InventoryNotifier(ref);
// });
