part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

/// Check if token exists in storage (app startup).
class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

/// Complete ThaID login with the authorization code captured from the webview.
class AuthThaidLoginRequested extends AuthEvent {
  final String code;
  const AuthThaidLoginRequested(this.code);
  @override
  List<Object?> get props => [code];
}

/// Logout and clear tokens.
class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

/// Local authentication (biometric/PIN) passed — unlock the app.
class AuthUnlocked extends AuthEvent {
  const AuthUnlocked();
}
