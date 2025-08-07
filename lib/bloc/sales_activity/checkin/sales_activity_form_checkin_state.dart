part of 'sales_activity_form_checkin_bloc.dart';

class SalesActivityFormCheckInState extends Equatable {
  final File? imageCheckIn;
  final File? imageCheckOut;
  final String odometer;
  final Position? position;
  final String address;
  final bool isCheckedIn;
  final bool isCheckedOut;

  const SalesActivityFormCheckInState({
    this.imageCheckIn,
    this.imageCheckOut,
    this.odometer = '',
    this.position,
    this.address = '',
    this.isCheckedIn = false,
    this.isCheckedOut = false,
  });

  SalesActivityFormCheckInState copyWith({
    File? imageCheckIn,
    File? imageCheckOut,
    String? odometer,
    Position? position,
    String? address,
    bool? isCheckedIn,
    bool? isCheckedOut,
  }) {
    return SalesActivityFormCheckInState(
      imageCheckIn: imageCheckIn ?? this.imageCheckIn,
      imageCheckOut: imageCheckOut ?? this.imageCheckOut,
      odometer: odometer ?? this.odometer,
      position: position ?? this.position,
      address: address ?? this.address,
      isCheckedIn: isCheckedIn ?? this.isCheckedIn,
      isCheckedOut: isCheckedOut ?? this.isCheckedOut,
    );
  }

  @override
  List<Object?> get props => [
        imageCheckIn,
        imageCheckOut,
        odometer,
        position,
        address,
        isCheckedIn,
        isCheckedOut,
      ];
}

class SalesActivityFormCheckInInitial extends SalesActivityFormCheckInState {}

class SalesActivityFormCheckInLoading extends SalesActivityFormCheckInState {}

class SalesActivityFormCheckInSuccess extends SalesActivityFormCheckInState {}

class SalesActivityFormCheckInError extends SalesActivityFormCheckInState {
  final String message;

  const SalesActivityFormCheckInError(this.message);

  @override
  List<Object?> get props => [message];
}

class CheckinInitial extends SalesActivityFormCheckInState {}

class CheckinLoading extends SalesActivityFormCheckInState {}

class   CheckinLoaded extends SalesActivityFormCheckInState {
  final CheckinInfo checkinInfo;

  const CheckinLoaded(this.checkinInfo);

  @override
  bool get isCheckedIn => checkinInfo.stat == 'Y';
}

class CheckinError extends SalesActivityFormCheckInState {
  final String message;

  const CheckinError(this.message);
}
