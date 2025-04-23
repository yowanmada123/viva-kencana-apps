import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../data/repository/batch_repository.dart';
import '../../models/delivery_detail.dart';

part 'delivery_detail_event.dart';
part 'delivery_detail_state.dart';

class DeliveryDetailBloc
    extends Bloc<DeliveryDetailEvent, DeliveryDetailState> {
  final BatchRepository batchRepository;

  DeliveryDetailBloc({required this.batchRepository})
    : super(DeliveryDetailInitial()) {
    on<LoadDeliveryDetail>(_loadDeliveryDetail);
  }

  void _loadDeliveryDetail(
    LoadDeliveryDetail event,
    Emitter<DeliveryDetailState> emit,
  ) async {
    emit(DeliveryDetailLoading());

    final res = await batchRepository.getDeliveryDetail(
      batchID: event.batchID,
      companyID: event.companyID,
      millID: event.millID,
      whID: event.whID,
    );

    res.fold(
      (exception) {
        emit(DeliveryDetailFailure(exception));
      },
      (deliveryDetail) {
        emit(DeliveryDetailSuccess(deliveryDetail));
      },
    );
  }
}
