import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'app/app.dart';
import 'core/di/service_locator.dart';
import 'core/services/fcm_service.dart';
import 'firebase_options.dart';

/// Background FCM handler — must be top-level function.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(
    RemoteMessage message) async {
  await firebaseMessagingBackgroundHandler(message);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Locale init — both EN and TH so DateFormat works in either language
  await initializeDateFormatting('th', null);
  await initializeDateFormatting('en', null);
  Intl.defaultLocale = 'en';
  timeago.setLocaleMessages('th', timeago.ThMessages());

  // Firebase — gracefully degrade if SHA-1/APNs not registered or project misconfigured
  // Android: reads android/app/google-services.json
  // iOS:     reads ios/Runner/GoogleService-Info.plist
  // Web:     uses DefaultFirebaseOptions.web (fill in after Firebase Console setup)
  try {
    if (kIsWeb) {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.web);
    } else {
      await Firebase.initializeApp();
    }
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  } catch (e) {
    debugPrint('[FCM] Firebase init failed — push notifications disabled: $e');
  }

  // Service locator — sets up ApiClient, TokenStorage, Repositories
  await setupServiceLocator();

  runApp(const StudentAccessApp());
}
