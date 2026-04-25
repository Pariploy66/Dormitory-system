import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/api_repository.dart';

/// Top-level handler required by Firebase for background messages
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // No need to re-init Firebase — it's already init'd by the OS
  _showLocalNotification(message);
}

void _showLocalNotification(RemoteMessage message) {
  final notification = message.notification;
  if (notification == null) return;

  FlutterLocalNotificationsPlugin().show(
    notification.hashCode,
    notification.title,
    notification.body,
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'access_events',
        'Access Events',
        channelDescription: 'Student entry/exit notifications',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    ),
  );
}

class FcmService {
  FcmService(this._ref);
  final Ref _ref;

  final _messaging = FirebaseMessaging.instance;
  final _localNotifications = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // Request permission
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Set up local notifications channel (Android 8+)
    await _localNotifications.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
    );

    // Register background handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Foreground messages
    FirebaseMessaging.onMessage.listen((message) {
      _showLocalNotification(message);
    });

    // Register FCM token with backend
    final token = await _messaging.getToken();
    if (token != null) {
      await _ref
          .read(apiRepositoryProvider)
          .registerFcmToken(token)
          .catchError((_) {}); // Non-fatal if this fails
    }

    // Handle token refresh
    _messaging.onTokenRefresh.listen((newToken) async {
      await _ref
          .read(apiRepositoryProvider)
          .registerFcmToken(newToken)
          .catchError((_) {});
    });
  }
}

final fcmServiceProvider = Provider<FcmService>((ref) => FcmService(ref));
