import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../data/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

/// Handles authentication lifecycle: check, login, logout.
/// Company pattern: features/auth/bloc/auth_bloc.dart
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _repository;

  AuthBloc(this._repository) : super(const AuthState()) {
    on<AuthCheckRequested>(_onCheck);
    on<AuthLoginRequested>(_onLogin);
    on<AuthLogoutRequested>(_onLogout);
  }

  Future<void> _onCheck(
      AuthCheckRequested event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.loading));
    final loggedIn = await _repository.isLoggedIn();
    emit(state.copyWith(
        status:
            loggedIn ? AuthStatus.authenticated : AuthStatus.unauthenticated));
  }

  Future<void> _onLogin(
      AuthLoginRequested event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      await _repository.login(event.email, event.password);
      emit(state.copyWith(status: AuthStatus.authenticated));
    } catch (e) {
      emit(state.copyWith(
          status: AuthStatus.failure,
          error: e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onLogout(
      AuthLogoutRequested event, Emitter<AuthState> emit) async {
    await _repository.logout();
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }
}
