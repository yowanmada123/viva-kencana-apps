part of 'sales_activity_history_visit_upload_image_bloc.dart';

abstract class SalesActivityHistoryVisitUploadImageEvent {}

class SubmitUploadImage extends SalesActivityHistoryVisitUploadImageEvent {
  final String entityId;
  final String trId;
  final String seqId;
  final File imageFile;
  final String remark;

  SubmitUploadImage({
    required this.entityId,
    required this.seqId,
    required this.trId,
    required this.imageFile,
    required this.remark,
  });

  List<Object?> get props => [entityId, seqId, trId, imageFile, remark];
}