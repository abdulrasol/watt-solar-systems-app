import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;
  SupabaseClient get client => _client;

  // --- Generic Pagination Helper ---
  Future<List<Map<String, dynamic>>> fetchPaginated({
    required String table,
    required int page,
    required int pageSize,
    String orderBy = 'created_at',
    bool ascending = false,
    Map<String, dynamic>? filters,
  }) async {
    final from = (page - 1) * pageSize;
    final to = from + pageSize - 1;

    var query = _client.from(table).select();

    if (filters != null) {
      filters.forEach((key, value) {
        query = query.eq(key, value);
      });
    }

    // range returns a FilterTransformBuilder, so we chain it at the end
    final response = await query.order(orderBy, ascending: ascending).range(from, to);
    logResponse('fetchPaginated($table)', response);
    return List<Map<String, dynamic>>.from(response);
  }

  // --- Specific Fetch Methods ---

  Future<List<Map<String, dynamic>>> fetchPosts(int page, int pageSize) async {
    final from = (page - 1) * pageSize;
    final to = from + pageSize - 1;

    final response = await _client
        .from('posts')
        .select('*, profiles(full_name, avatar_url, phone_number)') // Join with profiles
        .order('created_at', ascending: false)
        .range(from, to);

    logResponse('fetchPosts', 'posts: ${response.length}');
    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> fetchComments(String postId) async {
    final response = await _client
        .from('comments')
        .select('*, profiles(full_name, avatar_url, phone_number)')
        .eq('post_id', postId)
        .order('created_at', ascending: true);
    logResponse('fetchComments', response);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>> createComment(Map<String, dynamic> data) async {
    // We select profiles to get the author info immediately for the UI
    final response = await _client.from('comments').insert(data).select('*, profiles(full_name, avatar_url, phone_number)').single();
    logResponse('createComment', response);
    return response;
  }

  // --- Notifications ---

  Future<List<Map<String, dynamic>>> fetchNotifications(String userId) async {
    final response = await _client.from('notifications').select().eq('user_id', userId).order('created_at', ascending: false).limit(20);
    logResponse('fetchNotifications', response);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> markNotificationRead(String notificationId) async {
    await _client.from('notifications').update({'is_read': true}).eq('id', notificationId);
    logResponse('markNotificationRead', 'Success for $notificationId');
  }

  Future<void> createPost(Map<String, dynamic> data) async {
    final response = await _client.from('posts').insert(data);
    logResponse('createPost', response);
  }

  Future<List<Map<String, dynamic>>> fetchSystems(int page, int pageSize) async {
    return fetchPaginated(table: 'systems', page: page, pageSize: pageSize);
  }

  /// Securely reduces stock using database RPC.
  /// Throws exception if operation fails.
  Future<void> rpcReduceStock({required String productId, required int quantitySold}) async {
    try {
      await _client.rpc('reduce_stock_secure', params: {'p_product_id': productId, 'p_quantity_sold': quantitySold});
      logResponse('rpcReduceStock', 'Reduced $quantitySold for $productId');
    } catch (e) {
      logError('rpcReduceStock', e);
      rethrow;
    }
  }

  // --- Logging Helper ---
  void logResponse(String operation, dynamic response) {
    // print('server @$operation: $response');
  }

  void logError(String operation, dynamic error) {
    // print('server error @$operation: $error');
  }

  // --- Auth Helper ---
  User? get currentUser => _client.auth.currentUser;
}
