import 'package:bloc/bloc.dart';

import '../../../data/repository/incoming_inspection_repository.dart';
import 'coil_scan_event.dart';
import 'coil_scan_state.dart';

/// Memeriksa hasil scan barcode ke v_barcode_coil sebelum coil dimasukkan ke
/// daftar item pada form inspeksi.
class CoilScanBloc extends Bloc<CoilScanEvent, CoilScanState> {
  final IncomingInspectionRepository incomingInspectionRepository;

  CoilScanBloc({required this.incomingInspectionRepository})
    : super(CoilScanInitial()) {
    on<LookupCoilByBarcode>(_onLookup);
    on<ResetCoilScan>((event, emit) => emit(CoilScanInitial()));
  }

  Future<void> _onLookup(
    LookupCoilByBarcode event,
    Emitter<CoilScanState> emit,
  ) async {
    final barcode = event.barcode.trim();

    if (barcode.isEmpty) {
      emit(CoilScanError(message: 'Barcode kosong, coba scan ulang'));
      return;
    }

    emit(CoilScanLoading());

    final result = await incomingInspectionRepository.getCoilByBarcode(
      barcode: barcode,
    );

    result.fold(
      (l) => emit(CoilScanError(message: l.message ?? 'Gagal memeriksa coil')),
      (r) => emit(CoilScanLoaded(r)),
    );
  }
}
