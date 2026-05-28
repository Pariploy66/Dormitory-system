import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:student_access_app/features/auth/bloc/auth_bloc.dart';
import 'package:student_access_app/features/auth/data/auth_repository.dart';

// ── Mock ──────────────────────────────────────────────────────────────────────

class MockAuthRepository extends Mock implements AuthRepository {}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  late MockAuthRepository mockRepo;

  setUp(() {
    mockRepo = MockAuthRepository();
  });

  group('AuthBloc', () {
    // ── AuthCheckRequested ───────────────────────────────────────────────────

    group('AuthCheckRequested', () {
      blocTest<AuthBloc, AuthState>(
        'emits [loading, authenticated] when token exists',
        build: () {
          when(() => mockRepo.isLoggedIn()).thenAnswer((_) async => true);
          return AuthBloc(mockRepo);
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
          when(() => mockRepo.isLoggedIn()).thenAnswer((_) async => false);
          return AuthBloc(mockRepo);
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
          when(() => mockRepo.login(any(), any()))
              .thenAnswer((_) async {});
          return AuthBloc(mockRepo);
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
          when(() => mockRepo.login(any(), any()))
              .thenThrow(Exception('WRONG_CREDENTIALS'));
          return AuthBloc(mockRepo);
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
          when(() => mockRepo.login(any(), any()))
              .thenThrow(Exception('NETWORK_ERROR'));
          return AuthBloc(mockRepo);
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
          when(() => mockRepo.logout()).thenAnswer((_) async {});
          return AuthBloc(mockRepo);
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
