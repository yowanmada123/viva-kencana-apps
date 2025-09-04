import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repository/sales_repository.dart';
import '../../../models/sales_activity/history_visit.dart';

part 'sales_activity_history_visit_event.dart';
part 'sales_activity_history_visit_state.dart';

class SalesActivityHistoryVisitBloc extends Bloc<SalesActivityHistoryVisitEvent, SalesActivityHistoryVisitState> {
  final SalesActivityRepository salesActivityRepository;

  SalesActivityHistoryVisitBloc({required this.salesActivityRepository}) : super(HistoryVisitLoading()) {
    on<LoadHistoryVisit>(_onLoadHistoryVisit);
  }

  Future<void> _onLoadHistoryVisit(
    LoadHistoryVisit event,
    Emitter<SalesActivityHistoryVisitState> emit,
  ) async {
    emit(HistoryVisitLoading());

    final res = await salesActivityRepository.getHistoryVisit(
      startDate: event.startDate,
      endDate: event.endDate,
    );

    res.fold(
      (e) => emit(HistoryVisitFailure(e)),
      (visits) => emit(HistoryVisitLoaded(visits)),
    );
  }
}
