import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_hub/src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/controllers/company_contacts_controller.dart';
import 'package:solar_hub/src/features/inventory/presentation/providers/inventory_provider.dart';
import 'package:solar_hub/src/features/offers/presentation/providers/offers_provider.dart';

class GlobalSearchState {
  final String query;
  final bool isSearchActive;

  GlobalSearchState({
    this.query = '',
    this.isSearchActive = false,
  });

  GlobalSearchState copyWith({
    String? query,
    bool? isSearchActive,
  }) {
    return GlobalSearchState(
      query: query ?? this.query,
      isSearchActive: isSearchActive ?? this.isSearchActive,
    );
  }
}

class GlobalSearchNotifier extends Notifier<GlobalSearchState> {
  @override
  GlobalSearchState build() {
    return GlobalSearchState();
  }

  void setQuery(String query) {
    state = state.copyWith(query: query, isSearchActive: query.isNotEmpty);

    if (query.isNotEmpty) {
      // Trigger searches in relevant providers
      ref.read(inventoryNotifierProvider.notifier).search(query);
      ref.read(offersProvider.notifier).searchAvailableRequests(query);

      final companyId = ref.read(authProvider).company?.id;
      if (companyId != null) {
        ref.read(companyContactsProvider.notifier).search(companyId, query);
      }
    }
  }

  void clear() {
    state = GlobalSearchState();
  }
}

final globalSearchProvider =
    NotifierProvider<GlobalSearchNotifier, GlobalSearchState>(
  GlobalSearchNotifier.new,
);
