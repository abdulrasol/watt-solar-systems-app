import 'dart:io';
import 'package:solar_hub/src/features/inventory/domain/entities/filter.dart';
import 'package:solar_hub/src/features/inventory/domain/entities/filter_options.dart';

import '../../domain/entities/product.dart';
import '../../domain/repositories/inventory_repository.dart';
import '../data_sources/inventory_remote_data_source.dart';

class InventoryRepositoryImpl implements InventoryRepository {
  final InventoryRemoteDataSource remoteDataSource;

  InventoryRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<Product>> getProducts(int companyId, {required ProductsFilter filter}) async {
    return await remoteDataSource.getProducts(companyId, filter: filter);
  }

  @override
  Future<ProductFilterOptions> getFilterOptions(int companyId) async {
    return await remoteDataSource.getFilterOptions(companyId);
  }

  @override
  Future<Product> createProduct(int companyId, Map<String, dynamic> productData, {List<File> images = const []}) async {
    return await remoteDataSource.createProduct(companyId, productData, images: images);
  }

  @override
  Future<Product> updateProduct(int companyId, int productId, Map<String, dynamic> productData, {List<File> images = const []}) async {
    return await remoteDataSource.updateProduct(companyId, productId, productData, images: images);
  }

  @override
  Future<void> deleteProduct(int companyId, int productId) async {
    await remoteDataSource.deleteProduct(companyId, productId);
  }
}
