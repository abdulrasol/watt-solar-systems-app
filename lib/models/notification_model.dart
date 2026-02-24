class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String body;
  final String type; // info, success, warning, error
  final bool isRead;
  final String? relatedEntityType;
  final String? relatedEntityId;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    this.type = 'info',
    this.isRead = false,
    this.relatedEntityType,
    this.relatedEntityId,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      type: json['type'] as String? ?? 'info',
      isRead: json['is_read'] as bool? ?? false,
      relatedEntityType: json['related_entity_type'] as String?,
      relatedEntityId: json['related_entity_id'] as String?,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'body': body,
      'type': type,
      'is_read': isRead,
      'related_entity_type': relatedEntityType,
      'related_entity_id': relatedEntityId,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
