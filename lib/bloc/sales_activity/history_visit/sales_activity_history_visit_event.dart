part of 'sales_activity_history_visit_bloc.dart';

abstract class SalesActivityHistoryVisitEvent {}

class LoadHistoryVisit extends SalesActivityHistoryVisitEvent {
  final String startDate;
  final String endDate;

  LoadHistoryVisit({required this.startDate, required this.endDate});
}
