part of 'warehouse_bloc.dart';

sealed class WarehouseState extends Equatable {
  const WarehouseState();
  
  @override
  List<Object> get props => [];
}

final class WarehouseInitial extends WarehouseState {}
