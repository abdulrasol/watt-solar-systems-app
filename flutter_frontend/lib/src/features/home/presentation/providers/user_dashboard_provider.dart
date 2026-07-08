import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:watt/src/core/di/get_it.dart';
import 'package:watt/src/core/services/dio.dart';
import 'package:watt/src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:watt/src/utils/app_urls.dart';

class UserDashboardSummary {
  final int requestCount;
  final int orderCount;
  final int notificationCount;

  const UserDashboardSummary({
    this.requestCount = 0,
    this.orderCount = 0,
    this.notificationCount = 0,
  });
}

final userDashboardSummaryProvider = FutureProvider<UserDashboardSummary>((
  ref,
) async {
  final authState = ref.watch(authProvider);
  if (!authState.isSigned) {
    return const UserDashboardSummary();
  }

  final dio = getIt<DioService>();

  Future<int> countFromBody(String url) async {
    final response = await dio.getRawMap(
      url,
      queryParameters: const {'page': 1, 'page_size': 1},
    );
    final body = Map<String, dynamic>.from(
      response['body'] ?? const <String, dynamic>{},
    );

    final pagination = body['pagination'];
    if (pagination is Map<String, dynamic>) {
      return int.tryParse(pagination['total_items']?.toString() ?? '') ?? 0;
    }

    return int.tryParse(body['count']?.toString() ?? '') ?? 0;
  }

  final results = await Future.wait<int>([
    countFromBody(AppUrls.userRequests),
    countFromBody(AppUrls.b2cMyOrders),
    countFromBody(AppUrls.notificationHistory),
  ]);

  return UserDashboardSummary(
    requestCount: results[0],
    orderCount: results[1],
    notificationCount: results[2],
  );
});
