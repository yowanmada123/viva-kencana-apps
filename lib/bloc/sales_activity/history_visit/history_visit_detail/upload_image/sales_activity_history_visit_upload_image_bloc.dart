
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

import '../../../../../data/repository/sales_repository.dart';
import '../../../../../utils/image_to_base_64_converter.dart';

part 'sales_activity_history_visit_upload_image_event.dart';
part 'sales_activity_history_visit_upload_image_state.dart';

class SalesActivityHistoryVisitUploadImageBloc extends Bloc<SalesActivityHistoryVisitUploadImageEvent, SalesActivityHistoryVisitUploadImageState> {
  final SalesActivityRepository salesActivityRepository;

  SalesActivityHistoryVisitUploadImageBloc({required this.salesActivityRepository}) : super(UploadImageLoading()) {
    on<SubmitUploadImage>(_onSubmitUploadImage);
  }

  Future<void> _onSubmitUploadImage(
    SubmitUploadImage event,
    Emitter<SalesActivityHistoryVisitUploadImageState> emit,
  ) async {
    emit(UploadImageLoading());
    File originalFile = event.imageFile;
    File? compressed = await compressImage(originalFile);
    final fileToEncode = compressed ?? originalFile;
    final url = await imageToDataUri(fileToEncode);
    final result = await salesActivityRepository.submitImagesDetail(
      entityId: event.entityId,
      trId: event.trId,
      seqId: event.seqId,
      image: url,
      remark: event.remark,
    );

    result.fold(
      (failure) {
        emit(UploadImageError(failure.message ?? 'Upload gagal'));
        emit(UploadImageInitial());
      },
      (_) { 
        emit(UploadImageSuccess());
        emit(UploadImageInitial());
      },
    );
  }

  Future<File?> compressImage(File file) async {
    final targetPath =
        "${file.parent.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg";

    final result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 60,
    );

    return result != null ? File(result.path) : null;
  }
}

