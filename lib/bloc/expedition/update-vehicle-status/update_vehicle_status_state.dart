part of 'update_vehicle_status_bloc.dart';

sealed class UpdateVehicleStatusState extends Equatable {
  const UpdateVehicleStatusState();

  @override
  List<Object> get props => [];
}

final class UpdateVehicleStatusInitial extends UpdateVehicleStatusState {}

final class UpdateVehicleStatusSuccess extends UpdateVehicleStatusState {}

final class UpdateVehicleStatusLoading extends UpdateVehicleStatusState {}

final class UpdateVehicleStatusFailure extends UpdateVehicleStatusState {}
