import 'package:flutter/foundation.dart';
import 'package:solar_hub/src/core/cashe/cashe_interface.dart';
import 'package:solar_hub/src/core/di/get_it.dart';
import 'package:solar_hub/src/features/storefront/domain/entities/storefront_cart.dart';
import 'package:solar_hub/src/features/storefront/domain/entities/storefront_models.dart';

class StorefrontCartController extends ChangeNotifier {
  static const _storageKey = 'storefront_company_carts_v1';

  final CasheInterface _cache;
  final List<StorefrontCartItem> _items = [];

  StorefrontCartController(this._cache) {
    _hydrate();
  }

  List<StorefrontCartItem> get items => List.unmodifiable(_items);

  void _hydrate() {
    final raw = _cache.get(_storageKey);
    if (raw is List) {
      _items
        ..clear()
        ..addAll(
          raw.whereType<Map>().map(
            (item) =>
                StorefrontCartItem.fromJson(Map<String, dynamic>.from(item)),
          ),
        );
    }
  }

  Future<void> _persist() async {
    await _cache.save(
      _storageKey,
      _items.map((item) => item.toJson()).toList(),
    );
  }

  List<StorefrontCompanyCart> cartsForAudience(StorefrontAudience audience) {
    final filtered = _items.where((item) => item.audience == audience).toList();
    final grouped = <String, List<StorefrontCartItem>>{};

    for (final item in filtered) {
      final key = '${item.audience.name}_${item.companyId}';
      grouped.putIfAbsent(key, () => []).add(item);
    }

    return grouped.values
        .map(
          (companyItems) => StorefrontCompanyCart(
            companyId: companyItems.first.companyId,
            companyName: companyItems.first.companyName,
            audience: companyItems.first.audience,
            items: companyItems,
          ),
        )
        .toList()
      ..sort((a, b) => a.companyName.compareTo(b.companyName));
  }

  int totalItems(StorefrontAudience audience) {
    return cartsForAudience(
      audience,
    ).fold<int>(0, (sum, cart) => sum + cart.totalItems);
  }

  double totalAmount(StorefrontAudience audience) {
    return cartsForAudience(
      audience,
    ).fold<double>(0, (sum, cart) => sum + cart.totalAmount);
  }

  int companyCartCount(StorefrontAudience audience, int companyId) {
    return _items
        .where(
          (item) => item.audience == audience && item.companyId == companyId,
        )
        .fold<int>(0, (sum, item) => sum + item.quantity);
  }

  Future<void> addProduct(
    StorefrontProduct product, {
    required StorefrontAudience audience,
    int quantity = 1,
  }) async {
    final index = _items.indexWhere(
      (item) =>
          item.audience == audience &&
          item.companyId == product.company.id &&
          item.productId == product.id,
    );

    if (index == -1) {
      _items.add(
        StorefrontCartItem.fromProduct(
          product,
          audience: audience,
          quantity: quantity,
        ),
      );
    } else {
      final current = _items[index];
      _items[index] = current.copyWith(quantity: current.quantity + quantity);
    }

    notifyListeners();
    await _persist();
  }

  Future<void> updateQuantity({
    required StorefrontAudience audience,
    required int companyId,
    required int productId,
    required int quantity,
  }) async {
    final index = _items.indexWhere(
      (item) =>
          item.audience == audience &&
          item.companyId == companyId &&
          item.productId == productId,
    );

    if (index == -1) return;

    if (quantity <= 0) {
      _items.removeAt(index);
    } else {
      _items[index] = _items[index].copyWith(quantity: quantity);
    }

    notifyListeners();
    await _persist();
  }

  Future<void> removeItem({
    required StorefrontAudience audience,
    required int companyId,
    required int productId,
  }) async {
    _items.removeWhere(
      (item) =>
          item.audience == audience &&
          item.companyId == companyId &&
          item.productId == productId,
    );
    notifyListeners();
    await _persist();
  }

  Future<void> clearCompanyCart({
    required StorefrontAudience audience,
    required int companyId,
  }) async {
    _items.removeWhere(
      (item) => item.audience == audience && item.companyId == companyId,
    );
    notifyListeners();
    await _persist();
  }

  Future<void> clearAudience(StorefrontAudience audience) async {
    _items.removeWhere((item) => item.audience == audience);
    notifyListeners();
    await _persist();
  }
}

StorefrontCartController get storefrontCart =>
    getIt<StorefrontCartController>();
