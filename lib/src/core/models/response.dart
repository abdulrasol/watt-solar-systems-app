import 'package:solar_hub/src/utils/helper_methods.dart';

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
  Response({
    required int status,
    required String message,
    required dynamic body,
    required bool error,
    required String messageUser,
  }) {
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

class PaginationMeta {
  final int page;
  final int pageSize;
  final int totalItems;
  final int totalPages;
  final bool hasNext;
  final bool hasPrevious;

  const PaginationMeta({
    required this.page,
    required this.pageSize,
    required this.totalItems,
    required this.totalPages,
    required this.hasNext,
    required this.hasPrevious,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic>? json) {
    final data = json ?? const <String, dynamic>{};
    return PaginationMeta(
      page: data['page'] ?? 1,
      pageSize: data['page_size'] ?? 0,
      totalItems: data['total_items'] ?? data['count'] ?? 0,
      totalPages: data['total_pages'] ?? 1,
      hasNext: data['has_next'] ?? false,
      hasPrevious: data['has_previous'] ?? false,
    );
  }

  static const empty = PaginationMeta(
    page: 1,
    pageSize: 0,
    totalItems: 0,
    totalPages: 1,
    hasNext: false,
    hasPrevious: false,
  );
}

/// Paginated API response with items list and count
/// Example: {"items": [...], "count": 8}
class PaginationResponse extends BaseResponse {
  final int? count;
  final PaginationMeta pagination;

  PaginationResponse({
    this.count,
    this.pagination = PaginationMeta.empty,
    required List body,
    int status = 200,
    String message = '',
    bool error = false,
    String messageUser = '',
  }) {
    this.body = body;
    this.status = status;
    this.message = message;
    this.error = error;
    this.messageUser = messageUser;
  }

  factory PaginationResponse.fromJson(Map<String, dynamic> json) {
    // Standard wrapper structure: {"status": 200, "body": {"items": [...], "count": 6}, ...}
    final dynamic bodyData = json['body'];
    List items = [];
    int? count;
    PaginationMeta pagination = PaginationMeta.empty;

    if (bodyData is Map) {
      dPrint('Found wrapped body (Map)', tag: 'PaginationResponse');
      items = bodyData['items'] as List? ?? [];
      pagination = PaginationMeta.fromJson(
        bodyData['pagination'] as Map<String, dynamic>?,
      );
      count =
          bodyData['count'] ?? bodyData['total_items'] ?? pagination.totalItems;
    } else if (bodyData is List) {
      dPrint(
        'Found wrapped body (List): ${bodyData.length}',
        tag: 'PaginationResponse',
      );
      items = bodyData;
      count = bodyData.length;
    } else if (json['items'] is List) {
      dPrint('Found flat items list', tag: 'PaginationResponse');
      // Fallback for flat structure: {"items": [...], "count": 6}
      items = json['items'] as List;
      count = json['count'];
    } else {
      dPrint(
        'Warning: No items found in JSON structure',
        tag: 'PaginationResponse',
      );
    }

    return PaginationResponse(
      status: json['status'] ?? 200,
      message: json['message'] ?? '',
      error: json['error'] ?? false,
      messageUser: json['message_user'] ?? '',
      count: count,
      pagination: pagination,
      body: items,
    );
  }
}

class PaginatedItemsResponse<T> extends BaseResponse {
  final List<T> items;
  final PaginationMeta pagination;

  PaginatedItemsResponse({
    required this.items,
    required this.pagination,
    required int status,
    required String message,
    required bool error,
    required String messageUser,
  }) {
    body = items;
    this.status = status;
    this.message = message;
    this.error = error;
    this.messageUser = messageUser;
  }

  factory PaginatedItemsResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic> itemJson) itemFromJson,
  ) {
    final bodyData =
        json['body'] as Map<String, dynamic>? ?? const <String, dynamic>{};
    final rawItems = bodyData['items'] as List? ?? const [];
    final items = rawItems
        .whereType<Map>()
        .map((item) => itemFromJson(Map<String, dynamic>.from(item)))
        .toList();

    return PaginatedItemsResponse<T>(
      items: items,
      pagination: PaginationMeta.fromJson(
        bodyData['pagination'] as Map<String, dynamic>?,
      ),
      status: json['status'] ?? 0,
      message: json['message'] ?? '',
      error: json['error'] == true,
      messageUser: json['message_user'] ?? '',
    );
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
