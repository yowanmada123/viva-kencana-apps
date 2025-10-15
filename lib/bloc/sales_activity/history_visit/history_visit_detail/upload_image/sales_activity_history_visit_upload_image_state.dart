part of 'sales_activity_history_visit_upload_image_bloc.dart';

abstract class SalesActivityHistoryVisitUploadImageState {}

class UploadImageInitial extends SalesActivityHistoryVisitUploadImageState {}

class UploadImageLoading extends SalesActivityHistoryVisitUploadImageState {}

class UploadImageSuccess extends SalesActivityHistoryVisitUploadImageState {}

class UploadImageError extends SalesActivityHistoryVisitUploadImageState {
  final String message;

  UploadImageError(this.message);

  List<Object?> get props => [message];
}
