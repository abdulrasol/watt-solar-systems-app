import 'package:solar_hub/src/core/models/response.dart';
import 'package:solar_hub/src/core/services/dio.dart';
import 'package:solar_hub/src/features/orders_core/domain/entities/order_models.dart';
import 'package:solar_hub/src/features/orders_core/domain/entities/order_queries.dart';
import 'package:solar_hub/src/utils/app_urls.dart';

abstract class OrdersRemoteDataSource {
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

class OrdersRemoteDataSourceImpl implements OrdersRemoteDataSource {
  final DioService _dioService;

  OrdersRemoteDataSourceImpl(this._dioService);

  @override
  Future<OrderRecord> createB2cOrder(B2cOrderCreateRequest request) async {
    final response = await _dioService.post(
      AppUrls.b2cOrders,
      data: request.toJson(),
    );
    return OrderRecord.fromJson(
      Map<String, dynamic>.from(response.body as Map),
    );
  }

  @override
  Future<OrderRecord> createB2bOrder(B2bOrderCreateRequest request) async {
    final response = await _dioService.post(
      AppUrls.b2bOrders,
      data: request.toJson(),
    );
    return OrderRecord.fromJson(
      Map<String, dynamic>.from(response.body as Map),
    );
  }

  @override
  Future<PaginatedItemsResponse<OrderRecord>> listMyOrders(
    OrderAudience audience, {
    OrderListQuery query = const OrderListQuery(),
  }) async {
    final response = await _dioService.getRawMap(
      audience == OrderAudience.b2b ? AppUrls.b2bMyOrders : AppUrls.b2cMyOrders,
      queryParameters: query.toQueryParameters(),
    );
    return PaginatedItemsResponse<OrderRecord>.fromJson(
      response,
      OrderRecord.fromJson,
    );
  }

  @override
  Future<OrderRecord> getMyOrder(OrderAudience audience, int orderId) async {
    final response =
        await _dioService.get(
              audience == OrderAudience.b2b
                  ? AppUrls.b2bMyOrder(orderId)
                  : AppUrls.b2cMyOrder(orderId),
            )
            as Response;
    return OrderRecord.fromJson(
      Map<String, dynamic>.from(response.body as Map),
    );
  }

  @override
  Future<OrderRecord> cancelMyOrder(OrderAudience audience, int orderId) async {
    final response = await _dioService.post(
      audience == OrderAudience.b2b
          ? AppUrls.cancelB2bMyOrder(orderId)
          : AppUrls.cancelB2cMyOrder(orderId),
    );
    return OrderRecord.fromJson(
      Map<String, dynamic>.from(response.body as Map),
    );
  }

  @override
  Future<OrderRecord> confirmB2bReceipt(int orderId) async {
    final response = await _dioService.post(
      AppUrls.confirmB2bMyOrderReceipt(orderId),
    );
    return OrderRecord.fromJson(
      Map<String, dynamic>.from(response.body as Map),
    );
  }

  @override
  Future<PaginatedItemsResponse<OrderRecord>> listCompanyOrders(
    int companyId, {
    OrderListQuery query = const OrderListQuery(),
  }) async {
    final response = await _dioService.getRawMap(
      AppUrls.orders(companyId),
      queryParameters: query.toQueryParameters(),
    );
    return PaginatedItemsResponse<OrderRecord>.fromJson(
      response,
      OrderRecord.fromJson,
    );
  }

  @override
  Future<OrderRecord> getCompanyOrder(int companyId, int orderId) async {
    final response =
        await _dioService.get(AppUrls.order(companyId, orderId)) as Response;
    return OrderRecord.fromJson(
      Map<String, dynamic>.from(response.body as Map),
    );
  }

  @override
  Future<OrderRecord> updateCompanyOrder(
    int companyId,
    int orderId,
    SellerOrderUpdateRequest request,
  ) async {
    final response = await _dioService.put(
      AppUrls.order(companyId, orderId),
      data: request.toJson(),
    );
    return OrderRecord.fromJson(
      Map<String, dynamic>.from(response.body as Map),
    );
  }
}
