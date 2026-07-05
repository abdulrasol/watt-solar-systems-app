import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/get_it.dart';
import '../../../../core/cashe/cashe_interface.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/inventory_repository.dart';
import 'inventory_provider.dart';

class ProductFormState {
  final bool isLoading;
  final String? error;

  final List<ProductOption> options;
  final List<ProductPricingTier> pricingTiers;
  final List<File> selectedImages;
  final List<String> existingImageUrls;

  // New fields
  // Form Fields
  final String status;
  final bool isAvailable;
  final int? globalCategoryId;
  final List<int> internalCategoryIds;
  final int? companyCategoryId;

  ProductFormState({
    this.isLoading = false,
    this.error,
    this.options = const [],
    this.pricingTiers = const [],
    this.selectedImages = const [],
    this.existingImageUrls = const [],
    this.status = 'active',
    this.isAvailable = true,
    this.globalCategoryId,
    this.internalCategoryIds = const [],
    this.companyCategoryId,
  });

  bool get isSubmitting => isLoading;
  List<String> get existingImages => existingImageUrls;

  ProductFormState copyWith({
    bool? isLoading,
    String? error,
    bool clearError = false,
    List<ProductOption>? options,
    List<ProductPricingTier>? pricingTiers,
    List<File>? selectedImages,
    List<String>? existingImageUrls,
    String? status,
    bool? isAvailable,
    int? globalCategoryId,
    List<int>? internalCategoryIds,
    int? companyCategoryId,
  }) {
    return ProductFormState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      options: options ?? this.options,
      pricingTiers: pricingTiers ?? this.pricingTiers,
      selectedImages: selectedImages ?? this.selectedImages,
      existingImageUrls: existingImageUrls ?? this.existingImageUrls,
      status: status ?? this.status,
      isAvailable: isAvailable ?? this.isAvailable,
      globalCategoryId: globalCategoryId ?? this.globalCategoryId,
      internalCategoryIds: internalCategoryIds ?? this.internalCategoryIds,
      companyCategoryId: companyCategoryId ?? this.companyCategoryId,
    );
  }
}

class ProductFormNotifier extends Notifier<ProductFormState> {
  late InventoryRepository _repository;

  @override
  ProductFormState build() {
    _repository = getIt<InventoryRepository>();
    return ProductFormState();
  }

  void initializeWithProduct(Product? product) {
    if (product != null) {
      state = state.copyWith(
        options: List.from(product.options),
        pricingTiers: List.from(product.pricingTiers),
        existingImageUrls: List.from(product.images),
        status: product.status,
        isAvailable: product.isAvailable,
        globalCategoryId: product.globalCategory?.id,
        internalCategoryIds: product.internalCategories.map((e) => e.id).toList(),
        companyCategoryId: product.category?.id,
      );
    } else {
      state = ProductFormState(); // Reset
    }
  }

  void setStatus(String status) {
    state = state.copyWith(status: status);
  }

  void setAvailability(bool isAvailable) {
    state = state.copyWith(isAvailable: isAvailable);
  }

  void setGlobalCategory(int? categoryId) {
    state = state.copyWith(globalCategoryId: categoryId);
  }

  void setInternalCategories(List<int> categoryIds) {
    state = state.copyWith(internalCategoryIds: categoryIds);
  }

  void setCompanyCategory(int? categoryId) {
    state = state.copyWith(companyCategoryId: categoryId);
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

  void addImage(File file) {
    state = state.copyWith(selectedImages: [...state.selectedImages, file]);
  }

  void addImages(List<File> files) {
    state = state.copyWith(selectedImages: [...state.selectedImages, ...files]);
  }

  void removeSelectedImage(File file) {
    state = state.copyWith(
      selectedImages: state.selectedImages.where((f) => f.path != file.path).toList(),
    );
  }

  void removeExistingImage(String url) {
    state = state.copyWith(
      existingImageUrls: state.existingImageUrls.where((u) => u != url).toList(),
    );
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
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final user = getIt<CasheInterface>().user();
      if (user?.company?.id == null) throw Exception("No company selected");
      final companyId = user!.company!.id;

      final Map<String, dynamic> productData = {
        'name': name,
        'sku': sku,
        'description': description,
        'retail_price': retailPrice,
        'cost_price': costPrice,
        'wholesale_price': wholesalePrice,
        'stock_quantity': stockQuantity,
        'min_stock_alert': minStockAlert,
        'status': state.status,
        'is_available': state.isAvailable,
        'options': state.options
            .map((e) => {
                  if (e.id != null) 'id': e.id,
                  'name': e.name,
                  'retail_price': e.retailPrice,
                  'cost': e.cost,
                  'wholesale_price': e.wholesalePrice ?? 0,
                  'is_required': e.isRequired
                })
            .toList(),
        'pricing_tiers': state.pricingTiers.map((e) => {if (e.id != null) 'id': e.id, 'quantity': e.quantity, 'unit_price': e.unitPrice}).toList(),
      };

      final globalCategoryId = state.globalCategoryId;
      if (globalCategoryId != null) productData['global_category_id'] = globalCategoryId;

      if (state.internalCategoryIds.isNotEmpty) {
        productData['internal_category_ids'] = state.internalCategoryIds;
      }

      final companyCategoryId = state.companyCategoryId;
      if (companyCategoryId != null) productData['company_category_id'] = companyCategoryId;

      if (currentProductId == null) {
        final product = await _repository.createProduct(companyId, productData, images: state.selectedImages);
        ref.read(inventoryNotifierProvider.notifier).addProduct(product);
      } else {
        final product = await _repository.updateProduct(companyId, currentProductId, productData, images: state.selectedImages,);
        ref.read(inventoryNotifierProvider.notifier).addProduct(product, isUpdate: true);
      }

      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}

final productFormNotifierProvider = NotifierProvider<ProductFormNotifier, ProductFormState>(ProductFormNotifier.new);

