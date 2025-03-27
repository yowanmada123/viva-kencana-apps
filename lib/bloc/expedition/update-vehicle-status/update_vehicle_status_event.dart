part of 'update_vehicle_status_bloc.dart';

sealed class UpdateVehicleStatusEvent extends Equatable {
  final String vehicleID;
  const UpdateVehicleStatusEvent({required this.vehicleID});

  @override
  List<Object> get props => [];
}

final class UpdateVehicleToIdle extends UpdateVehicleStatusEvent {
  const UpdateVehicleToIdle({required super.vehicleID});
}

final class UpdateVehicleToReady extends UpdateVehicleStatusEvent {
  const UpdateVehicleToReady({required super.vehicleID});
}
