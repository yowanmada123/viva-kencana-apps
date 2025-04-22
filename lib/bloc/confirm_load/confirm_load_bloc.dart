import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../data/repository/batch_repository.dart';

part 'confirm_load_event.dart';
part 'confirm_load_state.dart';

class ConfirmLoadBloc extends Bloc<ConfirmLoadEvent, ConfirmLoadState> {
  final BatchRepository batchRepository;

  ConfirmLoadBloc({required this.batchRepository})
    : super(ConfirmLoadInitial()) {
    on<ConfirmLoadSubmitted>(confirmLoad);
  }

  void confirmLoad(
    ConfirmLoadSubmitted event,
    Emitter<ConfirmLoadState> emit,
  ) async {
    emit(ConfirmLoadLoading());

    final res = await batchRepository.confirmLoad(
      batchID: event.batchID,
      companyID: event.companyID,
      millID: event.millID,
      whID: event.whID,
    );

    res.fold(
      (exception) {
        emit(ConfirmLoadError(message: exception.message));
      },
      (deliveryDetail) {
        emit(ConfirmLoadSuccess());
      },
    );
  }
}
