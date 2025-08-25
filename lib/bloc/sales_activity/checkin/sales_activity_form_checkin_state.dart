part of 'sales_activity_form_checkin_bloc.dart';

class SalesActivityFormCheckInState extends Equatable {
  final List<ImageItem> images;
  final String odometer;
  final Position? position;
  final String? address;

  const SalesActivityFormCheckInState({
    this.images = const [],
    this.odometer = '',
    this.position,
    this.address = '',
  });

  SalesActivityFormCheckInState copyWith({
    List<ImageItem>? images,
    String? odometer,
    Position? position,
    String? address,
  }) {
    return SalesActivityFormCheckInState(
      images: images ?? this.images,
      odometer: odometer ?? this.odometer,
      position: position ?? this.position,
      address: address ?? this.address,
    );
  }

  @override
  List<Object?> get props => [
    images,
    odometer,
    position,
    address,
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

class CurrentLocationLoading extends SalesActivityFormCheckInState {}

class CurrentLocationSuccess extends SalesActivityFormCheckInState {
  final Position initialPosition;
  const CurrentLocationSuccess(this.initialPosition);
}

class SalesDataLoading extends SalesActivityFormCheckInState {}

class SalesDataSuccess extends SalesActivityFormCheckInState {
  final SalesInfo sales;

  const SalesDataSuccess({
    required this.sales,
  });

  @override
  List<Object?> get props => [sales];
}

class SalesDataError extends SalesActivityFormCheckInState {
  final String message;

  const SalesDataError(this.message);

  @override
  List<Object?> get props => [message];
}