part of 'list_vehicle_bloc.dart';

sealed class ListVehicleState {
  final List<Vehicle> vehicles;

  int get iddleVehicleCount {
    return vehicles.where((vehicle) => vehicle.isIdle).length;
  }

  int get deliveryVehicleCount {
    return vehicles.where((vehicle) => vehicle.isDelivery).length;
  }

  int get loadingVehicleCount {
    return vehicles.where((vehicle) => vehicle.isLoading).length;
  }

  int get readyVehicleCount {
    return vehicles.where((vehicle) => vehicle.isReady).length;
  }

  int get bannedVehicleCount {
    return vehicles.where((vehicle) => vehicle.isBanned).length;
  }

  ListVehicleState({required this.vehicles});
}

final class ListVehicleInitial extends ListVehicleState {
  ListVehicleInitial({required super.vehicles});
}

final class ListVehicleLoadSuccess extends ListVehicleState {
  ListVehicleLoadSuccess({required super.vehicles});
}

final class ListVehicleLoadFailure extends ListVehicleState {
  ListVehicleLoadFailure({required super.vehicles});
}

final class ListVehicleLoading extends ListVehicleState {
  ListVehicleLoading({required super.vehicles});
}
