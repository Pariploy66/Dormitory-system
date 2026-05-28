import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/di/service_locator.dart';
import '../core/theme/mfu_theme.dart';
import '../features/auth/bloc/auth_bloc.dart';
import '../features/dorm/bloc/dorm_bloc.dart';
import '../features/locale/bloc/locale_bloc.dart';
import 'router.dart';

/// App root — provides all BLoCs and builds MaterialApp.router.
/// Company pattern: app/app.dart with MultiBlocProvider.
class StudentAccessApp extends StatefulWidget {
  const StudentAccessApp({super.key});

  @override
  State<StudentAccessApp> createState() => _StudentAccessAppState();
}

class _StudentAccessAppState extends State<StudentAccessApp> {
  late final AuthBloc _authBloc;
  late final DormBloc _dormBloc;
  late final LocaleBloc _localeBloc;

  @override
  void initState() {
    super.initState();
    _authBloc = AuthBloc(authRepository)
      ..add(const AuthCheckRequested());
    _dormBloc = DormBloc(dormRepository, authRepository);
    _localeBloc = LocaleBloc();
  }

  @override
  void dispose() {
    _authBloc.close();
    _dormBloc.close();
    _localeBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _authBloc),
        BlocProvider.value(value: _dormBloc),
        BlocProvider.value(value: _localeBloc),
      ],
      child: BlocBuilder<LocaleBloc, LocaleState>(
        builder: (context, localeState) {
          final router = buildRouter(_authBloc);
          return MaterialApp.router(
            title: 'MFU Dormitory',
            theme: MfuTheme.theme,
            routerConfig: router,
            locale: localeState.locale,
            supportedLocales: const [Locale('en'), Locale('th')],
          );
        },
      ),
    );
  }
}
