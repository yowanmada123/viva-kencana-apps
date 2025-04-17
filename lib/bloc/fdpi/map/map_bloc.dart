import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vivakencanaapp/data/repository/fdpi_repository.dart';
import 'package:vivakencanaapp/models/fdpi/house.dart';

part 'map_event.dart';
part 'map_state.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  final FdpiRepository fdpiRepository;
  
  MapBloc({required this.fdpiRepository}) : super(MapInitial()) {
    on<LoadMap>(_onLoadMap);
    on<UnitChanged>(_onUnitChanged);
  }

  Future<void> _onLoadMap(LoadMap event, Emitter<MapState> emit) async {
    emit(state.copyWith(status: MapStatus.loading));
    final result = await fdpiRepository.getHouses(event.idCluster);

    result.fold(
      (failure) => emit(state.copyWith(
        status: MapStatus.failure,
        errorMessage: failure.message,
      )),
      (units) {
        emit(state.copyWith(
        status: MapStatus.success,
        units: units, 
        ));
      },
    );
  }

  Future<void> _onUnitChanged(UnitChanged event, Emitter<MapState> emit) async {
    emit(state.copyWith(selectedUnit: event.unit));
  }
}
