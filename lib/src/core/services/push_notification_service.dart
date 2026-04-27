import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:solar_hub/firebase_options.dart';
import 'package:solar_hub/src/core/cashe/cashe_interface.dart';
import 'package:solar_hub/src/core/di/get_it.dart';
import 'package:solar_hub/src/core/navigation/app_navigation.dart';
import 'package:solar_hub/src/core/services/dio.dart';
import 'package:solar_hub/src/core/services/network_status_service.dart';
import 'package:solar_hub/src/utils/app_urls.dart';
import 'package:solar_hub/src/utils/helper_methods.dart';

const List<String> _guestNotificationTopics = ['general', 'info'];
const String _notificationChannelId = 'solar_hub_notifications';
const String _notificationChannelName = 'Solar Hub Notifications';
const String _notificationHistoryPayload = 'notifications_history';

bool get _isMessagingSupportedPlatform {
  if (kIsWeb) {
    return false;
  }
  return Platform.isAndroid || Platform.isIOS || Platform.isMacOS;
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (!_isMessagingSupportedPlatform) {
    return;
  }

  try {
    // Firebase initialization is now handled in main.dart,
    // but check here for background isolate safety.
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    }
  } catch (e, stackTrace) {
    dPrint('Failed to initialize Firebase in background: $e', tag: 'fcm', stackTrace: stackTrace);
  }

  dPrint('Background message received: ${message.messageId}', tag: 'fcm');
}

@pragma('vm:entry-point')
void notificationTapBackgroundHandler(NotificationResponse response) {
  dPrint('Background local notification tap: ${response.payload}', tag: 'fcm');
}

class PushNotificationService {
  final CasheInterface _cache = getIt<CasheInterface>();
  final DioService _dioService = getIt<DioService>();
  final NetworkStatusService _networkStatus = getIt<NetworkStatusService>();
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  FirebaseMessaging get _messaging => FirebaseMessaging.instance;

  StreamSubscription<String>? _tokenRefreshSubscription;
  StreamSubscription<RemoteMessage>? _onMessageSubscription;
  StreamSubscription<RemoteMessage>? _onMessageOpenedAppSubscription;
  bool _initialized = false;
  bool _initializationAttempted = false;
  bool _localNotificationsAvailable = true;

  Future<void> initialize() async {
    if (_initialized || _initializationAttempted || !_isMessagingSupportedPlatform) {
      return;
    }

    _initializationAttempted = true;

    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }

      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
      await _initializeLocalNotifications();

      final permission = await _messaging.requestPermission(alert: true, badge: true, sound: true, provisional: false);
      dPrint('Notification permission: ${permission.authorizationStatus}', tag: 'fcm');

      // Keep foreground system alert disabled so the app can render its own
      // richer local notification presentation.
      await _messaging.setForegroundNotificationPresentationOptions(alert: false, badge: true, sound: true);

      _onMessageSubscription?.cancel();
      _onMessageSubscription = FirebaseMessaging.onMessage.listen((message) {
        dPrint('Foreground message received: ${message.messageId} - ${message.notification?.title}', tag: 'fcm');
        unawaited(_showForegroundNotification(message));
      });

      _onMessageOpenedAppSubscription?.cancel();
      _onMessageOpenedAppSubscription = FirebaseMessaging.onMessageOpenedApp.listen((_) {
        _openNotificationsPage();
      });

      _tokenRefreshSubscription?.cancel();
      _tokenRefreshSubscription = _messaging.onTokenRefresh.listen((token) {
        unawaited(_handleTokenRefresh(token));
      });

      _initialized = true;
      dPrint('Push notification service initialized', tag: 'fcm');

      if (Platform.isIOS || Platform.isMacOS) {
        await _waitForAPNSToken();
      }

      await _ensureGuestTopics();
      final token = await _getTokenIfReady();
      if (token != null && token.isNotEmpty) {
        await _cache.save('fcm_token', token);
      }

      if (_isSignedInLocally) {
        await onAuthenticated();
      } else {
        await _syncCurrentTokenWithBackend();
      }

      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        _openNotificationsPage();
      }
    } catch (e, stackTrace) {
      dPrint('Firebase Messaging initialization skipped: $e', tag: 'fcm', stackTrace: stackTrace);
      _initializationAttempted = false;
    }
  }

  Future<bool> _waitForAPNSToken({Duration timeout = const Duration(seconds: 5)}) async {
    if (!Platform.isIOS && !Platform.isMacOS) {
      return true;
    }

    final stopwatch = Stopwatch()..start();
    while (stopwatch.elapsed < timeout) {
      final apnsToken = await _messaging.getAPNSToken();
      if (apnsToken != null && apnsToken.isNotEmpty) {
        dPrint('APNs token received: ${apnsToken.substring(0, 8)}...', tag: 'fcm');
        return true;
      }
      await Future.delayed(const Duration(milliseconds: 500));
    }

    dPrint('APNs token timeout - check entitlements and provisioning profile', tag: 'fcm');
    return false;
  }

  Future<void> onAuthenticated() async {
    await initialize();
    if (!_initialized) {
      return;
    }

    await _ensureGuestTopics();
    await _syncCurrentTokenWithBackend();
  }

  Future<void> onLoggedOut() async {
    await initialize();
    if (!_initialized) {
      return;
    }

    await _cache.delete('fcm_synced_token');
    await _cache.delete('fcm_synced_user_id');
    await _resetGuestToken();
  }

  bool get _isSignedInLocally => _cache.token() != null && _cache.user() != null;

  Future<void> _handleTokenRefresh(String token) async {
    if (!_initialized) {
      return;
    }

    await _cache.save('fcm_token', token);
    await _cache.delete('fcm_synced_token');
    await _cache.delete('fcm_synced_user_id');
    await _cache.delete('fcm_backend_device_id');
    await _ensureGuestTopics();

    await _syncTokenWithBackend(token);
  }

  Future<void> _syncCurrentTokenWithBackend() async {
    final token = await _getTokenIfReady();
    if (token == null || token.isEmpty) {
      return;
    }

    await _cache.save('fcm_token', token);
    await _syncTokenWithBackend(token);
  }

  Future<void> _syncTokenWithBackend(String token) async {
    final user = _cache.user();

    final syncedToken = _cache.get('fcm_synced_token') as String?;
    final syncedUserId = _cache.get('fcm_synced_user_id')?.toString();
    final backendDeviceId = _cache.get('fcm_backend_device_id');

    final currentUserIdStr = user?.id.toString();

    if (syncedToken == token && syncedUserId == currentUserIdStr && backendDeviceId != null) {
      return;
    }

    try {
      final deviceIdentity = await _getOrCreateDeviceIdentity();
      final response = await _dioService.post(
        AppUrls.notificationSubscribe,
        data: {
          'token': token,
          'platform': Platform.isIOS ? 'ios' : (Platform.isMacOS ? 'macos' : 'android'),
          'device_id': deviceIdentity['device_id'],
          'app_version': deviceIdentity['app_version'],
        },
      );

      if ((response.status == 200 || response.status == 201) && !response.error) {
        await _cache.save('fcm_synced_token', token);
        if (currentUserIdStr != null) {
          await _cache.save('fcm_synced_user_id', user!.id);
        } else {
          await _cache.delete('fcm_synced_user_id');
        }
        final body = response.body is Map<String, dynamic> ? response.body as Map<String, dynamic> : <String, dynamic>{};
        if (body['device_id'] != null) {
          await _cache.save('fcm_backend_device_id', body['device_id']);
        }
        dPrint('FCM token synced${user != null ? ' for user ${user.id}' : ' for guest device'}', tag: 'fcm');
      } else {
        dPrint('FCM sync failed: ${response.message}', tag: 'fcm');
      }
    } catch (e, stackTrace) {
      if (_networkStatus.isConnectivityError(e)) {
        _networkStatus.markOffline(
          'Notifications will sync again when your connection returns.',
        );
      }
      dPrint('FCM sync error (non-fatal): $e', tag: 'fcm', stackTrace: stackTrace);
    }
  }

  Future<void> _resetGuestToken() async {
    try {
      await _messaging.deleteToken();
      dPrint('Deleted authenticated FCM token on logout', tag: 'fcm');
    } catch (e, stackTrace) {
      dPrint('Failed to delete FCM token on logout: $e', tag: 'fcm', stackTrace: stackTrace);
    }

    final guestToken = await _getTokenIfReady();
    if (guestToken != null && guestToken.isNotEmpty) {
      await _cache.save('fcm_token', guestToken);
      await _syncTokenWithBackend(guestToken);
    }

    await _cache.delete('fcm_backend_device_id');
    await _ensureGuestTopics();
  }

  Future<void> _ensureGuestTopics() async {
    if (!await _isApplePushTokenReady()) {
      return;
    }

    for (final topic in _guestNotificationTopics) {
      await _messaging.subscribeToTopic(topic);
      dPrint('Subscribed to topic: $topic', tag: 'fcm');
    }
  }

  Future<String?> _getTokenIfReady() async {
    if (!await _isApplePushTokenReady()) {
      return null;
    }
    return _messaging.getToken();
  }

  Future<bool> _isApplePushTokenReady() async {
    if (!Platform.isIOS && !Platform.isMacOS) {
      return true;
    }

    final apnsToken = await _messaging.getAPNSToken();
    if (apnsToken != null && apnsToken.isNotEmpty) {
      return true;
    }

    dPrint('APNs token not available yet. Skipping FCM topic/token work for now.', tag: 'fcm');
    return false;
  }

  Future<void> _initializeLocalNotifications() async {
    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/launcher_icon'),
      iOS: DarwinInitializationSettings(),
      macOS: DarwinInitializationSettings(),
    );

    try {
      await _localNotifications.initialize(
        settings: initializationSettings,
        onDidReceiveNotificationResponse: (response) {
          _handleNotificationTap(response.payload);
        },
        onDidReceiveBackgroundNotificationResponse: notificationTapBackgroundHandler,
      );
    } on MissingPluginException catch (e, stackTrace) {
      _localNotificationsAvailable = false;
      dPrint('Local notifications plugin unavailable: $e', tag: 'fcm', stackTrace: stackTrace);
      return;
    }

    const channel = AndroidNotificationChannel(
      _notificationChannelId,
      _notificationChannelName,
      description: 'Solar Hub foreground notifications',
      importance: Importance.max,
    );

    await _localNotifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);
  }

  Future<void> _showForegroundNotification(RemoteMessage message) async {
    if (!_localNotificationsAvailable) {
      return;
    }

    final title = message.notification?.title ?? message.data['title']?.toString() ?? 'Solar Hub';
    final body = message.notification?.body ?? message.data['body']?.toString() ?? '';

    if (body.isEmpty) {
      return;
    }

    final androidDetails = AndroidNotificationDetails(
      _notificationChannelId,
      _notificationChannelName,
      importance: Importance.max,
      priority: Priority.high,
      styleInformation: BigTextStyleInformation(body),
    );
    const iosDetails = DarwinNotificationDetails(presentAlert: true, presentBadge: true, presentSound: true);

    await _localNotifications.show(
      id: message.messageId.hashCode,
      title: title,
      body: body,
      notificationDetails: NotificationDetails(android: androidDetails, iOS: iosDetails, macOS: iosDetails),
      payload: _notificationHistoryPayload,
    );
  }

  void _handleNotificationTap(String? payload) {
    if (payload == _notificationHistoryPayload) {
      _openNotificationsPage();
    }
  }

  void _openNotificationsPage() {
    if (!_isSignedInLocally) {
      return;
    }

    final context = rootNavigatorKey.currentContext;
    if (context == null) {
      return;
    }

    GoRouter.of(context).push('/notifications');
  }

  Future<Map<String, String>> _getOrCreateDeviceIdentity() async {
    final cachedDeviceId = _cache.get('fcm_installation_id') as String?;
    if (cachedDeviceId != null && cachedDeviceId.isNotEmpty) {
      return {'device_id': cachedDeviceId, 'app_version': '1.0.0'};
    }

    final random = Random.secure().nextInt(1 << 32).toRadixString(16);
    final deviceId = '${Platform.operatingSystem}-${DateTime.now().millisecondsSinceEpoch}-$random';
    await _cache.save('fcm_installation_id', deviceId);
    return {'device_id': deviceId, 'app_version': '1.0.0'};
  }

  void dispose() {
    _onMessageSubscription?.cancel();
    _onMessageOpenedAppSubscription?.cancel();
    _tokenRefreshSubscription?.cancel();
  }
}
