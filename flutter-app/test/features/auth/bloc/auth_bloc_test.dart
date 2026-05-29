import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:student_access_app/features/auth/bloc/auth_bloc.dart';
import 'package:student_access_app/services/api_service.dart';

// ── Mock ──────────────────────────────────────────────────────────────────────

class MockApiService extends Mock implements ApiService {}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  late MockApiService mockApi;

  setUp(() {
    mockApi = MockApiService();
  });

  group('AuthBloc', () {
    // ── AuthCheckRequested ───────────────────────────────────────────────────

    group('AuthCheckRequested', () {
      blocTest<AuthBloc, AuthState>(
        'emits [loading, authenticated] when token exists',
        build: () {
          when(() => mockApi.isLoggedIn()).thenAnswer((_) async => true);
          return AuthBloc(mockApi);
        },
        act: (bloc) => bloc.add(const AuthCheckRequested()),
        expect: () => const [
          AuthState(status: AuthStatus.loading),
          AuthState(status: AuthStatus.authenticated),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [loading, unauthenticated] when no token',
        build: () {
          when(() => mockApi.isLoggedIn()).thenAnswer((_) async => false);
          return AuthBloc(mockApi);
        },
        act: (bloc) => bloc.add(const AuthCheckRequested()),
        expect: () => const [
          AuthState(status: AuthStatus.loading),
          AuthState(status: AuthStatus.unauthenticated),
        ],
      );
    });

    // ── AuthLoginRequested ───────────────────────────────────────────────────

    group('AuthLoginRequested', () {
      blocTest<AuthBloc, AuthState>(
        'emits [loading, authenticated] on successful login',
        build: () {
          when(() => mockApi.login(any(), any()))
              .thenAnswer((_) async {});
          return AuthBloc(mockApi);
        },
        act: (bloc) =>
            bloc.add(const AuthLoginRequested('user@test.com', 'pass123')),
        expect: () => const [
          AuthState(status: AuthStatus.loading),
          AuthState(status: AuthStatus.authenticated),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [loading, failure] with WRONG_CREDENTIALS on bad login',
        build: () {
          when(() => mockApi.login(any(), any()))
              .thenThrow(Exception('WRONG_CREDENTIALS'));
          return AuthBloc(mockApi);
        },
        act: (bloc) =>
            bloc.add(const AuthLoginRequested('user@test.com', 'wrong')),
        expect: () => const [
          AuthState(status: AuthStatus.loading),
          AuthState(
              status: AuthStatus.failure, error: 'WRONG_CREDENTIALS'),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [loading, failure] with NETWORK_ERROR on connection failure',
        build: () {
          when(() => mockApi.login(any(), any()))
              .thenThrow(Exception('NETWORK_ERROR'));
          return AuthBloc(mockApi);
        },
        act: (bloc) =>
            bloc.add(const AuthLoginRequested('user@test.com', 'pass')),
        expect: () => const [
          AuthState(status: AuthStatus.loading),
          AuthState(status: AuthStatus.failure, error: 'NETWORK_ERROR'),
        ],
      );
    });

    // ── AuthLogoutRequested ──────────────────────────────────────────────────

    group('AuthLogoutRequested', () {
      blocTest<AuthBloc, AuthState>(
        'emits [unauthenticated] after logout',
        build: () {
          when(() => mockApi.logout()).thenAnswer((_) async {});
          return AuthBloc(mockApi);
        },
        seed: () => const AuthState(status: AuthStatus.authenticated),
        act: (bloc) => bloc.add(const AuthLogoutRequested()),
        expect: () => const [
          AuthState(status: AuthStatus.unauthenticated),
        ],
      );
    });

    // ── AuthState equality ───────────────────────────────────────────────────

    group('AuthState equality (Equatable)', () {
      test('same status and error are equal', () {
        expect(
          const AuthState(status: AuthStatus.loading),
          equals(const AuthState(status: AuthStatus.loading)),
        );
      });

      test('different status are not equal', () {
        expect(
          const AuthState(status: AuthStatus.loading),
          isNot(equals(const AuthState(status: AuthStatus.authenticated))),
        );
      });
    });
  });
}
