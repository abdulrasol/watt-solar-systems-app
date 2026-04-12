import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_hub/src/core/di/get_it.dart';
import 'package:solar_hub/src/features/admin/domain/models/service_catalog_item.dart';
import 'package:solar_hub/src/features/admin/domain/repositories/admin_repository.dart';

class AdminServiceCatalogState {
  final bool isLoading;
  final String? error;
  final List<ServiceCatalogItem> catalog;

  AdminServiceCatalogState({this.isLoading = false, this.error, this.catalog = const []});

  AdminServiceCatalogState copyWith({bool? isLoading, String? error, List<ServiceCatalogItem>? catalog}) {
    return AdminServiceCatalogState(isLoading: isLoading ?? this.isLoading, error: error ?? this.error, catalog: catalog ?? this.catalog);
  }
}

class AdminServiceCatalogController extends Notifier<AdminServiceCatalogState> {
  late AdminRepository _repository;

  @override
  AdminServiceCatalogState build() {
    _repository = getIt<AdminRepository>();
    return AdminServiceCatalogState();
  }

  Future<void> fetchServiceCatalog() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final catalog = await _repository.listServiceCatalog();
      // Sort the catalog by sortOrder
      catalog.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      state = state.copyWith(isLoading: false, catalog: catalog);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> createServiceCatalogEntry(ServiceCatalogItem item) async {
    try {
      await _repository.createServiceCatalogEntry(item);
      await fetchServiceCatalog();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> updateServiceCatalogEntry(String serviceCode, Map<String, dynamic> data) async {
    try {
      await _repository.updateServiceCatalogEntry(serviceCode, data);
      await fetchServiceCatalog();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> deleteServiceCatalogEntry(String serviceCode) async {
    try {
      await _repository.deleteServiceCatalogEntry(serviceCode);
      await fetchServiceCatalog();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  // Locally reorder catalog items before syncing to server (for drag-and-drop feedback)
  void reorderCatalog(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final items = List<ServiceCatalogItem>.from(state.catalog);
    final item = items.removeAt(oldIndex);
    items.insert(newIndex, item);

    // Update sort orders locally
    final updatedItems = items.asMap().entries.map((entry) {
      final index = entry.key;
      final catalogItem = entry.value;
      return catalogItem.copyWith(sortOrder: (index + 1) * 10);
    }).toList();

    state = state.copyWith(catalog: updatedItems);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  // Sync reordered catalog to server
  Future<void> syncCatalogOrder() async {
    try {
      for (int i = 0; i < state.catalog.length; i++) {
        final item = state.catalog[i];
        await _repository.updateServiceCatalogEntry(item.code, {'sort_order': item.sortOrder});
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

final adminServiceCatalogProvider = NotifierProvider<AdminServiceCatalogController, AdminServiceCatalogState>(() {
  return AdminServiceCatalogController();
});
