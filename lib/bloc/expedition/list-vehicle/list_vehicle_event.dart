part of 'list_vehicle_bloc.dart';

sealed class ListVehicleEvent extends Equatable {
  final String userId;
  const ListVehicleEvent({required this.userId});

  @override
  List<Object> get props => [];
}

final class StartLongPollingListVehicle extends ListVehicleEvent {
  const StartLongPollingListVehicle({required super.userId});
}

final class LoadListVehicle extends ListVehicleEvent {
  const LoadListVehicle({required super.userId});
}
