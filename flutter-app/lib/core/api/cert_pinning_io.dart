import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';

/// Certificate pinning (Android/iOS/desktop).
///
/// Compares the SHA-256 fingerprint of the server's leaf certificate against
/// the allowed list embedded at build time. Even a certificate signed by a
/// trusted CA is rejected unless its fingerprint matches — this is what
/// defeats man-in-the-middle proxies on public Wi-Fi.
///
/// [pins] is empty in development (plain HTTP on LAN) → pinning disabled.
void applyCertificatePinning(Dio dio, List<String> pins) {
  if (pins.isEmpty) return;
  final adapter = dio.httpClientAdapter;
  if (adapter is IOHttpClientAdapter) {
    adapter.validateCertificate = (cert, host, port) {
      if (cert == null) return false;
      final fingerprint = sha256.convert(cert.der).toString().toLowerCase();
      return pins.contains(fingerprint);
    };
  }
}
