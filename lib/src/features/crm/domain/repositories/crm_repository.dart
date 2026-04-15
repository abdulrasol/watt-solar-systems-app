import 'package:solar_hub/src/core/models/response.dart';
import 'package:solar_hub/src/features/crm/domain/entities/crm_models.dart';
import 'package:solar_hub/src/features/orders_core/domain/entities/order_models.dart';

abstract class CrmRepository {
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
