part of 'map_bloc.dart';

enum MapStatus { initial, loading, success, failure }

class MapState extends Equatable {
  final MapStatus status;
  final List<House> units;
  final House? selectedUnit;
  final String? errorMessage;

  const MapState({
    this.status = MapStatus.initial,
    this.units = const [],
    this.selectedUnit,
    this.errorMessage,
  });

  MapState copyWith({
    MapStatus? status,
    List<House>? units,
    House? selectedUnit,
    String? errorMessage,
  }) {
    return MapState(
      status: status ?? this.status,
      units: units ?? this.units,
      selectedUnit: selectedUnit ?? this.selectedUnit,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
  
  @override
  List<Object?> get props => [
    status,
    units,
    selectedUnit,
    errorMessage
  ];
}

final class MapInitial extends MapState {}
