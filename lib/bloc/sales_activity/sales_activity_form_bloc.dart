import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'sales_activity_form_event.dart';
part 'sales_activity_form_state.dart';

class SalesActivityFormBloc extends Bloc<SalesActivityFormEvent, SalesActivityFormState> {
  SalesActivityFormBloc() : super(const SalesActivityFormState()) {
    on<ToggleActivityEvent>((event, emit) {
      final updated = Set<String>.from(state.selectedActivities);
      if (updated.contains(event.activity)) {
        updated.remove(event.activity);
      } else {
        updated.add(event.activity);
      }
      emit(state.copyWith(selectedActivities: updated));
    });

    on<AddImageEvent>((event, emit) {
      final updatedImages = List<File>.from(state.images)..add(event.image);
      emit(state.copyWith(images: updatedImages));
    });

    on<SetOfficeOption>((event, emit) {
      emit(state.copyWith(officeOption: event.option));
    });

    on<SetUserOption>((event, emit) {
      emit(state.copyWith(userOption: event.option));
    });
  }
}
