import 'package:solar_hub/src/core/models/response.dart';
import 'package:solar_hub/src/features/crm/data/datasources/crm_remote_data_source.dart';
import 'package:solar_hub/src/features/crm/domain/entities/crm_models.dart';
import 'package:solar_hub/src/features/crm/domain/repositories/crm_repository.dart';
import 'package:solar_hub/src/features/orders_core/domain/entities/order_models.dart';

class CrmRepositoryImpl implements CrmRepository {
  final CrmRemoteDataSource _remoteDataSource;

  CrmRepositoryImpl(this._remoteDataSource);

  @override
  Future<CustomerRecord> createCustomer(
    int companyId,
    CustomerWriteRequest request,
  ) => _remoteDataSource.createCustomer(companyId, request);

  @override
  Future<void> deleteCustomer(int companyId, int customerId) =>
      _remoteDataSource.deleteCustomer(companyId, customerId);

  @override
  Future<CustomerRecord> getCustomer(int companyId, int customerId) =>
      _remoteDataSource.getCustomer(companyId, customerId);

  @override
  Future<PaginatedItemsResponse<CustomerRecord>> listCustomers(
    int companyId, {
    CustomerQuery query = const CustomerQuery(),
  }) => _remoteDataSource.listCustomers(companyId, query: query);

  @override
  Future<CustomerRecord> updateCustomer(
    int companyId,
    int customerId,
    CustomerWriteRequest request,
  ) => _remoteDataSource.updateCustomer(companyId, customerId, request);

  @override
  Future<SupplierRecord> createSupplier(
    int companyId,
    SupplierWriteRequest request,
  ) => _remoteDataSource.createSupplier(companyId, request);

  @override
  Future<void> deleteSupplier(int companyId, int supplierId) =>
      _remoteDataSource.deleteSupplier(companyId, supplierId);

  @override
  Future<SupplierRecord> getSupplier(int companyId, int supplierId) =>
      _remoteDataSource.getSupplier(companyId, supplierId);

  @override
  Future<PaginatedItemsResponse<SupplierRecord>> listSuppliers(
    int companyId, {
    SupplierQuery query = const SupplierQuery(),
  }) => _remoteDataSource.listSuppliers(companyId, query: query);

  @override
  Future<SupplierRecord> updateSupplier(
    int companyId,
    int supplierId,
    SupplierWriteRequest request,
  ) => _remoteDataSource.updateSupplier(companyId, supplierId, request);
}
