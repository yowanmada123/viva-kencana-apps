part of 'sales_activity_history_visit_detail_list_image_bloc.dart';

abstract class SalesActivityHistoryVisitDetailListImageEvent extends Equatable {
  const SalesActivityHistoryVisitDetailListImageEvent();

  @override
  List<Object?> get props => [];
}

class FetchSalesActivityImages extends SalesActivityHistoryVisitDetailListImageEvent {
  final String entityId;
  final String trId;
  final String seqId;

  const FetchSalesActivityImages({required this.entityId, required this.trId, required this.seqId});

  @override
  List<Object?> get props => [entityId, trId, seqId];
}
