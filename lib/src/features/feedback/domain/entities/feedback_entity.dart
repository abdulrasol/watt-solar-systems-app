import 'package:cloud_firestore/cloud_firestore.dart';

class FeedbackEntity {
  final String? id;
  final String name;
  final String? phoneNumber;
  final String message;
  final String? imageData; // Base64 encoded image string
  final DateTime createdAt;
  final bool isRead;

  FeedbackEntity({this.id, required this.name, this.phoneNumber, required this.message, this.imageData, required this.createdAt, this.isRead = false});

  factory FeedbackEntity.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FeedbackEntity(
      id: doc.id,
      name: data['name'] ?? '',
      phoneNumber: data['phoneNumber'],
      message: data['message'] ?? '',
      imageData: data['imageData'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      isRead: data['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {'name': name, 'phoneNumber': phoneNumber, 'message': message, 'imageData': imageData, 'createdAt': Timestamp.fromDate(createdAt), 'isRead': isRead};
  }

  FeedbackEntity copyWith({String? id, String? name, String? phoneNumber, String? message, String? imageData, DateTime? createdAt, bool? isRead}) {
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
