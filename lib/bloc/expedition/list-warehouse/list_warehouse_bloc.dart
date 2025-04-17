import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../data/repository/warehouse_repository.dart';
import '../../../models/warehouse.dart';

part 'list_warehouse_event.dart';
part 'list_warehouse_state.dart';

class ListWarehouseBloc extends Bloc<ListWarehouseEvent, ListWarehouseState> {
  final WarehouseRepository warehouseRepository;

  ListWarehouseBloc({required this.warehouseRepository})
    : super(ListWarehouseInitial()) {
    on<LoadListWarehouse>(_loadWarehouse);
  }

  void _loadWarehouse(
    LoadListWarehouse event,
    Emitter<ListWarehouseState> emit,
  ) async {
    emit(ListWarehouseLoading());

    final res = await warehouseRepository.getWarehouse(
      deliveryID: event.deliveryId,
    );

    res.fold(
      (exception) {
        emit(ListWarehouseFailure(exception.message!));
      },
      (warehouses) {
        emit(ListWarehouseSuccess(warehouses));
      },
    );
  }
}
