part of 'sales_activity_history_visit_detail_list_image_bloc.dart';

abstract class SalesActivityHistoryVisitDetailListImageState extends Equatable {
  const SalesActivityHistoryVisitDetailListImageState();

  @override
  List<Object?> get props => [];
}

class HistoryImagesInitial extends SalesActivityHistoryVisitDetailListImageState {}

class HistoryImagesLoading extends SalesActivityHistoryVisitDetailListImageState {}

class HistoryImagesSuccess extends SalesActivityHistoryVisitDetailListImageState {
  final List<HistoryImage> images;

  const HistoryImagesSuccess(this.images);

  @override
  List<Object?> get props => [images];
}

class HistoryImagesError extends SalesActivityHistoryVisitDetailListImageState {
  final String message;

  const HistoryImagesError(this.message);

  @override
  List<Object?> get props => [message];
}