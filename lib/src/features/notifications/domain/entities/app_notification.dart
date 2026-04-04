class AppNotificationItem {
  final int id;
  final String title;
  final String body;
  final Map<String, dynamic> data;
  final String type;
  final String status;
  final DateTime createdAt;
  final DateTime? sentAt;

  const AppNotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.data,
    required this.type,
    required this.status,
    required this.createdAt,
    this.sentAt,
  });

  factory AppNotificationItem.fromJson(Map<String, dynamic> json) {
    return AppNotificationItem(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      data: Map<String, dynamic>.from(json['data'] ?? const {}),
      type: json['type'] ?? '',
      status: json['status'] ?? '',
      createdAt:
          DateTime.tryParse(json['created_at'] ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      sentAt: json['sent_at'] != null
          ? DateTime.tryParse(json['sent_at'])
          : null,
    );
  }
}
