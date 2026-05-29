import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../core/l10n/strings.dart';

part 'locale_event.dart';
part 'locale_state.dart';

/// Controls app language (EN / TH).
/// Company pattern: simple feature BLoC for cross-cutting concerns.
class LocaleBloc extends Bloc<LocaleEvent, LocaleState> {
  LocaleBloc() : super(LocaleState.en()) {
    on<LocaleChanged>(_onChanged);
  }

  void _onChanged(LocaleChanged event, Emitter<LocaleState> emit) {
    final newState =
        event.locale.languageCode == 'th' ? LocaleState.th() : LocaleState.en();

    Intl.defaultLocale = newState.locale.languageCode;
    if (newState.locale.languageCode == 'th') {
      timeago.setLocaleMessages('th', timeago.ThMessages());
    }

    emit(newState);
  }
}
