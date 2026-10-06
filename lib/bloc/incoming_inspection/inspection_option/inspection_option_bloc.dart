import 'package:bloc/bloc.dart';

import '../../../data/repository/incoming_inspection_repository.dart';
import 'inspection_option_event.dart';
import 'inspection_option_state.dart';

/// Menyediakan isi dropdown form header: crew (section ENT), shift, cuaca,
/// kondisi atap, kondisi terpal, storage, dan pilihan Kondisi CRC.
///
/// Semuanya datang dari server dalam satu panggilan, jadi perubahan master
/// crew atau penambahan kode tidak perlu rilis aplikasi baru.
class InspectionOptionBloc
    extends Bloc<InspectionOptionEvent, InspectionOptionState> {
  final IncomingInspectionRepository incomingInspectionRepository;

  InspectionOptionBloc({required this.incomingInspectionRepository})
    : super(InspectionOptionInitial()) {
    on<LoadInspectionOption>(_onLoad);
  }

  Future<void> _onLoad(
    LoadInspectionOption event,
    Emitter<InspectionOptionState> emit,
  ) async {
    emit(InspectionOptionLoading());

    final result = await incomingInspectionRepository.getInspectionOption(
      millId: event.millId,
    );

    result.fold(
      (l) => emit(
        InspectionOptionError(
          message: l.message ?? 'Gagal mengambil opsi inspeksi',
        ),
      ),
      (r) => emit(InspectionOptionLoaded(r)),
    );
  }
}
