import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:solar_hub/src/features/inventory/data/models/filter_options_model.dart';
import 'package:solar_hub/src/features/inventory/domain/entities/filter.dart';
import '../../../../core/models/response.dart' as local;
import '../../../../core/services/dio.dart';
import '../../../../utils/app_urls.dart';
import '../../../../utils/helper_methods.dart';
import '../models/product_model.dart';

abstract class InventoryRemoteDataSource {
  Future<List<ProductModel>> getProducts(int companyId, {required ProductsFilter filter});

  Future<ProductFilterOptionsModel> getFilterOptions(int companyId);

  Future<ProductModel> createProduct(int companyId, Map<String, dynamic> productData, {List<File> images = const []});

  Future<ProductModel> updateProduct(int companyId, int productId, Map<String, dynamic> productData, {List<File> images = const []});

  Future<void> deleteProduct(int companyId, int productId);
}

class InventoryRemoteDataSourceImpl implements InventoryRemoteDataSource {
  final DioService _dioService;

  InventoryRemoteDataSourceImpl(this._dioService);

  @override
  Future<List<ProductModel>> getProducts(int companyId, {required ProductsFilter filter}) async {
    try {
      local.PaginationResponse response =
          await _dioService.get(AppUrls.products(companyId), queryParameters: filter.query(), isPagination: true) as local.PaginationResponse;
      if (response.error || response.status != 200) {
        throw Exception(response.messageUser.isEmpty ? response.message : response.messageUser);
      }

      final listData = response.body as List;
      return listData.map((e) => ProductModel.fromJson(e)).toList();
    } catch (e, stackTrace) {
      dPrint('getProducts error: $e', stackTrace: stackTrace, tag: 'InventoryRemoteDataSource');
      rethrow;
    }
  }

  @override
  Future<ProductFilterOptionsModel> getFilterOptions(int companyId) async {
    try {
      local.Response response = await _dioService.get('${AppUrls.companiesBaseUrl}/$companyId/products/filter-options') as local.Response;
      if (response.error || response.status != 200) {
        throw Exception(response.messageUser.isEmpty ? response.message : response.messageUser);
      }
      return ProductFilterOptionsModel.fromJson(response.body);
    } catch (e, stackTrace) {
      dPrint('getFilterOptions error: $e', stackTrace: stackTrace, tag: 'InventoryRemoteDataSource');
      rethrow;
    }
  }

  @override
  Future<ProductModel> createProduct(int companyId, Map<String, dynamic> productData, {List<File> images = const []}) async {
    try {
      final formData = FormData.fromMap({'payload': jsonEncode(productData)});

      for (var image in images) {
        formData.files.add(MapEntry('images', await MultipartFile.fromFile(image.path, filename: image.path.split('/').last)));
      }

      local.BaseResponse response = await _dioService.multipartRequest(AppUrls.products(companyId), file: formData);

      if (response.error || response.status != 200) {
        throw Exception(response.messageUser.isEmpty ? response.message : response.messageUser);
      }

      return ProductModel.fromJson(response.body);
    } catch (e, stackTrace) {
      dPrint('createProduct error: $e', stackTrace: stackTrace, tag: 'InventoryRemoteDataSource');
      rethrow;
    }
  }

  @override
  Future<ProductModel> updateProduct(int companyId, int productId, Map<String, dynamic> productData, {List<File> images = const []}) async {
    try {
      final formData = FormData.fromMap({'payload': jsonEncode(productData)});

      for (var image in images) {
        formData.files.add(MapEntry('images', await MultipartFile.fromFile(image.path, filename: image.path.split('/').last)));
      }

      local.BaseResponse response = await _dioService.multipartRequest('${AppUrls.companiesBaseUrl}/$companyId/products/$productId', file: formData, isPut: true);

      if (response.error || response.status != 200) {
        throw Exception(response.messageUser.isEmpty ? response.message : response.messageUser);
      }

      return ProductModel.fromJson(response.body);
    } catch (e, stackTrace) {
      dPrint('updateProduct error: $e', stackTrace: stackTrace, tag: 'InventoryRemoteDataSource');
      rethrow;
    }
  }

  @override
  Future<void> deleteProduct(int companyId, int productId) async {
    try {
      local.BaseResponse response = await _dioService.delete('${AppUrls.companiesBaseUrl}/$companyId/products/$productId');
      if (response.error || response.status != 200) {
        throw Exception(response.messageUser.isEmpty ? response.message : response.messageUser);
      }
    } catch (e, stackTrace) {
      dPrint('deleteProduct error: $e', stackTrace: stackTrace, tag: 'InventoryRemoteDataSource');
      rethrow;
    }
  }
}
