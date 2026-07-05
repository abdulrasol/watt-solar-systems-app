import 'dart:io';
import 'package:solar_hub/src/features/inventory/domain/entities/filter.dart';
import 'package:solar_hub/src/features/inventory/domain/entities/filter_options.dart';
import 'package:solar_hub/src/features/inventory/domain/entities/product.dart';

abstract class InventoryRepository {
  Future<List<Product>> getProducts(int companyId, {required ProductsFilter filter});

  Future<ProductFilterOptions> getFilterOptions(int companyId);

  Future<Product> createProduct(int companyId, Map<String, dynamic> productData, {List<File> images = const []});

  Future<Product> updateProduct(int companyId, int productId, Map<String, dynamic> productData, {List<File> images = const []});

  Future<void> deleteProduct(int companyId, int productId);
}
