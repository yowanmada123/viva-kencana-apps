import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../data/repository/expedition_repository.dart';

part 'update_vehicle_status_event.dart';
part 'update_vehicle_status_state.dart';

class UpdateVehicleStatusBloc
    extends Bloc<UpdateVehicleStatusEvent, UpdateVehicleStatusState> {
  final ExpeditionRepository expeditionRepository;

  UpdateVehicleStatusBloc({
    required this.expeditionRepository,
  }) : super(UpdateVehicleStatusInitial()) {
    on<UpdateVehicleToIdle>(_updateVehicleToIdle);
    on<UpdateVehicleToReady>(_updateVehicleToReady);
  }

  void _updateVehicleToIdle(
    UpdateVehicleStatusEvent event,
    Emitter<UpdateVehicleStatusState> emit,
  ) async {
    emit(UpdateVehicleStatusLoading());
    final res = await expeditionRepository.updateVehicleStatus(
        vehicleID: event.vehicleID, status: 'I');

    res.fold(
      (exception) => emit(UpdateVehicleStatusFailure()),
      (right) => emit(UpdateVehicleStatusSuccess()),
    );
  }

  void _updateVehicleToReady(
    UpdateVehicleStatusEvent event,
    Emitter<UpdateVehicleStatusState> emit,
  ) async {
    emit(UpdateVehicleStatusLoading());
    final res = await expeditionRepository.updateVehicleStatus(
        vehicleID: event.vehicleID, status: 'R');

    res.fold(
      (exception) => emit(UpdateVehicleStatusFailure()),
      (right) => emit(UpdateVehicleStatusSuccess()),
    );
  }
}
