import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/app_providers.dart';
import '../ui/screens/login_screen.dart';
import '../ui/screens/register_screen.dart';
import '../ui/screens/home_screen.dart';
import '../ui/screens/logs_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = _RouterNotifier(ref);
  final router = GoRouter(
    initialLocation: '/login',
    refreshListenable: notifier,
    redirect: notifier._redirect,
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      GoRoute(
        path: '/home',
        builder: (_, __) => const HomeScreen(),
        routes: [
          GoRoute(
            path: 'logs/:studentId',
            builder: (_, state) =>
                LogsScreen(studentId: state.pathParameters['studentId']!),
          ),
        ],
      ),
    ],
  );
  ref.onDispose(notifier.dispose);
  return router;
});

class _RouterNotifier extends ChangeNotifier {
  _RouterNotifier(this._ref) {
    _ref.listen<AsyncValue<bool>>(authStateProvider, (_, __) => notifyListeners());
  }

  final Ref _ref;

  String? _redirect(BuildContext context, GoRouterState state) {
    final authAsync = _ref.read(authStateProvider);
    if (authAsync.isLoading) return null;

    final isLoggedIn = authAsync.valueOrNull ?? false;
    final onAuthPage = state.matchedLocation == '/login' ||
        state.matchedLocation == '/register';

    if (!isLoggedIn && !onAuthPage) return '/login';
    if (isLoggedIn && onAuthPage) return '/home';
    return null;
  }
}
