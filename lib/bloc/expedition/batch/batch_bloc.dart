import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../data/repository/batch_repository.dart';
import '../../../models/batch.dart';

part 'batch_event.dart';
part 'batch_state.dart';

class BatchBloc extends Bloc<BatchEvent, BatchState> {
  final BatchRepository batchRepository;

  BatchBloc({required this.batchRepository}) : super(BatchInitial()) {
    on<LoadBatch>(_loadBatch);
  }

  void _loadBatch(LoadBatch event, Emitter<BatchState> emit) async {
    emit(BatchLoading());

    final res = await batchRepository.getWarehouse(
      deliveryID: event.deliveryId,
    );

    res.fold(
      (exception) {
        emit(BatchFailure(exception.message!));
      },
      (warehouses) {
        emit(BatchSuccess(warehouses));
      },
    );
  }
}
