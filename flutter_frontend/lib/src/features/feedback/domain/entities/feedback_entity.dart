class FeedbackEntity {
  final String? id;
  final String name;
  final String? phoneNumber;
  final String message;
  final String? imageData;
  final DateTime createdAt;
  final bool isRead;

  FeedbackEntity({
    this.id,
    required this.name,
    this.phoneNumber,
    required this.message,
    this.imageData,
    required this.createdAt,
    this.isRead = false,
  });

  factory FeedbackEntity.fromJson(Map<String, dynamic> json) {
    final rawPhoneNumber = json['phone_number'] ?? json['phoneNumber'];
    final rawCreatedAt = json['created_at'] ?? json['createdAt'];

    return FeedbackEntity(
      id: json['id']?.toString(),
      name: (json['name'] ?? '').toString(),
      phoneNumber:
          rawPhoneNumber == null || rawPhoneNumber.toString().trim().isEmpty
          ? null
          : rawPhoneNumber.toString(),
      message: (json['message'] ?? '').toString(),
      imageData: _normalizeImage(json['image'] ?? json['imageData']),
      createdAt:
          DateTime.tryParse(rawCreatedAt?.toString() ?? '')?.toLocal() ??
          DateTime.now(),
      isRead: json['is_read'] == true || json['isRead'] == true,
    );
  }

  static String? _normalizeImage(dynamic value) {
    if (value == null) return null;
    final normalized = value.toString().trim();
    return normalized.isEmpty ? null : normalized;
  }

  FeedbackEntity copyWith({
    String? id,
    String? name,
    String? phoneNumber,
    String? message,
    String? imageData,
    DateTime? createdAt,
    bool? isRead,
  }) {
    return FeedbackEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      message: message ?? this.message,
      imageData: imageData ?? this.imageData,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
    );
  }
}
