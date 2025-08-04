part of 'sales_activity_form_bloc.dart';

class SalesActivityFormState extends Equatable {
  final Set<String> selectedActivities;
  final List<File> images;
  final String officeOption;
  final String userOption;
  final String odometer;
  final Position? position;
  final String address;

  const SalesActivityFormState({
    this.selectedActivities = const {},
    this.images = const [],
    this.officeOption = '',
    this.userOption = '',
    this.odometer = '',
    this.position,
    this.address = '',
  });

  SalesActivityFormState copyWith({
    Set<String>? selectedActivities,
    List<File>? images,
    String? officeOption,
    String? userOption,
    String? odometer,
    Position? position,
    String? address,
  }) {
    return SalesActivityFormState(
      selectedActivities: selectedActivities ?? this.selectedActivities,
      images: images ?? this.images,
      officeOption: officeOption ?? this.officeOption,
      userOption: userOption ?? this.userOption,
      odometer: odometer ?? this.odometer,
      position: position ?? this.position,
      address: address ?? this.address,
    );
  }

  @override
  List<Object?> get props => [selectedActivities, images, officeOption, userOption, odometer, position, address];
}

class SalesActivityFormInitial extends SalesActivityFormState {}

class SalesActivityFormLoading extends SalesActivityFormState {}

class SalesActivityFormSuccess extends SalesActivityFormState {}

class SalesActivityFormError extends SalesActivityFormState {}
