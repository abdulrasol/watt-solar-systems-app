import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:solar_hub/src/core/cashe/cashe_interface.dart';
import 'package:solar_hub/src/core/di/get_it.dart';
import 'package:solar_hub/src/features/inventory/domain/entities/filter.dart';
import '../../../../core/models/response.dart' as local;
import '../../../../core/services/dio.dart';
import '../../../../utils/app_urls.dart';
import '../models/product_model.dart';

abstract class InventoryRemoteDataSource {
  Future<List<ProductModel>> getProducts(int companyId, {required ProductsFilter filter});

  Future<ProductModel> createProduct(int companyId, Map<String, dynamic> productData, {List<File> images = const []});

  Future<ProductModel> updateProduct(int companyId, int productId, Map<String, dynamic> productData, {List<File> images = const []});

  Future<void> deleteProduct(int companyId, int productId);
}

class InventoryRemoteDataSourceImpl implements InventoryRemoteDataSource {
  final DioService _dioService;

  InventoryRemoteDataSourceImpl(this._dioService);

  @override
  Future<List<ProductModel>> getProducts(int companyId, {required ProductsFilter filter}) async {
    local.PaginationResponse response =
        await _dioService.get(AppUrls.products(companyId), queryParameters: filter.query(), isPagination: true) as local.PaginationResponse;
    if (response.error || response.status != 200) {
      throw Exception(response.messageUser.isEmpty ? response.message : response.messageUser);
    }

    final listData = response.body as List;
    return listData.map((e) => ProductModel.fromJson(e)).toList();
  }

  @override
  Future<ProductModel> createProduct(int companyId, Map<String, dynamic> productData, {List<File> images = const []}) async {
    final formData = FormData.fromMap({'payload': jsonEncode(productData)});

    for (var image in images) {
      formData.files.add(MapEntry('images', await MultipartFile.fromFile(image.path, filename: image.path.split('/').last)));
    }

    local.BaseResponse response = await _dioService.multipartRequest(AppUrls.products(getIt<CasheInterface>().user()!.company!.id), file: formData);

    if (response.error || response.status != 200) {
      throw Exception(response.messageUser.isEmpty ? response.message : response.messageUser);
    }

    return ProductModel.fromJson(response.body);
  }

  @override
  Future<ProductModel> updateProduct(int companyId, int productId, Map<String, dynamic> productData, {List<File> images = const []}) async {
    final formData = FormData.fromMap({'payload': jsonEncode(productData)});

    for (var image in images) {
      formData.files.add(MapEntry('images', await MultipartFile.fromFile(image.path, filename: image.path.split('/').last)));
    }

    // WARNING: Might need a new route in the backend (api/v1/company/{id}/products/{product_id} with PUT/PATCH)
    local.BaseResponse response = await _dioService.multipartRequest(
      AppUrls.products(getIt<CasheInterface>().user()!.company!.id),
      file: formData,
      isPut: true, // Requires backend support for PUT
    );

    if (response.error || response.status != 200) {
      throw Exception(response.messageUser.isEmpty ? response.message : response.messageUser);
    }

    return ProductModel.fromJson(response.body);
  }

  @override
  Future<void> deleteProduct(int companyId, int productId) async {
    local.BaseResponse response = await _dioService.delete('${AppUrls.companiesBaseUrl}/$companyId/products/$productId');
    if (response.error || response.status != 200) {
      throw Exception(response.messageUser.isEmpty ? response.message : response.messageUser);
    }
  }
}
