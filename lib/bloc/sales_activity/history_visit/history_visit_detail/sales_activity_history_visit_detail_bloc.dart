

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/repository/sales_repository.dart';
import '../../../../models/sales_activity/history_detail.dart';

part 'sales_activity_history_visit_detail_event.dart';
part 'sales_activity_history_visit_detail_state.dart';

class SalesActivityHistoryVisitDetailBloc extends Bloc<SalesActivityHistoryVisitDetailEvent, SalesActivityHistoryVisitDetailState> {
  final SalesActivityRepository salesActivityRepository;

  SalesActivityHistoryVisitDetailBloc({required this.salesActivityRepository}) : super(HistoryDetailLoading()) {
    on<LoadHistoryDetail>(_onLoadHistoryDetail);
  }

  Future<void> _onLoadHistoryDetail(
    LoadHistoryDetail event,
    Emitter<SalesActivityHistoryVisitDetailState> emit,
  ) async {
    emit(HistoryDetailLoading());
    final res = await salesActivityRepository.getHistoryDetail(activityId: event.activityId);

    res.fold(
      (exception) => emit(HistoryDetailFailure(exception)),
      (details) => emit(HistoryDetailLoaded(details)),
    );
  }
}

