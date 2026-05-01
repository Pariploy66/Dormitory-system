class AppConstants {
  // Injected at build time via --dart-define
  static const apiBaseUrl = String.fromEnvironment('API_BASE_URL',
      defaultValue: 'http://192.168.20.239:3000');

  static const jwtStorageKey = 'jwt_token';
  static const parentIdStorageKey = 'parent_id';
}
