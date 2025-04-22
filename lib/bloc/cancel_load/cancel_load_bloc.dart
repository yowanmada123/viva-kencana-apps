import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../data/repository/batch_repository.dart';

part 'cancel_load_event.dart';
part 'cancel_load_state.dart';

class CancelLoadBloc extends Bloc<CancelLoadEvent, CancelLoadState> {
  final BatchRepository batchRepository;

  CancelLoadBloc({required this.batchRepository}) : super(CancelLoadInitial()) {
    on<CancelLoadSubmitted>(cancelLoad);
  }

  void cancelLoad(
    CancelLoadSubmitted event,
    Emitter<CancelLoadState> emit,
  ) async {
    emit(CancelLoadLoading());

    final res = await batchRepository.cancelLoad(
      batchID: event.batchID,
      delivID: event.delivID,
      companyID: event.companyID,
      millID: event.millID,
      whID: event.whID,
      itemNum: event.itemNum,
    );

    res.fold(
      (exception) {
        emit(CancelLoadError(message: exception.message));
      },
      (deliveryDetail) {
        emit(CancelLoadSuccess());
      },
    );
  }
}
