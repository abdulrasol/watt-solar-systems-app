import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:watt/src/features/company_dashboard/domain/entities/activity_log_item.dart';
import 'package:watt/src/features/inventory/presentation/providers/inventory_provider.dart';
import 'package:watt/src/features/offers/presentation/providers/offers_provider.dart';
import 'package:watt/src/features/notifications/presentation/controllers/notification_history_controller.dart';

/// IMPORTANT: [ActivityLogItem.fromJson] exists (it parses `action_type`,
/// `entity_type`, `entity_id`, `created_at`), which looks like it was built
/// expecting a real `GET /companies/{id}/activity` backend endpoint — but
/// that endpoint does not exist anywhere in the Django Ninja API (verified
/// by reading the full `companies` app router). `AppUrls.companyActivity()`
/// is therefore a dead helper pointing at a 404.
///
/// Until/unless that backend endpoint is built, this provider synthesizes
/// a "recent activity" feed client-side from data the app already has
/// loaded for other screens (last 5 products, last 5 open offer requests,
/// last 5 read/unread notifications), sorted by time and capped at 10. It
/// is an approximation, not a real audit log — it won't show things like
/// member-role changes, order-status updates, or payments, and it can't be
/// paginated past what's already loaded elsewhere in memory.

class CompanyActivityState {
  final bool isLoading;
  final String? error;
  final List<ActivityLogItem> items;

  const CompanyActivityState({
    this.isLoading = false,
    this.error,
    this.items = const [],
  });
}

final companyActivityFeedProvider = Provider<CompanyActivityState>((ref) {
  final inventoryState = ref.watch(inventoryNotifierProvider);
  final offersState = ref.watch(offersProvider);
  final notificationState = ref.watch(notificationHistoryProvider);

  final isLoading = inventoryState.isLoading ||
      offersState.isLoading ||
      notificationState.isLoading;

  final items = <ActivityLogItem>[];

  for (final product in inventoryState.products.take(5)) {
    items.add(ActivityLogItem(
      id: product.id,
      title: 'New product added',
      subtitle: '${product.name} was added to inventory',
      actionType: ActivityActionType.productAdded,
      createdAt: product.createdAt,
      entityType: 'product',
      entityId: product.id,
    ));
  }

  for (final request in offersState.availableRequests.take(5)) {
    final rid = request.id ?? 0;
    items.add(ActivityLogItem(
      id: rid,
      title: 'Offer request received',
      subtitle: request.note ?? 'Solar Request #$rid',
      actionType: ActivityActionType.offerCreated,
      createdAt: request.createdAt ?? DateTime.now(),
      entityType: 'offer',
      entityId: rid,
    ));
  }

  for (final notification in notificationState.items
      .where((n) => n.status == 'read' || n.status == 'unread')
      .take(5)) {
    items.add(ActivityLogItem(
      id: notification.id,
      title: notification.title,
      subtitle: notification.body,
      actionType: ActivityActionType.unknown,
      createdAt: notification.createdAt,
      entityType: 'notification',
      entityId: notification.id,
    ));
  }

  items.sort((a, b) => b.createdAt.compareTo(a.createdAt));

  return CompanyActivityState(
    isLoading: isLoading && items.isEmpty,
    items: items.take(10).toList(),
  );
});
