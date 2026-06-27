import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../core/services/api_service.dart';

part 'auth_event.dart';
part 'auth_state.dart';

/// Handles authentication lifecycle: check, ThaID login, logout.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final ApiService _api;

  AuthBloc(this._api) : super(const AuthState()) {
    on<AuthCheckRequested>(_onCheck);
    on<AuthThaidLoginRequested>(_onThaidLogin);
    on<AuthLogoutRequested>(_onLogout);
  }

  Future<void> _onCheck(
      AuthCheckRequested event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.loading));
    final loggedIn = await _api.isLoggedIn();
    emit(state.copyWith(
        status:
            loggedIn ? AuthStatus.authenticated : AuthStatus.unauthenticated));
  }

  Future<void> _onThaidLogin(
      AuthThaidLoginRequested event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      await _api.thaidLogin(event.code);
      emit(state.copyWith(status: AuthStatus.authenticated));
    } catch (e) {
      emit(state.copyWith(
          status: AuthStatus.failure,
          error: e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onLogout(
      AuthLogoutRequested event, Emitter<AuthState> emit) async {
    await _api.logout();
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }
}
