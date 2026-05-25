import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'core/router.dart';
import 'firebase_options.dart';
import 'services/fcm_service.dart';
import 'ui/theme/mfu_theme.dart';
import 'package:firebase_messaging/firebase_messaging.dart'; // เติม ; เข้าไปท้ายบรรทัดครับ

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // สำคัญ: ต้องเรียก Firebase.initializeApp() ภายในนี้ด้วย
  if (kIsWeb) {
    await Firebase.initializeApp(options: firebaseOptions);
  } else {
    await Firebase.initializeApp();
  }
  debugPrint('FCM background message: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 2. ตั้งค่า Locale — init both so DateFormat('EEE, d MMM', 'th'/'en') both work
  await initializeDateFormatting('th', null);
  await initializeDateFormatting('en', null);
  Intl.defaultLocale = 'en'; // default English; UI locale drives DateFormat explicitly
  timeago.setLocaleMessages('th', timeago.ThMessages());

  // 3. Initialize Firebase
  if (kIsWeb) {
    await Firebase.initializeApp(options: firebaseOptions);
  } else {
    await Firebase.initializeApp();
  }

  // 4. ลงทะเบียน Background Handler ตรงนี้เลย!
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(const ProviderScope(child: StudentAccessApp()));
}

class StudentAccessApp extends ConsumerStatefulWidget {
  const StudentAccessApp({super.key});

  @override
  ConsumerState<StudentAccessApp> createState() => _StudentAccessAppState();
}

class _StudentAccessAppState extends ConsumerState<StudentAccessApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(fcmServiceProvider).init();
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'MFU Dormitory',
      // ← เปลี่ยนจาก blue เป็น MFU theme
      theme: MfuTheme.theme,
      routerConfig: router,
    );
  }
}
