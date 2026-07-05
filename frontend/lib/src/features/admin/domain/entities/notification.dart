class NotificationResponse {
  final bool success;
  final String message;
  final int successCount;
  final int failureCount;

  const NotificationResponse({
    required this.success,
    required this.message,
    this.successCount = 0,
    this.failureCount = 0,
  });
}

class NotificationStats {
  final DeviceStats devices;
  final DeliveryStats notifications;

  const NotificationStats({required this.devices, required this.notifications});

  const NotificationStats.empty()
    : devices = const DeviceStats(),
      notifications = const DeliveryStats();

  factory NotificationStats.fromJson(Map<String, dynamic> json) {
    return NotificationStats(
      devices: DeviceStats.fromJson(
        Map<String, dynamic>.from(json['devices'] ?? const {}),
      ),
      notifications: DeliveryStats.fromJson(
        Map<String, dynamic>.from(json['notifications'] ?? const {}),
      ),
    );
  }
}

class DeviceStats {
  final int total;
  final int active;
  final int ios;
  final int android;

  const DeviceStats({
    this.total = 0,
    this.active = 0,
    this.ios = 0,
    this.android = 0,
  });

  factory DeviceStats.fromJson(Map<String, dynamic> json) {
    return DeviceStats(
      total: json['total'] ?? 0,
      active: json['active'] ?? 0,
      ios: json['ios'] ?? 0,
      android: json['android'] ?? 0,
    );
  }
}

class DeliveryStats {
  final int total;
  final int sent;
  final int failed;

  const DeliveryStats({this.total = 0, this.sent = 0, this.failed = 0});

  factory DeliveryStats.fromJson(Map<String, dynamic> json) {
    return DeliveryStats(
      total: json['total'] ?? 0,
      sent: json['sent'] ?? 0,
      failed: json['failed'] ?? 0,
    );
  }
}
