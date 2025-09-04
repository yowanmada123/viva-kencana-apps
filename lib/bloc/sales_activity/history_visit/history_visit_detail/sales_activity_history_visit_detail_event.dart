part of 'sales_activity_history_visit_detail_bloc.dart';

abstract class SalesActivityHistoryVisitDetailEvent {}

class LoadHistoryDetail extends SalesActivityHistoryVisitDetailEvent {
  final String activityId;

  LoadHistoryDetail(this.activityId);
}

