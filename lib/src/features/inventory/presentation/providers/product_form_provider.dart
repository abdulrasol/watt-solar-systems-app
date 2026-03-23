import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../../core/di/get_it.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/inventory_repository.dart';
import 'inventory_provider.dart';

class ProductFormState {
  final bool isLoading;
  final String? error;

  final List<ProductOption> options;
  final List<ProductPricingTier> pricingTiers;
  final File? selectedImage;
  final String? existingImageUrl;

  ProductFormState({this.isLoading = false, this.error, this.options = const [], this.pricingTiers = const [], this.selectedImage, this.existingImageUrl});

  ProductFormState copyWith({
    bool? isLoading,
    String? error,
    bool clearError = false,
    List<ProductOption>? options,
    List<ProductPricingTier>? pricingTiers,
    File? selectedImage,
    bool clearImage = false,
    String? existingImageUrl,
    bool clearExistingImageUrl = false,
  }) {
    return ProductFormState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      options: options ?? this.options,
      pricingTiers: pricingTiers ?? this.pricingTiers,
      selectedImage: clearImage ? null : (selectedImage ?? this.selectedImage),
      existingImageUrl: clearExistingImageUrl ? null : (existingImageUrl ?? this.existingImageUrl),
    );
  }
}

class ProductFormNotifier extends StateNotifier<ProductFormState> {
  final Ref ref;
  late InventoryRepository _repository;

  ProductFormNotifier(this.ref) : super(ProductFormState()) {
    _repository = getIt<InventoryRepository>();
  }

  void initializeWithProduct(Product? product) {
    if (product != null) {
      state = state.copyWith(
        options: List.from(product.options),
        pricingTiers: List.from(product.pricingTiers),
        existingImageUrl: product.productImages.isNotEmpty ? product.productImages.first : null,
      );
    } else {
      state = ProductFormState(); // Reset
    }
  }

  void addOption(ProductOption option) {
    state = state.copyWith(options: [...state.options, option]);
  }

  void removeOption(int index) {
    final newOptions = List<ProductOption>.from(state.options)..removeAt(index);
    state = state.copyWith(options: newOptions);
  }

  void addPricingTier(ProductPricingTier tier) {
    state = state.copyWith(pricingTiers: [...state.pricingTiers, tier]);
  }

  void removePricingTier(int index) {
    final newTiers = List<ProductPricingTier>.from(state.pricingTiers)..removeAt(index);
    state = state.copyWith(pricingTiers: newTiers);
  }

  void updatePricingTier(int index, ProductPricingTier tier) {
    final newTiers = List<ProductPricingTier>.from(state.pricingTiers);
    newTiers[index] = tier;
    state = state.copyWith(pricingTiers: newTiers);
  }

  void setImage(File file) {
    state = state.copyWith(selectedImage: file, clearExistingImageUrl: true);
  }

  void clearImage() {
    state = state.copyWith(clearImage: true, clearExistingImageUrl: true);
  }

  Future<bool> saveProduct({
    int? currentProductId,
    required String name,
    required String sku,
    required String description,
    required double retailPrice,
    required double costPrice,
    required double wholesalePrice,
    required int stockQuantity,
    required int minStockAlert,
    int? categoryId,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final companyId = ref.read(authProvider).company?.id;
      if (companyId == null) throw Exception("No company selected");

      final productData = {
        'name': name,
        'sku': sku,
        'description': description,
        'retail_price': retailPrice,
        'cost_price': costPrice,
        'wholesale_price': wholesalePrice,
        'stock_quantity': stockQuantity,
        'min_stock_alert': minStockAlert,
        'status': 'active',
        'options': state.options
            .map((e) => {'name': e.name, 'retail_price': e.retailPrice, 'cost': e.cost, 'wholesale_price': e.wholesalePrice ?? 0, 'is_required': e.isRequired})
            .toList(),
        'pricing_tiers': state.pricingTiers.map((e) => {'quantity': e.quantity, 'unit_price': e.unitPrice}).toList(),
      };

      if (categoryId != null) productData['category_id'] = categoryId;

      List<File> imagesToUpload = [];
      if (state.selectedImage != null) {
        imagesToUpload.add(state.selectedImage!);
      }

      if (currentProductId == null) {
        final product = await _repository.createProduct(companyId, productData, images: imagesToUpload);
        ref.read(inventoryNotifierProvider.notifier).addPorodcut(product);
      } else {
        final product = await _repository.updateProduct(companyId, currentProductId, productData, images: imagesToUpload);
        ref.read(inventoryNotifierProvider.notifier).addPorodcut(product, isUpdate: true);
      }

      // Refresh list

      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}

final productFormNotifierProvider = StateNotifierProvider.autoDispose<ProductFormNotifier, ProductFormState>((ref) {
  return ProductFormNotifier(ref);
});
