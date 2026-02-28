import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:solar_hub/controllers/notifications_controller.dart';

import 'package:solar_hub/layouts/company/notifications/widgets/notification_card.dart';
import 'package:icons_plus/icons_plus.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NotificationsController());

    return Scaffold(
      appBar: AppBar(
        title: Text('notifications'.tr),
        actions: [IconButton(icon: const Icon(Icons.done_all), onPressed: () => controller.markAllAsRead(), tooltip: 'mark_all_read'.tr)],
      ),
      body: RefreshIndicator(
        onRefresh: controller.forceRefresh,
        child: Obx(() {
          if (controller.isLoading.value && controller.notifications.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.notifications.isEmpty) {
            return ListView(
              children: [
                SizedBox(height: Get.height * 0.3),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Iconsax.notification_bing_bold, size: 64, color: Colors.grey.withValues(alpha: 0.5)),
                      const SizedBox(height: 16),
                      Text('no_notifications'.tr, style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
                    ],
                  ),
                ),
              ],
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: controller.notifications.length,
            itemBuilder: (context, index) {
              final notification = controller.notifications[index];
              return NotificationCard(
                notification: notification,
                onTap: () => controller.handleNotificationTap(notification),
                onDelete: () => controller.deleteNotification(notification['id']),
                onMarkRead: () => controller.markAsRead(notification['id']),
              );
            },
          );
        }),
      ),
    );
  }
}
