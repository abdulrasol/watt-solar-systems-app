abstract class BaseResponse {
  dynamic body;
  int status = 0;
  String message = '';
  bool error = false;
  String messageUser = '';

  @override
  String toString() {
    return 'BaseResponse(body: $body, status: $status, message: $message, error: $error, messageUser: $messageUser)';
  }
}

/// Standard API response with status, message, body, error, message_user
/// Example: {"status": 200, "message": "...", "body": {...}, "error": false, "message_user": null}
class Response extends BaseResponse {
  Response({required int status, required String message, required dynamic body, required bool error, required String messageUser}) {
    this.status = status;
    this.message = message;
    this.body = body;
    this.error = error;
    this.messageUser = messageUser;
  }

  factory Response.fromJson(Map<String, dynamic> json) {
    return Response(
      status: json['status'] ?? 0,
      message: json['message'] ?? '',
      body: json['body'],
      error: json['error'] ?? false,
      messageUser: json['message_user'] ?? '',
    );
  }
}

/// Paginated API response with items list and count
/// Example: {"items": [...], "count": 8}
class PaginationResponse extends BaseResponse {
  final int? count;

  PaginationResponse({this.count, required List body}) {
    this.body = body;
    status = 200;
    message = '';
    error = false;
    messageUser = '';
  }

  factory PaginationResponse.fromJson(Map<String, dynamic> json) {
    return PaginationResponse(count: json['count'], body: json['items'] as List);
  }
}

/// Raw list API response (server returns a plain JSON array)
/// Example: [{...}, {...}, ...]
class ListResponse extends BaseResponse {
  ListResponse({required List body}) {
    this.body = body;
    status = 200;
    message = '';
    error = false;
    messageUser = '';
  }

  /// Creates a ListResponse directly from a List (not a Map)
  factory ListResponse.fromList(List data) {
    return ListResponse(body: data);
  }
}
