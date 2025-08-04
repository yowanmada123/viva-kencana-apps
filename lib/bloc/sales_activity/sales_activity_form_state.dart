part of 'sales_activity_form_bloc.dart';

class SalesActivityFormState extends Equatable {
  final Set<String> selectedActivities;
  final List<File> images;
  final String officeOption;
  final String userOption;

  const SalesActivityFormState({
    this.selectedActivities = const {},
    this.images = const [],
    this.officeOption = '',
    this.userOption = '',
  });

  SalesActivityFormState copyWith({
    Set<String>? selectedActivities,
    List<File>? images,
    String? officeOption,
    String? userOption,
  }) {
    return SalesActivityFormState(
      selectedActivities: selectedActivities ?? this.selectedActivities,
      images: images ?? this.images,
      officeOption: officeOption ?? this.officeOption,
      userOption: userOption ?? this.userOption,
    );
  }

  @override
  List<Object?> get props => [selectedActivities, images, officeOption, userOption];
}

class SalesActivityFormInitial extends SalesActivityFormState {}

class SalesActivityFormLoading extends SalesActivityFormState {}

class SalesActivityFormSuccess extends SalesActivityFormState {}

class SalesActivityFormError extends SalesActivityFormState {}
