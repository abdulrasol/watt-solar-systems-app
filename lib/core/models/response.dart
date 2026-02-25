final resp = {
  "status": 200,
  "message": "Success",
  "body": [
    {
      "id": 4,
      "user_id": 3,
      "title": "Company Invitation",
      "body": "You have been added to 'PV Solar' as a manager.",
      "notification_type": "info",
      "is_read": false,
      "related_entity_type": "Company",
      "related_entity_id": "00000000-0000-0000-0000-000000000002",
      "created_at": "2026-02-23T22:06:13.899Z",
    },
    {
      "id": 3,
      "user_id": 1,
      "title": "New Company Registration",
      "body": "Company 'PV Solar' has registered and is pending approval.",
      "notification_type": "info",
      "is_read": false,
      "related_entity_type": "Company",
      "related_entity_id": "00000000-0000-0000-0000-000000000003",
      "created_at": "2026-02-23T19:25:18.971Z",
    },
    {
      "id": 2,
      "user_id": 1,
      "title": "New Company Registration",
      "body": "Company 'PV Solar' has registered and is pending approval.",
      "notification_type": "info",
      "is_read": false,
      "related_entity_type": "Company",
      "related_entity_id": "00000000-0000-0000-0000-000000000002",
      "created_at": "2026-02-23T19:23:32.943Z",
    },
    {
      "id": 1,
      "user_id": 1,
      "title": "New Company Registration",
      "body": "Company 'PV Solar' has registered and is pending approval.",
      "notification_type": "info",
      "is_read": false,
      "related_entity_type": "Company",
      "related_entity_id": "00000000-0000-0000-0000-000000000001",
      "created_at": "2026-02-23T17:18:27.401Z",
    },
  ],
  "error": null,
  "message_user": null,
};

class Response {
  final int status;
  final String message;
  final dynamic body;
  final String error;
  final String messageUser;

  Response({required this.status, required this.message, required this.body, required this.error, required this.messageUser});

  factory Response.fromJson(Map<String, dynamic> json) {
    return Response(status: json['status'], message: json['message'], body: json['body'], error: json['error'] ?? '', messageUser: json['message_user'] ?? '');
  }
}
