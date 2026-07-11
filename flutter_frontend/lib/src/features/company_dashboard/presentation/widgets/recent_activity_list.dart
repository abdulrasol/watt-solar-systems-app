import 'package:watt/src/core/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:watt/l10n/app_localizations.dart';
import 'package:watt/src/features/company_dashboard/domain/entities/activity_log_item.dart';
import 'package:watt/src/features/company_dashboard/presentation/providers/company_activity_provider.dart';
import 'package:watt/src/utils/app_theme.dart';

class RecentActivityList extends ConsumerWidget {
  const RecentActivityList({super.key});

  IconData _iconForType(ActivityActionType type) {
    switch (type) {
      case ActivityActionType.productAdded:
      case ActivityActionType.productUpdated:
        return Iconsax.box_add;
      case ActivityActionType.offerCreated:
      case ActivityActionType.offerAccepted:
      case ActivityActionType.offerUpdated:
        return Iconsax.document_text;
      case ActivityActionType.memberJoined:
      case ActivityActionType.memberInvited:
        return Iconsax.user_add;
      case ActivityActionType.orderPlaced:
      case ActivityActionType.orderUpdated:
        return Iconsax.shopping_cart;
      case ActivityActionType.contactAdded:
        return Iconsax.call;
      case ActivityActionType.invoiceCreated:
      case ActivityActionType.paymentReceived:
        return Iconsax.money_2;
      default:
        return Iconsax.info_circle;
    }
  }

  Color _colorForType(ActivityActionType type) {
    switch (type) {
      case ActivityActionType.productAdded:
      case ActivityActionType.productUpdated:
        return Colors.blue;
      case ActivityActionType.offerCreated:
      case ActivityActionType.offerAccepted:
      case ActivityActionType.offerUpdated:
        return Colors.green;
      case ActivityActionType.memberJoined:
      case ActivityActionType.memberInvited:
        return Colors.orange;
      case ActivityActionType.orderPlaced:
      case ActivityActionType.orderUpdated:
        return Colors.purple;
      case ActivityActionType.contactAdded:
        return Colors.teal;
      case ActivityActionType.invoiceCreated:
      case ActivityActionType.paymentReceived:
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }

  String _timeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dateTime.day}/${dateTime.month}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(companyActivityFeedProvider);
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Note: there is no backend "activity log" endpoint (confirmed —
          // `/companies/{id}/activity` doesn't exist server-side despite an
          // AppUrls helper for it). This list is a client-side aggregation
          // of the most recent inventory/offers/notification items already
          // loaded elsewhere in the app, not a dedicated audit trail. A
          // "View all" link used to point at a route
          // (`/companies/dashboard/activity`) that was never registered —
          // removed rather than left as a dead link, since there's also
          // nothing further to page into: the data isn't server-paginated.
          Text(
            l10n.recent_activity,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, fontFamily: AppTheme.fontFamily),
          ),
          SizedBox(height: 16),
          if (state.isLoading)
            const Center(
              child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator(strokeWidth: 2)),
            )
          else if (state.items.isEmpty)
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  l10n.no_data_available,
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ),
            )
          else
            ...List.generate(state.items.length, (index) {
              final item = state.items[index];
              return Column(children: [if (index > 0) const Divider(), _buildActivityItem(context, item)]);
            }),
        ],
      ),
    );
  }

  Widget _buildActivityItem(BuildContext context, ActivityLogItem item) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: InkWell(
        onTap: () {
          final route = _routeForItem(item);
          if (route != null) context.push(route);
        },
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(color: _colorForType(item.actionType).withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(_iconForType(item.actionType), color: _colorForType(item.actionType), size: 20),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, fontFamily: AppTheme.fontFamily),
                  ),
                  Text(
                    item.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey, fontSize: 12, fontFamily: AppTheme.fontFamily),
                  ),
                ],
              ),
            ),
            Text(
              _timeAgo(item.createdAt),
              style: TextStyle(color: Colors.grey, fontSize: 11, fontFamily: AppTheme.fontFamily),
            ),
          ],
        ),
      ),
    );
  }

  String? _routeForItem(ActivityLogItem item) {
    switch (item.actionType) {
      case ActivityActionType.productAdded:
      case ActivityActionType.productUpdated:
        return AppRoutes.companyInventoryProducts;
      case ActivityActionType.offerCreated:
      case ActivityActionType.offerAccepted:
      case ActivityActionType.offerUpdated:
        return '/offers';
      case ActivityActionType.memberJoined:
      case ActivityActionType.memberInvited:
        return '/members';
      case ActivityActionType.orderPlaced:
      case ActivityActionType.orderUpdated:
        return '/companies/dashboard/orders';
      case ActivityActionType.contactAdded:
        return '/companies/dashboard/contacts';
      case ActivityActionType.invoiceCreated:
      case ActivityActionType.paymentReceived:
        return '/companies/dashboard/accounting';
      default:
        return null;
    }
  }
}
