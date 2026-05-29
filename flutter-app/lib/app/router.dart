import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/bloc/auth_bloc.dart';
import '../screens/login/login_screen.dart';
import '../screens/register/register_screen.dart';
import '../screens/home/home_screen.dart';

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
      final onAuthPage = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';

      if (!loggedIn && !onAuthPage) return '/login';
      if (loggedIn && onAuthPage) return '/home';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
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
