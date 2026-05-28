part of 'locale_bloc.dart';

class LocaleState extends Equatable {
  final Locale locale;
  final AppStrings strings;

  const LocaleState({
    required this.locale,
    required this.strings,
  });

  factory LocaleState.en() =>
      const LocaleState(locale: Locale('en'), strings: AppStrings.en);

  factory LocaleState.th() =>
      const LocaleState(locale: Locale('th'), strings: AppStrings.th);

  @override
  List<Object?> get props => [locale];
}
