import 'package:solar_hub/src/core/models/response.dart';
import 'package:solar_hub/src/core/services/dio.dart';
import 'package:solar_hub/src/features/crm/domain/entities/crm_models.dart';
import 'package:solar_hub/src/features/orders_core/domain/entities/order_models.dart';
import 'package:solar_hub/src/utils/app_urls.dart';

abstract class CrmRemoteDataSource {
  Future<PaginatedItemsResponse<CustomerRecord>> listCustomers(
    int companyId, {
    CustomerQuery query = const CustomerQuery(),
  });
  Future<CustomerRecord> createCustomer(
    int companyId,
    CustomerWriteRequest request,
  );
  Future<CustomerRecord> updateCustomer(
    int companyId,
    int customerId,
    CustomerWriteRequest request,
  );
  Future<CustomerRecord> getCustomer(int companyId, int customerId);
  Future<void> deleteCustomer(int companyId, int customerId);
  Future<PaginatedItemsResponse<SupplierRecord>> listSuppliers(
    int companyId, {
    SupplierQuery query = const SupplierQuery(),
  });
  Future<SupplierRecord> createSupplier(
    int companyId,
    SupplierWriteRequest request,
  );
  Future<SupplierRecord> updateSupplier(
    int companyId,
    int supplierId,
    SupplierWriteRequest request,
  );
  Future<SupplierRecord> getSupplier(int companyId, int supplierId);
  Future<void> deleteSupplier(int companyId, int supplierId);
}

class CrmRemoteDataSourceImpl implements CrmRemoteDataSource {
  final DioService _dioService;

  CrmRemoteDataSourceImpl(this._dioService);

  @override
  Future<CustomerRecord> createCustomer(
    int companyId,
    CustomerWriteRequest request,
  ) async {
    final response = await _dioService.post(
      AppUrls.customers(companyId),
      data: request.toJson(),
    );
    return CustomerRecord.fromJson(
      Map<String, dynamic>.from(response.body as Map),
    );
  }

  @override
  Future<void> deleteCustomer(int companyId, int customerId) =>
      _dioService.delete(AppUrls.customer(companyId, customerId));

  @override
  Future<CustomerRecord> getCustomer(int companyId, int customerId) async {
    final response =
        await _dioService.get(AppUrls.customer(companyId, customerId))
            as Response;
    return CustomerRecord.fromJson(
      Map<String, dynamic>.from(response.body as Map),
    );
  }

  @override
  Future<PaginatedItemsResponse<CustomerRecord>> listCustomers(
    int companyId, {
    CustomerQuery query = const CustomerQuery(),
  }) async {
    final response = await _dioService.getRawMap(
      AppUrls.customers(companyId),
      queryParameters: query.toQueryParameters(),
    );
    return PaginatedItemsResponse<CustomerRecord>.fromJson(
      response,
      CustomerRecord.fromJson,
    );
  }

  @override
  Future<CustomerRecord> updateCustomer(
    int companyId,
    int customerId,
    CustomerWriteRequest request,
  ) async {
    final response = await _dioService.put(
      AppUrls.customer(companyId, customerId),
      data: request.toJson(),
    );
    return CustomerRecord.fromJson(
      Map<String, dynamic>.from(response.body as Map),
    );
  }

  @override
  Future<SupplierRecord> createSupplier(
    int companyId,
    SupplierWriteRequest request,
  ) async {
    final response = await _dioService.post(
      AppUrls.suppliers(companyId),
      data: request.toJson(),
    );
    return SupplierRecord.fromJson(
      Map<String, dynamic>.from(response.body as Map),
    );
  }

  @override
  Future<void> deleteSupplier(int companyId, int supplierId) =>
      _dioService.delete(AppUrls.supplier(companyId, supplierId));

  @override
  Future<SupplierRecord> getSupplier(int companyId, int supplierId) async {
    final response =
        await _dioService.get(AppUrls.supplier(companyId, supplierId))
            as Response;
    return SupplierRecord.fromJson(
      Map<String, dynamic>.from(response.body as Map),
    );
  }

  @override
  Future<PaginatedItemsResponse<SupplierRecord>> listSuppliers(
    int companyId, {
    SupplierQuery query = const SupplierQuery(),
  }) async {
    final response = await _dioService.getRawMap(
      AppUrls.suppliers(companyId),
      queryParameters: query.toQueryParameters(),
    );
    return PaginatedItemsResponse<SupplierRecord>.fromJson(
      response,
      SupplierRecord.fromJson,
    );
  }

  @override
  Future<SupplierRecord> updateSupplier(
    int companyId,
    int supplierId,
    SupplierWriteRequest request,
  ) async {
    final response = await _dioService.put(
      AppUrls.supplier(companyId, supplierId),
      data: request.toJson(),
    );
    return SupplierRecord.fromJson(
      Map<String, dynamic>.from(response.body as Map),
    );
  }
}
