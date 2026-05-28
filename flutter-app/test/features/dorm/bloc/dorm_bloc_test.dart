import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:student_access_app/features/auth/data/auth_repository.dart';
import 'package:student_access_app/features/auth/domain/parent_model.dart';
import 'package:student_access_app/features/dorm/bloc/dorm_bloc.dart';
import 'package:student_access_app/features/dorm/data/dorm_repository.dart';
import 'package:student_access_app/features/dorm/domain/access_log_model.dart';
import 'package:student_access_app/features/dorm/domain/student_model.dart';

// ── Mocks ─────────────────────────────────────────────────────────────────────

class MockDormRepository extends Mock implements DormRepository {}
class MockAuthRepository extends Mock implements AuthRepository {}

// ── Fixtures ──────────────────────────────────────────────────────────────────

const _student = StudentModel(
  id: 'stu-001',
  name: 'Test Student',
  studentCode: 'S001',
  dormitory: 'A',
  roomNumber: '101',
);

final _log = AccessLogModel(
  id: 'log-001',
  accessTime: DateTime(2026, 5, 28, 8, 0),
  type: 'IN',
  gateName: 'Main Gate',
  isLate: false,
);

const _profile = ParentModel(
  id: 'par-001',
  name: 'Test Parent',
  phone: '0812345678',
  email: 'parent@test.com',
);

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  late MockDormRepository mockDormRepo;
  late MockAuthRepository mockAuthRepo;

  setUp(() {
    mockDormRepo = MockDormRepository();
    mockAuthRepo = MockAuthRepository();
  });

  group('DormBloc', () {
    // ── DormRefreshDashboard ─────────────────────────────────────────────────

    group('DormRefreshDashboard', () {
      blocTest<DormBloc, DormState>(
        'emits [loading, success] with students + logs on first load',
        build: () {
          when(() => mockDormRepo.getStudents())
              .thenAnswer((_) async => [_student]);
          when(() => mockDormRepo.getLogsToday(any()))
              .thenAnswer((_) async => [_log]);
          when(() => mockDormRepo.getLogs(any()))
              .thenAnswer((_) async => [_log]);
          return DormBloc(mockDormRepo, mockAuthRepo);
        },
        act: (bloc) => bloc.add(const DormRefreshDashboard()),
        expect: () => [
          const DormState(status: DormStatus.loading),
          predicate<DormState>((s) =>
              s.status == DormStatus.success &&
              s.students.length == 1 &&
              s.students.first.id == 'stu-001' &&
              s.logsToday.length == 1),
        ],
      );

      blocTest<DormBloc, DormState>(
        'emits success with empty lists when no students linked',
        build: () {
          when(() => mockDormRepo.getStudents())
              .thenAnswer((_) async => []);
          return DormBloc(mockDormRepo, mockAuthRepo);
        },
        act: (bloc) => bloc.add(const DormRefreshDashboard()),
        expect: () => [
          const DormState(status: DormStatus.loading),
          predicate<DormState>((s) =>
              s.status == DormStatus.success && s.students.isEmpty),
        ],
      );

      blocTest<DormBloc, DormState>(
        'emits failure on network error (no existing students)',
        build: () {
          when(() => mockDormRepo.getStudents())
              .thenThrow(Exception('NETWORK_ERROR'));
          return DormBloc(mockDormRepo, mockAuthRepo);
        },
        act: (bloc) => bloc.add(const DormRefreshDashboard()),
        expect: () => [
          const DormState(status: DormStatus.loading),
          predicate<DormState>((s) =>
              s.status == DormStatus.failure &&
              s.error == 'NETWORK_ERROR'),
        ],
      );

      blocTest<DormBloc, DormState>(
        'keeps existing data visible (success) on background poll error',
        build: () {
          when(() => mockDormRepo.getStudents())
              .thenThrow(Exception('NETWORK_ERROR'));
          return DormBloc(mockDormRepo, mockAuthRepo);
        },
        seed: () => DormState(
          status: DormStatus.success,
          students: const [_student],
          logsToday: [_log],
          logs: [_log],
        ),
        act: (bloc) => bloc.add(const DormRefreshDashboard()),
        expect: () => [
          predicate<DormState>((s) =>
              s.status == DormStatus.success &&
              s.students.length == 1),
        ],
      );
    });

    // ── DormSetFilterDays ────────────────────────────────────────────────────

    group('DormSetFilterDays', () {
      blocTest<DormBloc, DormState>(
        'updates filterDays and refreshes history',
        build: () {
          when(() => mockDormRepo.getLogs(any(), days: any(named: 'days')))
              .thenAnswer((_) async => [_log]);
          return DormBloc(mockDormRepo, mockAuthRepo);
        },
        seed: () => const DormState(
          status: DormStatus.success,
          students: [_student],
        ),
        act: (bloc) => bloc.add(const DormSetFilterDays(7)),
        expect: () => [
          predicate<DormState>((s) => s.filterDays == 7),
          // followed by DormRefreshHistory result — we just check filterDays
          anything,
        ],
      );

      blocTest<DormBloc, DormState>(
        'filterDays defaults to 1 in initial state',
        build: () => DormBloc(mockDormRepo, mockAuthRepo),
        act: (_) {},
        verify: (bloc) => expect(bloc.state.filterDays, equals(1)),
      );
    });

    // ── DormSetFilterType ────────────────────────────────────────────────────

    group('DormSetFilterType', () {
      blocTest<DormBloc, DormState>(
        'updates filterType to Entry',
        build: () => DormBloc(mockDormRepo, mockAuthRepo),
        act: (bloc) => bloc.add(const DormSetFilterType('Entry')),
        expect: () => [
          predicate<DormState>((s) => s.filterType == 'Entry'),
        ],
      );

      blocTest<DormBloc, DormState>(
        'updates filterType to Exit',
        build: () => DormBloc(mockDormRepo, mockAuthRepo),
        act: (bloc) => bloc.add(const DormSetFilterType('Exit')),
        expect: () => [
          predicate<DormState>((s) => s.filterType == 'Exit'),
        ],
      );
    });

    // ── DormFetchProfile ─────────────────────────────────────────────────────

    group('DormFetchProfile', () {
      blocTest<DormBloc, DormState>(
        'emits [profileLoading=true, profile loaded] on success',
        build: () {
          when(() => mockAuthRepo.getProfile())
              .thenAnswer((_) async => _profile);
          return DormBloc(mockDormRepo, mockAuthRepo);
        },
        act: (bloc) => bloc.add(const DormFetchProfile()),
        expect: () => [
          predicate<DormState>((s) => s.profileLoading == true),
          predicate<DormState>((s) =>
              s.profileLoading == false &&
              s.profile?.name == 'Test Parent'),
        ],
      );

      blocTest<DormBloc, DormState>(
        'does not re-fetch if profile already loaded',
        build: () => DormBloc(mockDormRepo, mockAuthRepo),
        seed: () => const DormState(profile: _profile),
        act: (bloc) => bloc.add(const DormFetchProfile()),
        expect: () => [],
        verify: (_) => verifyNever(() => mockAuthRepo.getProfile()),
      );

      blocTest<DormBloc, DormState>(
        'emits error state when profile fetch fails',
        build: () {
          when(() => mockAuthRepo.getProfile())
              .thenThrow(Exception('SERVER_ERROR'));
          return DormBloc(mockDormRepo, mockAuthRepo);
        },
        act: (bloc) => bloc.add(const DormFetchProfile()),
        expect: () => [
          predicate<DormState>((s) => s.profileLoading == true),
          predicate<DormState>((s) =>
              s.profileLoading == false && s.error == 'SERVER_ERROR'),
        ],
      );
    });

    // ── DormState computed properties ────────────────────────────────────────

    group('DormState computed getters', () {
      test('activeStudent returns first student', () {
        const state = DormState(students: [_student]);
        expect(state.activeStudent, equals(_student));
      });

      test('activeStudent returns null when students empty', () {
        expect(const DormState().activeStudent, isNull);
      });

      test('todayInCount counts IN entries', () {
        final state = DormState(logsToday: [_log, _log]);
        expect(state.todayInCount, equals(2));
      });

      test('todayOutCount counts OUT entries', () {
        final outLog = AccessLogModel(
          id: 'log-out',
          accessTime: DateTime(2026, 5, 28, 17, 0),
          type: 'OUT',
          gateName: 'Main Gate',
          isLate: false,
        );
        final state = DormState(logsToday: [_log, outLog]);
        expect(state.todayOutCount, equals(1));
      });
    });
  });
}
