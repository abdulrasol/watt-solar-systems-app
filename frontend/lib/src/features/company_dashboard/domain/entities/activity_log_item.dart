import 'package:solar_hub/src/core/utils/date_parser.dart';

enum ActivityActionType {
  productAdded,
  productUpdated,
  offerCreated,
  offerAccepted,
  offerUpdated,
  memberJoined,
  memberInvited,
  orderPlaced,
  orderUpdated,
  contactAdded,
  invoiceCreated,
  paymentReceived,
  unknown,
}

class ActivityLogItem {
  final int id;
  final String title;
  final String subtitle;
  final ActivityActionType actionType;
  final DateTime createdAt;
  final String? entityType;
  final int? entityId;

  const ActivityLogItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.actionType,
    required this.createdAt,
    this.entityType,
    this.entityId,
  });

  factory ActivityLogItem.fromJson(Map<String, dynamic> json) {
    return ActivityLogItem(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? json['description'] ?? '',
      actionType: _parseActionType(json['action_type']?.toString()),
      createdAt: safeParseDate(json['created_at']) ?? DateTime.now(),
      entityType: json['entity_type']?.toString(),
      entityId: json['entity_id'],
    );
  }

  static ActivityActionType _parseActionType(String? value) {
    switch (value?.toLowerCase()) {
      case 'product_added':
        return ActivityActionType.productAdded;
      case 'product_updated':
        return ActivityActionType.productUpdated;
      case 'offer_created':
        return ActivityActionType.offerCreated;
      case 'offer_accepted':
        return ActivityActionType.offerAccepted;
      case 'offer_updated':
        return ActivityActionType.offerUpdated;
      case 'member_joined':
        return ActivityActionType.memberJoined;
      case 'member_invited':
        return ActivityActionType.memberInvited;
      case 'order_placed':
        return ActivityActionType.orderPlaced;
      case 'order_updated':
        return ActivityActionType.orderUpdated;
      case 'contact_added':
        return ActivityActionType.contactAdded;
      case 'invoice_created':
        return ActivityActionType.invoiceCreated;
      case 'payment_received':
        return ActivityActionType.paymentReceived;
      default:
        return ActivityActionType.unknown;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'action_type': actionType.name,
      'created_at': createdAt.toIso8601String(),
      'entity_type': entityType,
      'entity_id': entityId,
    };
  }
}
