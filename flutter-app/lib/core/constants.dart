import 'package:flutter/foundation.dart' show kIsWeb;

class AppConstants {
  // ── API base URL ──────────────────────────────────────────────────────────
  // Override at build time:
  //   flutter run --dart-define=API_BASE_URL=http://<ip>:3000
  //
  // Defaults (when API_BASE_URL is not defined):
  //   Web                → http://localhost:3000      (same machine)
  //   Android emulator   → http://192.168.20.239:3000      (host loopback)
  //   iOS simulator      → http://localhost:3000
  //   Physical device    → set --dart-define=API_BASE_URL=http://<LAN IP>:3000
  static String get apiBaseUrl {
    const defined = String.fromEnvironment('API_BASE_URL', defaultValue: '');
    if (defined.isNotEmpty) return defined;
    return kIsWeb ? 'http://localhost:3000' : 'http://192.168.20.239:3000';
  }

  static const jwtStorageKey      = 'jwt_token';
  static const parentIdStorageKey = 'parent_id';
}
