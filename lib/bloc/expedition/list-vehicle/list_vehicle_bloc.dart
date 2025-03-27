import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../data/repository/expedition_repository.dart';
import '../../../models/vehicle.dart';

part 'list_vehicle_event.dart';
part 'list_vehicle_state.dart';

class ListVehicleBloc extends Bloc<ListVehicleEvent, ListVehicleState> {
  final ExpeditionRepository expeditionRepository;

  ListVehicleBloc({required this.expeditionRepository})
    : super(ListVehicleInitial(vehicles: [])) {
    on<StartLongPollingListVehicle>(_startLongPolling);
    on<LoadListVehicle>(_loadVehicles);
  }

  void _startLongPolling(
    StartLongPollingListVehicle event,
    Emitter<ListVehicleState> emit,
  ) async {
    if (state is! ListVehicleLoading) {
      await _fetchListVehicles(emit);
    }
  }

  void _loadVehicles(
    LoadListVehicle event,
    Emitter<ListVehicleState> emit,
  ) async {
    emit(ListVehicleLoading(vehicles: []));
    await _fetchListVehicles(emit);
  }

  Future<void> _fetchListVehicles(Emitter<ListVehicleState> emit) async {
    final currentDataVehicle = state.vehicles;
    final res = await expeditionRepository.getVehicles(userId: '');
    res.fold(
      (exception) {
        emit(ListVehicleLoadFailure(vehicles: currentDataVehicle));
      },
      (vehicles) {
        emit(ListVehicleInitial(vehicles: vehicles));
        emit(ListVehicleLoadSuccess(vehicles: vehicles));
      },
    );
  }
}
