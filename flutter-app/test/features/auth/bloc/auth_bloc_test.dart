import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:student_access_app/features/auth/bloc/auth_bloc.dart';
import 'package:student_access_app/core/services/api_service.dart';

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

    // ── AuthThaidLoginRequested ──────────────────────────────────────────────

    group('AuthThaidLoginRequested', () {
      blocTest<AuthBloc, AuthState>(
        'emits [loading, authenticated+unlocked] on successful ThaID login',
        build: () {
          when(() => mockApi.thaidLogin(any())).thenAnswer((_) async {});
          return AuthBloc(mockApi);
        },
        act: (bloc) => bloc.add(const AuthThaidLoginRequested('auth-code')),
        expect: () => const [
          AuthState(status: AuthStatus.loading),
          // Fresh ThaID login is already verified → no biometric lock.
          AuthState(status: AuthStatus.authenticated, unlocked: true),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [loading, failure] with SERVER_ERROR when exchange fails',
        build: () {
          when(() => mockApi.thaidLogin(any()))
              .thenThrow(Exception('SERVER_ERROR'));
          return AuthBloc(mockApi);
        },
        act: (bloc) => bloc.add(const AuthThaidLoginRequested('bad-code')),
        expect: () => const [
          AuthState(status: AuthStatus.loading),
          AuthState(status: AuthStatus.failure, error: 'SERVER_ERROR'),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [loading, failure] with NETWORK_ERROR on connection failure',
        build: () {
          when(() => mockApi.thaidLogin(any()))
              .thenThrow(Exception('NETWORK_ERROR'));
          return AuthBloc(mockApi);
        },
        act: (bloc) => bloc.add(const AuthThaidLoginRequested('code')),
        expect: () => const [
          AuthState(status: AuthStatus.loading),
          AuthState(status: AuthStatus.failure, error: 'NETWORK_ERROR'),
        ],
      );
    });

    // ── AuthUnlocked (biometric app lock) ───────────────────────────────────

    group('AuthUnlocked', () {
      blocTest<AuthBloc, AuthState>(
        'sets unlocked=true after local authentication passes',
        build: () => AuthBloc(mockApi),
        seed: () => const AuthState(status: AuthStatus.authenticated),
        act: (bloc) => bloc.add(const AuthUnlocked()),
        expect: () => const [
          AuthState(status: AuthStatus.authenticated, unlocked: true),
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
