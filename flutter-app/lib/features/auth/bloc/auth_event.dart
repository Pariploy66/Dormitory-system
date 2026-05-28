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

/// Login with email + password.
class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;
  const AuthLoginRequested(this.email, this.password);
  @override
  List<Object?> get props => [email, password];
}

/// Logout and clear tokens.
class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}
