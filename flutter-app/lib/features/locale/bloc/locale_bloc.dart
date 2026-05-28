import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
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
    emit(event.locale.languageCode == 'th'
        ? LocaleState.th()
        : LocaleState.en());
  }
}
