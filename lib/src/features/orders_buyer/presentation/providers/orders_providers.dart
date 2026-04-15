import 'package:flutter_riverpod/flutter_riverpod.dart' show FutureProvider;
import 'package:flutter_riverpod/legacy.dart';
import 'package:solar_hub/src/core/di/get_it.dart';
import 'package:solar_hub/src/core/models/response.dart';
import 'package:solar_hub/src/features/orders_buyer/domain/repositories/orders_repository.dart';
import 'package:solar_hub/src/features/orders_core/domain/entities/order_models.dart';
import 'package:solar_hub/src/features/orders_core/domain/entities/order_queries.dart';

class OrdersListState {
  final bool isLoading;
  final bool isSubmitting;
  final String? error;
  final List<OrderRecord> items;
  final PaginationMeta pagination;
  final OrderListQuery query;

  const OrdersListState({
    this.isLoading = false,
    this.isSubmitting = false,
    this.error,
    this.items = const [],
    this.pagination = PaginationMeta.empty,
    this.query = const OrderListQuery(),
  });

  OrdersListState copyWith({
    bool? isLoading,
    bool? isSubmitting,
    String? error,
    bool clearError = false,
    List<OrderRecord>? items,
    PaginationMeta? pagination,
    OrderListQuery? query,
  }) {
    return OrdersListState(
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: clearError ? null : (error ?? this.error),
      items: items ?? this.items,
      pagination: pagination ?? this.pagination,
      query: query ?? this.query,
    );
  }
}

class BuyerOrdersController extends StateNotifier<OrdersListState> {
  final OrderAudience audience;
  final OrdersRepository _repository;

  BuyerOrdersController(this.audience, this._repository)
    : super(const OrdersListState(isLoading: true)) {
    fetchOrders();
  }

  Future<void> fetchOrders({OrderListQuery? query}) async {
    state = state.copyWith(
      isLoading: true,
      query: query ?? state.query,
      clearError: true,
    );
    try {
      final response = await _repository.listMyOrders(
        audience,
        query: state.query,
      );
      state = state.copyWith(
        isLoading: false,
        items: response.items,
        pagination: response.pagination,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<OrderRecord?> cancelOrder(int orderId) async {
    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      final updated = await _repository.cancelMyOrder(audience, orderId);
      state = state.copyWith(
        isSubmitting: false,
        items: state.items.map((e) => e.id == orderId ? updated : e).toList(),
      );
      return updated;
    } catch (e) {
      state = state.copyWith(isSubmitting: false, error: e.toString());
      return null;
    }
  }

  Future<OrderRecord?> confirmReceipt(int orderId) async {
    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      final updated = await _repository.confirmB2bReceipt(orderId);
      state = state.copyWith(
        isSubmitting: false,
        items: state.items.map((e) => e.id == orderId ? updated : e).toList(),
      );
      return updated;
    } catch (e) {
      state = state.copyWith(isSubmitting: false, error: e.toString());
      return null;
    }
  }
}

final buyerOrdersProvider =
    StateNotifierProvider.family<
      BuyerOrdersController,
      OrdersListState,
      OrderAudience
    >((ref, audience) {
      return BuyerOrdersController(audience, getIt<OrdersRepository>());
    });

final buyerOrderDetailProvider =
    FutureProvider.family<OrderRecord, ({OrderAudience audience, int orderId})>(
      (ref, args) =>
          getIt<OrdersRepository>().getMyOrder(args.audience, args.orderId),
    );

class CompanyOrdersController extends StateNotifier<OrdersListState> {
  final int companyId;
  final OrdersRepository _repository;

  CompanyOrdersController(this.companyId, this._repository)
    : super(const OrdersListState(isLoading: true)) {
    fetchOrders();
  }

  Future<void> fetchOrders({OrderListQuery? query}) async {
    state = state.copyWith(
      isLoading: true,
      query: query ?? state.query,
      clearError: true,
    );
    try {
      final response = await _repository.listCompanyOrders(
        companyId,
        query: state.query,
      );
      state = state.copyWith(
        isLoading: false,
        items: response.items,
        pagination: response.pagination,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> updateFilters(OrderListQuery query) async {
    await fetchOrders(query: query);
  }

  Future<OrderRecord?> updateOrder(
    int orderId,
    SellerOrderUpdateRequest request,
  ) async {
    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      final updated = await _repository.updateCompanyOrder(
        companyId,
        orderId,
        request,
      );
      state = state.copyWith(
        isSubmitting: false,
        items: state.items.map((e) => e.id == orderId ? updated : e).toList(),
      );
      return updated;
    } catch (e) {
      state = state.copyWith(isSubmitting: false, error: e.toString());
      return null;
    }
  }
}

final companyOrdersProvider =
    StateNotifierProvider.family<CompanyOrdersController, OrdersListState, int>(
      (ref, companyId) {
        return CompanyOrdersController(companyId, getIt<OrdersRepository>());
      },
    );

final companyOrderDetailProvider =
    FutureProvider.family<OrderRecord, ({int companyId, int orderId})>(
      (ref, args) => getIt<OrdersRepository>().getCompanyOrder(
        args.companyId,
        args.orderId,
      ),
    );
