part of 'sales_activity_history_visit_detail_bloc.dart';

abstract class SalesActivityHistoryVisitDetailState {}

class HistoryDetailLoading extends SalesActivityHistoryVisitDetailState {}

class HistoryDetailLoaded extends SalesActivityHistoryVisitDetailState {
  final List<HistoryDetail> details;

  HistoryDetailLoaded(this.details);
}

class HistoryDetailFailure extends SalesActivityHistoryVisitDetailState {
  final Exception exception;

  HistoryDetailFailure(this.exception);
}
