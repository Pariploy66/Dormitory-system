import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../firebase_options.dart' show DefaultFirebaseOptions;
import './api_service.dart';

/// Firebase Cloud Messaging service.
/// Registers the device token through the centralized ApiService (NewSystem).
/// Company pattern: core/services/ for cross-cutting infrastructure.

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(
    RemoteMessage message) async {
  try {
    if (Firebase.apps.isEmpty) {
      if (kIsWeb) {
        await Firebase.initializeApp(options: DefaultFirebaseOptions.web);
      } else {
        await Firebase.initializeApp();
      }
    }
    final plugin = FlutterLocalNotificationsPlugin();
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await plugin.initialize(const InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    ));
    _showNotification(plugin, message);
  } catch (e) {
    debugPrint('[FCM] Background handler error: $e');
  }
}

void _showNotification(
    FlutterLocalNotificationsPlugin plugin, RemoteMessage message) {
  final notification = message.notification;
  if (notification == null) return;
  plugin.show(
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
  FcmService(this._api);
  final ApiService _api;

  final _messaging = FirebaseMessaging.instance;
  final _localNotifications = FlutterLocalNotificationsPlugin();

  bool _initialised = false;

  /// Idempotent + crash-safe. Call after login (JWT must exist before the
  /// token can be registered to the backend). No-ops gracefully if Firebase
  /// is unavailable (web placeholder config, emulator AUTHENTICATION_FAILED).
  Future<void> init() async {
    if (_initialised) return;
    _initialised = true;
    try {
      await _messaging.requestPermission(
          alert: true, badge: true, sound: true);

      await _localNotifications.initialize(
        const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
          iOS: DarwinInitializationSettings(),
        ),
      );

      FirebaseMessaging.onMessage
          .listen((msg) => _showNotification(_localNotifications, msg));

      final token = await _messaging.getToken();
      if (token != null) {
        await _api.registerFcmToken(token);
      }

      _messaging.onTokenRefresh.listen((newToken) async {
        await _api.registerFcmToken(newToken);
      });
    } catch (e) {
      _initialised = false; // allow retry on next login
      debugPrint('[FCM] init skipped: $e');
    }
  }
}
