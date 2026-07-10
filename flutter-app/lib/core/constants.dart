import 'package:flutter/foundation.dart' show kIsWeb;

class AppConstants {
  // ── API base URL ──────────────────────────────────────────────────────────
  // Override at build time:
  //   flutter run --dart-define=API_BASE_URL=http://<ip>:3000
  //
  // Defaults (when API_BASE_URL is not defined):
  //   Web              → http://localhost:3000
  //   Android emulator → http://10.0.2.2:3000  (alias for the host machine)
  //
  // ⚠️ If the emulator shows "Network is unreachable", it has BOTH eth0 and
  // wlan0 up on the same 10.0.2.0/24 subnet (route conflict). Fix per boot:
  //   adb shell svc data disable      # keep Wi-Fi only
  // Backup path: `adb reverse tcp:3000 tcp:3000` + API_BASE_URL=localhost.
  //
  // Physical device over Wi-Fi:
  //   --dart-define=API_BASE_URL=http://<host LAN IP>:3000
  static String get apiBaseUrl {
    const defined = String.fromEnvironment('API_BASE_URL', defaultValue: '');
    if (defined.isNotEmpty) return defined;
    return kIsWeb ? 'http://localhost:3000' : 'http://10.0.2.2:3000';
  }

  static const jwtStorageKey      = 'jwt_token';
  static const parentIdStorageKey = 'parent_id';

  // ── Certificate pinning ───────────────────────────────────────────────────
  // SHA-256 fingerprints (hex, no colons) of the server certificates the app
  // will trust. Empty (default) = disabled — dev runs plain HTTP on the LAN.
  // Production build:
  //   flutter build apk --dart-define=PINNED_CERT_SHA256=<fp1>,<fp2>
  // Get a fingerprint:
  //   openssl s_client -connect host:443 </dev/null 2>/dev/null \
  //     | openssl x509 -outform DER | openssl dgst -sha256
  static List<String> get pinnedCertSha256 {
    const raw =
        String.fromEnvironment('PINNED_CERT_SHA256', defaultValue: '');
    if (raw.isEmpty) return const [];
    return raw.toLowerCase().replaceAll(':', '').split(',');
  }
}
