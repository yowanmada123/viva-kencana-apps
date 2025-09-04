part of 'sales_activity_history_visit_bloc.dart';

abstract class SalesActivityHistoryVisitState {}

class HistoryVisitLoading extends SalesActivityHistoryVisitState {}

class HistoryVisitLoaded extends SalesActivityHistoryVisitState {
  final List<HistoryVisit> visits;

  HistoryVisitLoaded(this.visits);
}

class HistoryVisitFailure extends SalesActivityHistoryVisitState {
  final Exception exception;

  HistoryVisitFailure(this.exception);
}
