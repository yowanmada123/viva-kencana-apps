import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../data/repository/sales_repository.dart';
import '../../../../../models/sales_activity/history_image.dart';

part 'sales_activity_history_visit_detail_list_image_event.dart';
part 'sales_activity_history_visit_detail_list_image_state.dart';

class SalesActivityHistoryVisitDetailListImageBloc extends Bloc<SalesActivityHistoryVisitDetailListImageEvent, SalesActivityHistoryVisitDetailListImageState> {
  final SalesActivityRepository salesActivityRepository;

  SalesActivityHistoryVisitDetailListImageBloc({required this.salesActivityRepository}) : super(HistoryImagesInitial()) {
    on<FetchSalesActivityImages>(_onFetchImages);
  }

  Future<void> _onFetchImages(
    FetchSalesActivityImages event,
    Emitter<SalesActivityHistoryVisitDetailListImageState> emit,
  ) async {
    emit(HistoryImagesLoading());

    try {
      final res = await salesActivityRepository.getHistoryImages(
        entityId: event.entityId, 
        trId: event.trId, 
        seqId: event.seqId
      );

      res.fold(
        (failure) {
          emit(HistoryImagesError(failure.message ?? 'Failed to fetch images'));
        },
        (images) {
          emit(HistoryImagesSuccess(images));
        },
      );
    } catch (e) {
      emit(HistoryImagesError(e.toString()));
    }
  }
}
