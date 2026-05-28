part of 'auth_bloc.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, failure }

class AuthState extends Equatable {
  final AuthStatus status;
  final String? error; // error code: NETWORK_ERROR | WRONG_CREDENTIALS | SERVER_ERROR

  const AuthState({
    this.status = AuthStatus.initial,
    this.error,
  });

  AuthState copyWith({AuthStatus? status, String? error}) => AuthState(
        status: status ?? this.status,
        error: error,
      );

  @override
  List<Object?> get props => [status, error];
}
