import 'package:dio/dio.dart';

/// Web build: browser owns TLS — certificate pinning is not applicable.
void applyCertificatePinning(Dio dio, List<String> pins) {}
