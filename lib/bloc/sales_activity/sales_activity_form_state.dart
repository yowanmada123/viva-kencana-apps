part of 'sales_activity_form_bloc.dart';

class SalesActivityFormState extends Equatable {
  final Set<String> selectedActivities;
  final List<ImageItem> images;
  final String odometer;
  final Position? position;
  final Position? currentPosition;
  final String address;
  final bool isLoadingLocation;

  const SalesActivityFormState({
    this.selectedActivities = const {},
    this.images = const [],
    this.odometer = '',
    this.position,
    this.currentPosition,
    this.address = '',
    this.isLoadingLocation = false,
  });

  SalesActivityFormState copyWith({
    Set<String>? selectedActivities,
    List<ImageItem>? images,
    String? odometer,
    Position? position,
    Position? currentPosition,
    String? address,
    bool? isLoadingLocation,
  }) {
    return SalesActivityFormState(
      selectedActivities: selectedActivities ?? this.selectedActivities,
      images: images ?? this.images,
      odometer: odometer ?? this.odometer,
      position: position ?? this.position,
      currentPosition: currentPosition ?? this.currentPosition,
      address: address ?? this.address,
      isLoadingLocation: isLoadingLocation ?? this.isLoadingLocation,
    );
  }

  @override
  List<Object?> get props => [
    selectedActivities,
    images,
    odometer,
    position,
    address,
    isLoadingLocation,
    currentPosition,
  ];
}

class SalesActivityInitial extends SalesActivityFormState {}

class SalesActivityLoading extends SalesActivityFormState {}

class SalesActivityError extends SalesActivityFormState {
  final String message;
  const SalesActivityError(this.message);
}

class CustomerSearchSuccess extends SalesActivityFormState {
  final List<CustomerInfo> customers;

  const CustomerSearchSuccess(this.customers);

  @override
  List<Object?> get props => [customers];
}

class CustomerSearchLoading extends SalesActivityFormState {}

class CustomerSearchError extends SalesActivityFormState {
  final String message;

  const CustomerSearchError(this.message);

  @override
  List<Object?> get props => [message];
}

class ProvinceLoadSuccess extends SalesActivityFormState {
  final List<String> provinces;
  const ProvinceLoadSuccess(this.provinces);
}

class CityLoadSuccess extends SalesActivityFormState {
  final List<String> cities;
  const CityLoadSuccess(this.cities);
}

class DistrictLoadSuccess extends SalesActivityFormState {
  final List<String> districts;
  const DistrictLoadSuccess(this.districts);
}

class VillageLoadSuccess extends SalesActivityFormState {
  final List<String> villages;
  const VillageLoadSuccess(this.villages);
}

class CustomerDetailLoadSuccess extends SalesActivityFormState {
  final CustomerDetail customerDetail;

  const CustomerDetailLoadSuccess(this.customerDetail);
}

class SalesActivityFormInitial extends SalesActivityFormState {}

class SalesActivityFormLoading extends SalesActivityFormState {}

class SalesActivityFormSuccess extends SalesActivityFormState {}

class SalesActivityFormFailure extends SalesActivityFormState {
  final String error;
  const SalesActivityFormFailure(this.error);
}

class CurrentLocationLoading extends SalesActivityFormState {}

class CurrentLocationSuccess extends SalesActivityFormState {
  final Position initialPosition;
  const CurrentLocationSuccess(this.initialPosition);
}
