import '../../../models/incoming_inspection/inspection_option.dart';

abstract class InspectionOptionState {}

class InspectionOptionInitial extends InspectionOptionState {}

class InspectionOptionLoading extends InspectionOptionState {}

class InspectionOptionLoaded extends InspectionOptionState {
  final InspectionOption option;

  InspectionOptionLoaded(this.option);
}

class InspectionOptionError extends InspectionOptionState {
  final String message;

  InspectionOptionError({required this.message});
}
