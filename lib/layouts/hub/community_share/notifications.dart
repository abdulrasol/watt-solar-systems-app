import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:solar_hub/layouts/hub/community_share/fake_data.dart';
import 'package:timeago/timeago.dart' as timeago;

// Assuming your fake data is accessible globally or passed
// In a real app, you'd fetch these from a data layer/provider
//import '../main.dart'; // Adjust this path if your fake data is in main.dart or another file

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  // Function to handle notification tap
  void _handleNotificationTap(
    BuildContext context,
    Map<String, dynamic> notification,
  ) {
    // In a real app, you would mark the notification as read here via an API call
    Get.snackbar(
      'Notification Tapped',
      notification['message'],
      snackPosition: SnackPosition.BOTTOM,
    );

    final String? relatedId = notification['relatedId'];
    if (relatedId != null) {
      if (notification['type'] == 'comment_on_system') {
        // Find the system by ID and navigate to its detail page
        final Map<String, dynamic>? targetSystem = fakeSystems.firstWhereOrNull(
          (s) => s['id'] == relatedId,
        );
        if (targetSystem != null) {
          // You would typically navigate to a system details page
          // For demonstration, let's show a simple dialog or the systemCard itself
          // Get.dialog(
          //   AlertDialog(
          //     title: const Text('System Details'),
          //     content: Column(
          //       mainAxisSize: MainAxisSize.min,
          //       children: [
          //         systemCard(context, targetSystem),
          //         // Add more system details here
          //       ],
          //     ),
          //     actions: [
          //       TextButton(
          //         onPressed: () => Get.back(),
          //         child: const Text('Close'),
          //       ),
          //     ],
          //   ),
          // );
          Get.toNamed('/community/system', arguments: system);
        } else {
          Get.snackbar(
            'Error',
            'System not found!',
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      } else if (notification['type'] == 'reply_on_post' ||
          notification['type'] == 'problem_answered') {
        // Find the post by ID and navigate to its detail page
        final Map<String, dynamic>? targetPost = fakePosts.firstWhereOrNull(
          (p) => p['id'] == relatedId,
        );
        if (targetPost != null) {
          // You would typically navigate to a post details page
          // For demonstration, let's show a simple dialog or the postCard itself
          // Get.dialog(
          //   AlertDialog(
          //     title: const Text('Post Details'),
          //     content: Column(
          //       mainAxisSize: MainAxisSize.min,
          //       children: [
          //         postCard(targetPost),
          //         // Add more post details here, including comments
          //       ],
          //     ),
          //     actions: [
          //       TextButton(
          //         onPressed: () => Get.back(),
          //         child: const Text('Close'),
          //       ),
          //     ],
          //   ),
          // );
          Get.toNamed('/community/post', arguments: post);
        } else {
          Get.snackbar(
            'Error',
            'Post not found!',
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Notifications",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: fakeNotifications.isEmpty
          ? Center(
              child: Text(
                "No new notifications.",
                style: TextStyle(color: Colors.grey[600]),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: fakeNotifications.length,
              itemBuilder: (context, index) {
                final notification = fakeNotifications[index];
                final isRead = notification['isRead'] ?? false;

                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(
                    vertical: 6,
                    horizontal: 4,
                  ),
                  color: isRead
                      ? Colors.white
                      : Colors.blue.shade50, // Highlight unread
                  child: InkWell(
                    onTap: () => _handleNotificationTap(context, notification),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            notification['message'] ?? 'No message',
                            style: TextStyle(
                              fontWeight: isRead
                                  ? FontWeight.normal
                                  : FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            // Format timestamp nicely
                            (notification['timestamp'] != null)
                                ? timeago.format(
                                    DateTime.parse(notification['timestamp']),
                                  )
                                : 'Unknown time',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

// For `timeago.format`, you'll need to add the `timeago` package to your pubspec.yaml:
// dependencies:
//   timeago: ^3.6.0
// Then import it: `import 'package:timeago/timeago.dart' as timeago;`

final system = {
  'id': 'system_123', // <--- Add this
  'userName': 'Rasool Al-Engineer',
  'type': 'Hybrid',
  'panelPower': 610,
  'panelCount': 6,
  'panelBrand': 'LONGi',
  'panelNotes': 'Mounted at 25° tilt',
  'batteryVoltage': 51.2,
  'batteryAh': 200,
  'batteryCount': 1,
  'batteryBrand': 'SVolt',
  'batteryNotes': 'Lithium, safe under high temp',
  'inverterSize': '6',
  'inverterType': 'Hybrid',
  'inverterBrand': 'Deye',
  'inverterNotes': 'WiFi monitoring enabled',
  'installDate': '2024-11-10',
  'installer': 'SolarTech Iraq',
  'relatedPosts': [],
};

final post = {
  'id': 'post_a1b2', // <--- Add this
  'title': 'Battery Drain Problem',
  'user': 'Ahmed Zain',
  "type": "post",
  'date': '2025-04-15',
  'content': 'The battery drains quickly after sunset.',
  'likes': 5,
  'dislikes': 2,
  'comments': [
    {
      'author': 'Engineer Noor',
      'text': 'Check your charge controller!',
      'timestamp': '2025-04-16',
    },
    {
      'author': 'Ali H.',
      'text': 'Had same issue with old inverter',
      'timestamp': '2025-04-17',
    },
  ],
  'system': {
    'panelCount': 4,
    'panelPower': '550W',
    'panelBrand': 'Jinko',
    'batteryCount': 2,
    'batteryAh': '250',
    'batteryBrand': 'Narada',
    'inverterSize': '5kW',
    'inverterBrand': 'Growatt',
    'installer': 'GreenSun Co.',
  },
};

final post2 = {
  'id': 'post_c3d4', // <--- Add this
  'title': 'شحن غير كافي',
  'user': 'الحلو',
  "type": "issue",
  'date': '2025-04-15',
  'content': 'في الليل يكون التشغيل اقل من المعتاد على البطارية',
  'likes': 5,
  'dislikes': 2,
  'comments': [
    {
      'author': 'Engineer Noor',
      'text': 'Check your charge controller!',
      'timestamp': '2025-04-16',
    },
    {
      'author': 'Ali H.',
      'text': 'Had same issue with old inverter',
      'timestamp': '2025-04-17',
    },
  ],
  'system': {
    'panelCount': 4,
    'panelPower': '550W',
    'panelBrand': 'Jinko',
    'batteryCount': 2,
    'batteryAh': '250',
    'batteryBrand': 'Narada',
    'inverterSize': '5kW',
    'inverterBrand': 'Growatt',
    'installer': 'GreenSun Co.',
  },
};
