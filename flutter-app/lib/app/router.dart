import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/bloc/auth_bloc.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/unlock_screen.dart';
import '../features/dorm/presentation/home_screen.dart';

/// App router with BLoC-based auth guard.
/// Company pattern: app/router.dart — go_router with stream-based redirect.
GoRouter buildRouter(AuthBloc authBloc) {
  final notifier = _AuthRouterNotifier(authBloc);
  return GoRouter(
    initialLocation: '/login',
    refreshListenable: notifier,
    redirect: (context, state) {
      final authState = authBloc.state;
      if (authState.status == AuthStatus.initial ||
          authState.status == AuthStatus.loading) {
        return null; // Wait for check to complete
      }
      final loggedIn = authState.status == AuthStatus.authenticated;
      final onAuthPage = state.matchedLocation == '/login';
      final onUnlockPage = state.matchedLocation == '/unlock';

      if (!loggedIn && !onAuthPage) return '/login';
      // Biometric app lock: restored session must pass local auth first.
      if (loggedIn && !authState.unlocked && !onUnlockPage) return '/unlock';
      if (loggedIn && authState.unlocked && (onAuthPage || onUnlockPage)) {
        return '/home';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/unlock', builder: (_, __) => const UnlockScreen()),
      GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
    ],
  );
}

class _AuthRouterNotifier extends ChangeNotifier {
  _AuthRouterNotifier(AuthBloc bloc) {
    _sub = bloc.stream.listen((_) => notifyListeners());
  }
  late final StreamSubscription _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
