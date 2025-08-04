part of 'sales_activity_form_checkin_bloc.dart';

abstract class SalesActivityFormCheckInEvent extends Equatable {
  const SalesActivityFormCheckInEvent();

  @override
  List<Object?> get props => [];
}

class SetImageEvent extends SalesActivityFormCheckInEvent {
  final File image;

  const SetImageEvent(this.image);

  @override
  List<Object?> get props => [image];
}


class GetLocationEvent extends SalesActivityFormCheckInEvent {
  final Position position;
  final String address;
  GetLocationEvent(this.position, this.address);
}

class SetLocationEvent extends SalesActivityFormCheckInEvent {}
class SetCheckInEvent extends SalesActivityFormCheckInEvent {}
class SetCheckOutEvent extends SalesActivityFormCheckInEvent {} 