part of 'sales_activity_form_bloc.dart';

class SalesActivityFormState extends Equatable {
  final Set<String> selectedActivities;
  final File? image;
  final String officeOption;
  final String userOption;

  const SalesActivityFormState({
    this.selectedActivities = const {},
    this.image,
    this.officeOption = '',
    this.userOption = '',
  });

  SalesActivityFormState copyWith({
    Set<String>? selectedActivities,
    File? image,
    String? officeOption,
    String? userOption,
  }) {
    return SalesActivityFormState(
      selectedActivities: selectedActivities ?? this.selectedActivities,
      image: image ?? this.image,
      officeOption: officeOption ?? this.officeOption,
      userOption: userOption ?? this.userOption,
    );
  }

  @override
  List<Object?> get props => [selectedActivities, image, officeOption, userOption];
}

class SalesActivityFormInitial extends SalesActivityFormState {}

class SalesActivityFormLoading extends SalesActivityFormState {}

class SalesActivityFormSuccess extends SalesActivityFormState {}

class SalesActivityFormError extends SalesActivityFormState {}
