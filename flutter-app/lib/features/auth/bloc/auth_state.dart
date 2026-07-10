part of 'auth_bloc.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, failure }

class AuthState extends Equatable {
  final AuthStatus status;
  final String? error; // error code: NETWORK_ERROR | WRONG_CREDENTIALS | SERVER_ERROR

  /// Biometric app lock: a restored session (from secure storage) starts
  /// LOCKED and must pass local authentication (fingerprint/face/PIN) first.
  /// A fresh ThaID login is already verified, so it starts unlocked.
  final bool unlocked;

  const AuthState({
    this.status = AuthStatus.initial,
    this.error,
    this.unlocked = false,
  });

  AuthState copyWith({AuthStatus? status, String? error, bool? unlocked}) =>
      AuthState(
        status: status ?? this.status,
        error: error,
        unlocked: unlocked ?? this.unlocked,
      );

  @override
  List<Object?> get props => [status, error, unlocked];
}
