import '../../../models/incoming_inspection/inspection_form.dart';

abstract class InspectionSubmitEvent {}

/// Simpan satu inspection_hdr beserta seluruh inspection_dtl-nya.
class SubmitInspection extends InspectionSubmitEvent {
  final InspectionForm form;

  SubmitInspection(this.form);
}

/// Kembalikan state ke awal, dipanggil setelah pesan sukses/gagal ditampilkan
/// supaya bloc yang hidup global tidak menahan hasil submit sebelumnya.
class ResetInspectionSubmit extends InspectionSubmitEvent {}
