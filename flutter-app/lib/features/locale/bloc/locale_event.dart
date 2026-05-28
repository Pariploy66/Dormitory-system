part of 'locale_bloc.dart';

abstract class LocaleEvent extends Equatable {
  const LocaleEvent();
  @override
  List<Object?> get props => [];
}

class LocaleChanged extends LocaleEvent {
  final Locale locale;
  const LocaleChanged(this.locale);
  @override
  List<Object?> get props => [locale];
}
