import 'dart:async';
import 'package:flutter/material.dart' show debugPrint;
import 'package:get/get.dart';
import 'package:solar_hub/services/supabase_service.dart';
import 'package:solar_hub/layouts/shared/chat/chat_page.dart'; // Import ChatPage
import 'package:solar_hub/layouts/company/requests/widgets/company_offer_details_sheet.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:solar_hub/utils/toast_service.dart';

class NotificationsController extends GetxController {
  final _dbService = SupabaseService();
  final notifications = <Map<String, dynamic>>[].obs;
  final isLoading = true.obs;
  final unreadCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    // Initial fetch
    if (_dbService.client.auth.currentUser != null) {
      fetchNotifications();
      _subscribeToNotifications();
    }

    // Listen to Auth Changes
    _dbService.client.auth.onAuthStateChange.listen((data) {
      if (data.event == AuthChangeEvent.signedIn) {
        fetchNotifications();
        _subscribeToNotifications();
      } else if (data.event == AuthChangeEvent.signedOut) {
        _subscription?.cancel(); // Stop listening
        notifications.clear();
        unreadCount.value = 0;
      }
    });
  }

  @override
  void onReady() {
    super.onReady();
    // Double check on ready to ensure data is loaded if session exists
    if (_dbService.client.auth.currentUser != null && notifications.isEmpty) {
      fetchNotifications();
      _subscribeToNotifications();
    }
  }

  Future<void> forceRefresh() async {
    isLoading.value = true;
    await fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    try {
      final user = _dbService.client.auth.currentUser;
      if (user == null) return;

      final response = await _dbService.client.from('notifications').select('*').eq('user_id', user.id).order('created_at', ascending: false).limit(50);

      notifications.assignAll(List<Map<String, dynamic>>.from(response));
      _updateUnreadCount();
    } catch (e) {
      debugPrint("Error fetching notifications: $e");
    } finally {
      isLoading.value = false;
    }
  }

  StreamSubscription? _subscription;

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }

  void _subscribeToNotifications() {
    _subscription?.cancel(); // Cancel potential existing one
    final user = _dbService.client.auth.currentUser;
    if (user == null) return;

    _subscription = _dbService.client
        .from('notifications')
        .stream(primaryKey: ['id'])
        .eq('user_id', user.id)
        .order('created_at')
        .listen(
          (data) {
            notifications.assignAll(data);
            notifications.sort((a, b) => DateTime.parse(b['created_at']).compareTo(DateTime.parse(a['created_at'])));
            _updateUnreadCount();
          },
          onError: (e) {
            debugPrint("Notification stream error: $e");
          },
        );
  }

  void _updateUnreadCount() {
    unreadCount.value = notifications.where((n) => n['is_read'] == false).length;
  }

  Future<void> markAsRead(String id) async {
    try {
      await _dbService.client.from('notifications').update({'is_read': true}).eq('id', id);
      // Local update
      final index = notifications.indexWhere((n) => n['id'] == id);
      if (index != -1) {
        notifications[index]['is_read'] = true;
        notifications.refresh();
        _updateUnreadCount();
      }
    } catch (e) {
      // print("Error marking read: $e");
      ToastService.error("Notification Error", "Could not mark as read. Check permissions.");
    }
  }

  Future<void> markAllAsRead() async {
    try {
      final user = _dbService.client.auth.currentUser;
      if (user == null) return;
      await _dbService.client.from('notifications').update({'is_read': true}).eq('user_id', user.id);
      for (var n in notifications) {
        n['is_read'] = true;
      }
      notifications.refresh();
      _updateUnreadCount();
    } catch (e) {
      // print("Error marking all read");
    }
  }

  Future<void> deleteNotification(String id) async {
    try {
      await _dbService.client.from('notifications').delete().eq('id', id);
      notifications.removeWhere((n) => n['id'] == id);
      _updateUnreadCount();
    } catch (e) {
      ToastService.error("Notification Error", "Could not delete. Check permissions.");
    }
  }

  Future<void> handleNotificationTap(Map<String, dynamic> notification) async {
    if (notification['is_read'] == false) {
      markAsRead(notification['id']);
    }

    final type = notification['type'];
    final entityId = notification['related_entity_id'];
    // Default entityType
    final entityType = notification['related_entity_type'] ?? (type == 'chat_message' ? 'offer' : null);

    if (entityId == null) return;

    if (type == 'chat_message') {
      // For chat message, entityId is the OFFER ID (or Order ID).
      // We open ChatPage.
      Get.to(() => ChatPage(entityId: entityId, entityType: entityType ?? 'offer', title: 'Chat'));
    } else if (type == 'offer_received' || entityType == 'offer') {
      // It's an offer notification. Open offer details.
      try {
        final offerRes = await _dbService.client.from('offers').select('*, offer_requests(title)').eq('id', entityId).maybeSingle();

        if (offerRes != null) {
          Get.bottomSheet(CompanyOfferDetailsSheet(offer: offerRes), isScrollControlled: true);
        }
      } catch (e) {
        // print("Error fetching offer for notification: $e");
      }
    }
  }
}
