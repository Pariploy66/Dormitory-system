import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../api/api_client.dart';
import '../auth/token_storage.dart';
import '../../features/auth/data/auth_repository.dart';
import '../../features/dorm/data/dorm_repository.dart';

/// Global service locator — company pattern from mobile-flutter/core/di/service_locator.dart
/// Replaces Riverpod Provider<Dio> and Provider<ApiRepository>.
late ApiClient apiClient;
late TokenStorage tokenStorage;
late AuthRepository authRepository;
late DormRepository dormRepository;

Future<void> setupServiceLocator() async {
  tokenStorage = const TokenStorage(FlutterSecureStorage());

  // Platform-aware base URL: Android emulator uses 10.0.2.2, web uses localhost
  const envUrl =
      String.fromEnvironment('API_BASE_URL', defaultValue: '');
  final baseUrl = envUrl.isNotEmpty
      ? envUrl
      : kIsWeb
          ? 'http://localhost:3000'
          : 'http://10.0.2.2:3000';

  apiClient = ApiClient(baseUrl: baseUrl);

  authRepository = AuthRepository(apiClient, tokenStorage);
  dormRepository = DormRepository(apiClient);
}
