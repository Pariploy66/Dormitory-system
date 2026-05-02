import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../firebase_options.dart';
import '../data/api_repository.dart';

/// 1. Top-level handler สำหรับ Background (ห้ามลบ @pragma)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (kIsWeb) {
    await Firebase.initializeApp(options: firebaseOptions);
  } else {
    await Firebase.initializeApp();
  }

  final FlutterLocalNotificationsPlugin localNotifications =
      FlutterLocalNotificationsPlugin();
  const AndroidInitializationSettings androidSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initSettings =
      InitializationSettings(android: androidSettings);

  await localNotifications.initialize(initSettings);
  _showNotification(localNotifications, message);
}

/// 2. ฟังก์ชันกลางสำหรับแสดง Notification (แชร์ใช้ทั้ง Foreground/Background)
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

    // Initialize Local Notifications สำหรับ Foreground
    await _localNotifications.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
    );

    // ลงทะเบียน Background Handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // 3. แก้ไขจุดนี้: เรียกใช้ _showNotification แทนชื่อเดิมที่หาไม่เจอ
    FirebaseMessaging.onMessage.listen((message) {
      _showNotification(_localNotifications, message);
    });

    // Register FCM token
    final token = await _messaging.getToken();
    if (token != null) {
      await _ref
          .read(apiRepositoryProvider)
          .registerFcmToken(token)
          .catchError((_) {});
    }

    _messaging.onTokenRefresh.listen((newToken) async {
      await _ref
          .read(apiRepositoryProvider)
          .registerFcmToken(newToken)
          .catchError((_) {});
    });
  }
}

final fcmServiceProvider = Provider<FcmService>((ref) => FcmService(ref));
