part of 'sales_activity_form_bloc.dart';

abstract class SalesActivityFormEvent extends Equatable {
  const SalesActivityFormEvent();

  @override
  List<Object?> get props => [];
}

class ToggleActivityEvent extends SalesActivityFormEvent {
  final String activity;

  const ToggleActivityEvent(this.activity);

  @override
  List<Object?> get props => [activity];
}

class SetImageEvent extends SalesActivityFormEvent {
  final File image;

  const SetImageEvent(this.image);

  @override
  List<Object?> get props => [image];
}

class AddImageEvent extends SalesActivityFormEvent {
  final File image;

  const AddImageEvent(this.image);

  @override
  List<Object?> get props => [image];
}

class SetOfficeOption extends SalesActivityFormEvent {
  final String option;

  const SetOfficeOption(this.option);

  @override
  List<Object?> get props => [option];
}

class SetUserOption extends SalesActivityFormEvent {
  final String option;

  const SetUserOption(this.option);

  @override
  List<Object?> get props => [option];
}


class SetLocationEvent extends SalesActivityFormEvent {}