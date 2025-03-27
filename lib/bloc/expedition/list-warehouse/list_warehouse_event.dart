part of 'list_warehouse_bloc.dart';

abstract class ListWarehouseEvent extends Equatable {
  const ListWarehouseEvent();

  @override
  List<Object> get props => [];
}

class LoadListWarehouse extends ListWarehouseEvent {
  final String deliveryId;

  LoadListWarehouse({required this.deliveryId});

  @override
  List<Object> get props => [deliveryId];
}
