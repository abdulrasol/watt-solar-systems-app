import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:solar_hub/services/supabase_service.dart';
import 'package:toastification/toastification.dart';

class ChatController extends GetxController {
  final _dbService = SupabaseService();

  final messages = <Map<String, dynamic>>[].obs;
  final isLoading = true.obs;
  final isSending = false.obs;
  StreamSubscription? _subscription;
  // Stream<List<Map<String, dynamic>>>? chatStream; // Not needed if we listen directly

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }

  String? currentEntityId;
  String? currentEntityType;

  // Open Chat for any entity
  void openChat(String entityId, String entityType) {
    currentEntityId = entityId;
    currentEntityType = entityType;
    messages.clear();
    isLoading.value = true;

    // Initial Fetch
    refreshMessages(entityId, entityType);
    fetchContext(entityId, entityType);

    // Subscribe
    // Subscribe
    // Cancel previous subscription if any
    _subscription?.cancel();

    // Subscribe
    _subscription = _dbService.client
        .from('replies')
        .stream(primaryKey: ['id'])
        .order('created_at')
        .map((maps) => maps.where((m) => m['entity_id'] == entityId && m['entity_type'] == entityType).toList())
        .listen(
          (data) {
            // sort again just in case, though DB order is robust, stream update order might vary
            data.sort((a, b) => DateTime.parse(a['created_at']).compareTo(DateTime.parse(b['created_at'])));
            messages.assignAll(data);
            isLoading.value = false;
          },
          onError: (e) {
            debugPrint("Chat stream error: $e");
          },
        );
  }

  Future<void> refreshMessages(String entityId, String entityType) async {
    try {
      final response = await _dbService.client
          .from('replies')
          .select('*')
          .eq('entity_id', entityId)
          .eq('entity_type', entityType)
          .order('created_at', ascending: true);

      messages.assignAll(List<Map<String, dynamic>>.from(response));
    } catch (e) {
      // debugPrint("Error fetching messages: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // Context Data
  final contextData = <String, dynamic>{}.obs;
  final isContextLoading = false.obs;

  Future<void> fetchContext(String entityId, String entityType) async {
    isContextLoading.value = true;
    try {
      if (entityType == 'offer') {
        final response = await _dbService.client.from('offers').select('*, offer_requests(title)').eq('id', entityId).single();
        contextData.assignAll(response);
      } else if (entityType == 'order') {
        final response = await _dbService.client.from('orders').select('*').eq('id', entityId).single();
        contextData.assignAll(response);
      } else if (entityType == 'system') {
        final response = await _dbService.client.from('solar_systems').select('*').eq('id', entityId).single();
        contextData.assignAll(response);
      }
    } catch (e) {
      // debugPrint("Error fetching context: $e");
    } finally {
      isContextLoading.value = false;
    }
  }

  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty || currentEntityId == null || currentEntityType == null) return;

    isSending.value = true;
    try {
      final user = _dbService.client.auth.currentUser;
      if (user == null) return;

      await _dbService.client.from('replies').insert({
        'entity_id': currentEntityId,
        'entity_type': currentEntityType,
        'sender_id': user.id,
        'content': content.trim(),
        'is_read': false,
      });

      // Notification Logic
      if (currentEntityType == 'offer') {
        await _handleOfferNotification(currentEntityId!, user.id);
      }
      // Add logic for 'order', 'system' notifications later
    } catch (e) {
      // debugPrint("Error sending reply: $e");
      toastification.show(
        title: Text('err_error'.tr),
        description: Text('reply_send_error'.tr),
        type: ToastificationType.error,
        style: ToastificationStyle.flat,
        autoCloseDuration: const Duration(seconds: 3),
      );
    } finally {
      isSending.value = false;
    }
  }

  Future<void> _handleOfferNotification(String offerId, String senderUserId) async {
    final offer = await _dbService.client.from('offers').select('company_id, request_id').eq('id', offerId).single();
    final request = await _dbService.client.from('offer_requests').select('user_id').eq('id', offer['request_id']).single();

    final companyId = offer['company_id'];
    final requestUserId = request['user_id'];

    // If current user is the requester (Customer), notify company members
    if (senderUserId == requestUserId) {
      final membersRes = await _dbService.client.from('company_members').select('user_id').eq('company_id', companyId);
      final members = List<Map<String, dynamic>>.from(membersRes);
      final notifications = members
          .map(
            (m) => {
              'user_id': m['user_id'],
              'title': 'New Message',
              'body': 'User sent a message on your offer.',
              'type': 'chat_message',
              'related_entity_id': offerId,
              'is_read': false,
            },
          )
          .toList();
      if (notifications.isNotEmpty) {
        await _dbService.client.from('notifications').insert(notifications);
      }
    } else {
      // Assume I am company member/admin, notify requester
      await _dbService.client.from('notifications').insert({
        'user_id': requestUserId,
        'title': 'New Message',
        'body': 'Company sent you a message.',
        'type': 'chat_message',
        'related_entity_id': offerId,
        'is_read': false,
      });
    }
  }
}
