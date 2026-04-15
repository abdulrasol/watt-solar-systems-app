import 'package:solar_hub/src/core/models/response.dart';
import 'package:solar_hub/src/features/orders_buyer/data/datasources/orders_remote_data_source.dart';
import 'package:solar_hub/src/features/orders_buyer/domain/repositories/orders_repository.dart';
import 'package:solar_hub/src/features/orders_core/domain/entities/order_models.dart';
import 'package:solar_hub/src/features/orders_core/domain/entities/order_queries.dart';

class OrdersRepositoryImpl implements OrdersRepository {
  final OrdersRemoteDataSource _remoteDataSource;

  OrdersRepositoryImpl(this._remoteDataSource);

  @override
  Future<OrderRecord> createB2bOrder(B2bOrderCreateRequest request) =>
      _remoteDataSource.createB2bOrder(request);

  @override
  Future<OrderRecord> createB2cOrder(B2cOrderCreateRequest request) =>
      _remoteDataSource.createB2cOrder(request);

  @override
  Future<OrderRecord> cancelMyOrder(OrderAudience audience, int orderId) =>
      _remoteDataSource.cancelMyOrder(audience, orderId);

  @override
  Future<OrderRecord> confirmB2bReceipt(int orderId) =>
      _remoteDataSource.confirmB2bReceipt(orderId);

  @override
  Future<OrderRecord> getCompanyOrder(int companyId, int orderId) =>
      _remoteDataSource.getCompanyOrder(companyId, orderId);

  @override
  Future<OrderRecord> getMyOrder(OrderAudience audience, int orderId) =>
      _remoteDataSource.getMyOrder(audience, orderId);

  @override
  Future<PaginatedItemsResponse<OrderRecord>> listCompanyOrders(
    int companyId, {
    OrderListQuery query = const OrderListQuery(),
  }) => _remoteDataSource.listCompanyOrders(companyId, query: query);

  @override
  Future<PaginatedItemsResponse<OrderRecord>> listMyOrders(
    OrderAudience audience, {
    OrderListQuery query = const OrderListQuery(),
  }) => _remoteDataSource.listMyOrders(audience, query: query);

  @override
  Future<OrderRecord> updateCompanyOrder(
    int companyId,
    int orderId,
    SellerOrderUpdateRequest request,
  ) => _remoteDataSource.updateCompanyOrder(companyId, orderId, request);
}
