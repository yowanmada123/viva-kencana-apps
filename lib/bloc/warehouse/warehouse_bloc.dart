import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'warehouse_event.dart';
part 'warehouse_state.dart';

class WarehouseBloc extends Bloc<WarehouseEvent, WarehouseState> {
  WarehouseBloc() : super(WarehouseInitial()) {
    on<WarehouseEvent>((event, emit) {
      //
    });
  }
}
