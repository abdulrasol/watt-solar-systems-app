import 'package:flutter/foundation.dart';
import 'package:solar_hub/src/core/cashe/cashe_interface.dart';
import 'package:solar_hub/src/core/di/get_it.dart';
import 'package:solar_hub/src/features/storefront/domain/entities/storefront_cart.dart';
import 'package:solar_hub/src/features/storefront/domain/entities/storefront_models.dart';

class StorefrontCartController extends ChangeNotifier {
  static const _storageKey = 'storefront_company_carts_v2';

  final CasheInterface _cache;
  final List<StorefrontCartItem> _items = [];
  final Map<String, StorefrontCompanyCartConfig> _configs = {};

  StorefrontCartController(this._cache) {
    _hydrate();
  }

  List<StorefrontCartItem> get items => List.unmodifiable(_items);

  String _key(StorefrontAudience audience, int companyId) {
    return '${audience.name}_$companyId';
  }

  String _defaultPaymentMethod(StorefrontAudience audience) {
    return audience == StorefrontAudience.b2b ? 'credit' : 'cash';
  }

  void _hydrate() {
    final raw = _cache.get(_storageKey);
    _items.clear();
    _configs.clear();

    if (raw is List) {
      _items.addAll(
        raw.whereType<Map>().map(
          (item) =>
              StorefrontCartItem.fromJson(Map<String, dynamic>.from(item)),
        ),
      );
      return;
    }

    if (raw is! Map) return;

    final itemsRaw = raw['items'] as List? ?? const [];
    final configsRaw = raw['configs'] as List? ?? const [];

    _items.addAll(
      itemsRaw.whereType<Map>().map(
        (item) => StorefrontCartItem.fromJson(Map<String, dynamic>.from(item)),
      ),
    );

    for (final config in configsRaw.whereType<Map>()) {
      final parsed = StorefrontCompanyCartConfig.fromJson(
        Map<String, dynamic>.from(config),
      );
      _configs[_key(parsed.audience, parsed.companyId)] = parsed;
    }
  }

  Future<void> _persist() async {
    await _cache.save(_storageKey, {
      'items': _items.map((item) => item.toJson()).toList(),
      'configs': _configs.values.map((config) => config.toJson()).toList(),
    });
  }

  Set<StorefrontAudience> audiencesForCompany(int companyId) {
    final audiences = <StorefrontAudience>{};
    for (final item in _items.where((item) => item.companyId == companyId)) {
      audiences.add(item.audience);
    }
    for (final config in _configs.values.where(
      (item) => item.companyId == companyId,
    )) {
      audiences.add(config.audience);
    }
    return audiences;
  }

  StorefrontCompanyCart? cartForCompany({
    required StorefrontAudience audience,
    required int companyId,
  }) {
    final carts = cartsForAudience(audience);
    for (final cart in carts) {
      if (cart.companyId == companyId) return cart;
    }
    return null;
  }

  List<StorefrontCompanyCart> cartsForAudience(StorefrontAudience audience) {
    final filtered = _items.where((item) => item.audience == audience).toList();
    final grouped = <String, List<StorefrontCartItem>>{};

    for (final item in filtered) {
      grouped
          .putIfAbsent(_key(item.audience, item.companyId), () => [])
          .add(item);
    }

    return grouped.values.map((companyItems) {
      final first = companyItems.first;
      final config =
          _configs[_key(first.audience, first.companyId)] ??
          StorefrontCompanyCartConfig(
            companyId: first.companyId,
            audience: first.audience,
            paymentMethod: _defaultPaymentMethod(first.audience),
          );

      return StorefrontCompanyCart(
        companyId: first.companyId,
        companyName: first.companyName,
        audience: first.audience,
        items: companyItems,
        paymentMethod: config.paymentMethod,
        deliveryMethod: config.deliveryMethod,
        deliveryOptionId: config.deliveryOptionId,
        deliveryCost: config.deliveryCost,
        shippingAddress: config.shippingAddress,
      );
    }).toList()..sort((a, b) => a.companyName.compareTo(b.companyName));
  }

  List<StorefrontCompanyCart> allCarts() {
    final carts = [
      ...cartsForAudience(StorefrontAudience.b2c),
      ...cartsForAudience(StorefrontAudience.b2b),
    ];

    carts.sort((a, b) {
      final companyCompare = a.companyName.compareTo(b.companyName);
      if (companyCompare != 0) return companyCompare;
      return a.audience.name.compareTo(b.audience.name);
    });

    return carts;
  }

  int totalItems(StorefrontAudience audience) {
    return cartsForAudience(
      audience,
    ).fold<int>(0, (sum, cart) => sum + cart.totalItems);
  }

  int totalItemsAll() {
    return allCarts().fold<int>(0, (sum, cart) => sum + cart.totalItems);
  }

  double totalAmount(StorefrontAudience audience) {
    return cartsForAudience(
      audience,
    ).fold<double>(0, (sum, cart) => sum + cart.totalAmount);
  }

  double totalAmountAll() {
    return allCarts().fold<double>(0, (sum, cart) => sum + cart.totalAmount);
  }

  int companyCartCount(StorefrontAudience audience, int companyId) {
    return _items
        .where(
          (item) => item.audience == audience && item.companyId == companyId,
        )
        .fold<int>(0, (sum, item) => sum + item.quantity);
  }

  bool containsProduct(
    StorefrontProduct product, {
    List<int>? selectedOptionIds,
  }) {
    return _items.any(
      (item) =>
          item.companyId == product.company.id &&
          item.productId == product.id &&
          (selectedOptionIds == null ||
              listEquals(item.selectedOptionIds, selectedOptionIds)),
    );
  }

  Future<void> addProduct(
    StorefrontProduct product, {
    required StorefrontAudience audience,
    required int quantity,
    required List<StorefrontProductOption> selectedOptions,
  }) async {
    final index = _items.indexWhere(
      (item) =>
          item.audience == audience &&
          item.companyId == product.company.id &&
          item.productId == product.id &&
          listEquals(
            item.selectedOptionIds,
            selectedOptions.map((e) => e.id).toList(),
          ),
    );

    if (index == -1) {
      _items.add(
        StorefrontCartItem.fromProduct(
          product,
          audience: audience,
          quantity: quantity,
          selectedOptions: selectedOptions,
        ),
      );
    } else {
      final current = _items[index];
      _items[index] = current.copyWith(quantity: current.quantity + quantity);
    }

    _configs.putIfAbsent(
      _key(audience, product.company.id),
      () => StorefrontCompanyCartConfig(
        companyId: product.company.id,
        audience: audience,
        paymentMethod: _defaultPaymentMethod(audience),
      ),
    );

    notifyListeners();
    await _persist();
  }

  Future<void> updateQuantity({
    required StorefrontAudience audience,
    required int companyId,
    required int productId,
    required int quantity,
    List<int>? selectedOptionIds,
  }) async {
    final index = _items.indexWhere(
      (item) =>
          item.audience == audience &&
          item.companyId == companyId &&
          item.productId == productId &&
          (selectedOptionIds == null ||
              listEquals(item.selectedOptionIds, selectedOptionIds)),
    );

    if (index == -1) return;

    if (quantity <= 0) {
      _items.removeAt(index);
    } else {
      _items[index] = _items[index].copyWith(quantity: quantity);
    }

    _removeEmptyConfigIfNeeded(audience: audience, companyId: companyId);
    notifyListeners();
    await _persist();
  }

  Future<void> removeItem({
    required StorefrontAudience audience,
    required int companyId,
    required int productId,
    List<int>? selectedOptionIds,
  }) async {
    _items.removeWhere(
      (item) =>
          item.audience == audience &&
          item.companyId == companyId &&
          item.productId == productId &&
          (selectedOptionIds == null ||
              listEquals(item.selectedOptionIds, selectedOptionIds)),
    );
    _removeEmptyConfigIfNeeded(audience: audience, companyId: companyId);
    notifyListeners();
    await _persist();
  }

  Future<void> removeProductAcrossAudiences({
    required int companyId,
    required int productId,
    List<int>? selectedOptionIds,
  }) async {
    _items.removeWhere(
      (item) =>
          item.companyId == companyId &&
          item.productId == productId &&
          (selectedOptionIds == null ||
              listEquals(item.selectedOptionIds, selectedOptionIds)),
    );
    _configs.removeWhere(
      (key, value) =>
          value.companyId == companyId &&
          !_items.any(
            (item) =>
                item.companyId == companyId && item.audience == value.audience,
          ),
    );
    notifyListeners();
    await _persist();
  }

  Future<void> updateCompanyCartConfig({
    required StorefrontAudience audience,
    required int companyId,
    required String paymentMethod,
    String? deliveryMethod,
    bool clearDeliveryMethod = false,
    int? deliveryOptionId,
    bool clearDeliveryOptionId = false,
    double? deliveryCost,
    Map<String, dynamic>? shippingAddress,
    bool clearShippingAddress = false,
  }) async {
    final key = _key(audience, companyId);
    final current =
        _configs[key] ??
        StorefrontCompanyCartConfig(
          companyId: companyId,
          audience: audience,
          paymentMethod: _defaultPaymentMethod(audience),
        );

    _configs[key] = current.copyWith(
      paymentMethod: paymentMethod,
      deliveryMethod: deliveryMethod,
      clearDeliveryMethod: clearDeliveryMethod,
      deliveryOptionId: deliveryOptionId,
      clearDeliveryOptionId: clearDeliveryOptionId,
      deliveryCost: deliveryCost,
      shippingAddress: shippingAddress,
      clearShippingAddress: clearShippingAddress,
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
    _configs.remove(_key(audience, companyId));
    notifyListeners();
    await _persist();
  }

  Future<void> clearAudience(StorefrontAudience audience) async {
    _items.removeWhere((item) => item.audience == audience);
    _configs.removeWhere((key, value) => value.audience == audience);
    notifyListeners();
    await _persist();
  }

  void _removeEmptyConfigIfNeeded({
    required StorefrontAudience audience,
    required int companyId,
  }) {
    final hasItems = _items.any(
      (item) => item.audience == audience && item.companyId == companyId,
    );
    if (!hasItems) {
      _configs.remove(_key(audience, companyId));
    }
  }
}

StorefrontCartController get storefrontCart =>
    getIt<StorefrontCartController>();
