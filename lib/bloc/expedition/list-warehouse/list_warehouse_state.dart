part of 'list_warehouse_bloc.dart';

abstract class ListWarehouseState extends Equatable {
  const ListWarehouseState();

  @override
  List<Object> get props => [];
}

class ListWarehouseInitial extends ListWarehouseState {}

class ListWarehouseLoading extends ListWarehouseState {}

class ListWarehouseSuccess extends ListWarehouseState {
  final List<Warehouse> warehouses;

  ListWarehouseSuccess(this.warehouses);

  @override
  List<Object> get props => [warehouses];
}

class ListWarehouseFailure extends ListWarehouseState {
  final String message;

  ListWarehouseFailure(this.message);

  @override
  List<Object> get props => [message];
}
