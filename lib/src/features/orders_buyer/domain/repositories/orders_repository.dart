import 'package:solar_hub/src/core/models/response.dart';
import 'package:solar_hub/src/features/orders_core/domain/entities/order_models.dart';
import 'package:solar_hub/src/features/orders_core/domain/entities/order_queries.dart';

abstract class OrdersRepository {
  Future<OrderRecord> createB2cOrder(B2cOrderCreateRequest request);
  Future<OrderRecord> createB2bOrder(B2bOrderCreateRequest request);
  Future<PaginatedItemsResponse<OrderRecord>> listMyOrders(
    OrderAudience audience, {
    OrderListQuery query = const OrderListQuery(),
  });
  Future<OrderRecord> getMyOrder(OrderAudience audience, int orderId);
  Future<OrderRecord> cancelMyOrder(OrderAudience audience, int orderId);
  Future<OrderRecord> confirmB2bReceipt(int orderId);
  Future<PaginatedItemsResponse<OrderRecord>> listCompanyOrders(
    int companyId, {
    OrderListQuery query = const OrderListQuery(),
  });
  Future<OrderRecord> getCompanyOrder(int companyId, int orderId);
  Future<OrderRecord> updateCompanyOrder(
    int companyId,
    int orderId,
    SellerOrderUpdateRequest request,
  );
}
