import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationCard extends StatelessWidget {
  final Map<String, dynamic> notification;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onMarkRead;

  const NotificationCard({super.key, required this.notification, required this.onTap, required this.onDelete, required this.onMarkRead});

  @override
  Widget build(BuildContext context) {
    final bool isRead = notification['is_read'] ?? false;
    final String type = notification['type'] ?? 'info';
    final DateTime createdAt = DateTime.tryParse(notification['created_at']) ?? DateTime.now();

    // Theme adaptation
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final Color unreadBgColor = isDark ? Colors.blue.withValues(alpha: 0.1) : Colors.blue.withValues(alpha: 0.05);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isRead ? cardColor : unreadBgColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [if (!isDark) BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
        border: Border.all(color: isRead ? Colors.transparent : Theme.of(context).primaryColor.withValues(alpha: 0.3), width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon Area
                _buildIcon(type, context),
                const SizedBox(width: 16),
                // Content Area
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              notification['title'] ?? 'Notification',
                              style: TextStyle(
                                fontWeight: isRead ? FontWeight.w600 : FontWeight.bold,
                                fontSize: 16,
                                color: Theme.of(context).textTheme.bodyLarge?.color,
                              ),
                            ),
                          ),
                          Text(
                            timeago.format(createdAt, locale: Get.locale?.languageCode),
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        notification['body'] ?? '',
                        style: TextStyle(
                          color: isRead ? Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.8) : Theme.of(context).textTheme.bodyLarge?.color,
                          fontSize: 14,
                          height: 1.4,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      // Actions Row (only if needed, or always visible for better UX)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (!isRead)
                            TextButton.icon(
                              onPressed: onMarkRead,
                              icon: const Icon(Icons.mark_email_read, size: 16),
                              label: Text('mark_read'.tr, style: const TextStyle(fontSize: 12)),
                              style: TextButton.styleFrom(
                                foregroundColor: Theme.of(context).primaryColor,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                            ),
                          IconButton(
                            onPressed: onDelete,
                            icon: Icon(Iconsax.trash_bold, size: 18, color: Colors.red.withValues(alpha: 0.7)),
                            tooltip: 'delete'.tr,
                            visualDensity: VisualDensity.compact,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(String type, BuildContext context) {
    Color color;
    IconData icon;

    switch (type) {
      case 'chat_message':
        color = Colors.blueAccent;
        icon = Iconsax.message_bold;
        break;
      case 'offer_received':
        color = Colors.green;
        icon = Iconsax.ticket_discount_bold;
        break;
      case 'order_update':
        color = Colors.orange;
        icon = Iconsax.box_bold;
        break;
      case 'warning':
        color = Colors.redAccent;
        icon = Iconsax.warning_2_bold;
        break;
      case 'success':
        color = Colors.teal;
        icon = Iconsax.tick_circle_bold;
        break;
      default:
        color = Theme.of(context).primaryColor;
        icon = Iconsax.notification_bold;
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
      child: Icon(icon, color: color, size: 24),
    );
  }
}
