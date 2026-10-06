import 'package:bloc/bloc.dart';

import '../../../data/repository/incoming_inspection_repository.dart';
import '../../../models/incoming_inspection/barcode_coil.dart';
import 'barcode_coil_event.dart';
import 'barcode_coil_state.dart';

/// Mengelola daftar riwayat inspeksi dari view v_barcode_coil.
///
/// Hanya [LoadBarcodeCoil] yang menembak API. Pencarian teks dikerjakan di
/// sisi aplikasi terhadap data yang sudah ada, karena satu baris view sudah
/// memuat seluruh kolom yang dibutuhkan layar detail.
class BarcodeCoilBloc extends Bloc<BarcodeCoilEvent, BarcodeCoilState> {
  final IncomingInspectionRepository incomingInspectionRepository;

  BarcodeCoilBloc({required this.incomingInspectionRepository})
    : super(BarcodeCoilInitial()) {
    on<LoadBarcodeCoil>(_onLoad);
    on<FilterBarcodeCoil>(_onFilterKeyword);
  }

  Future<void> _onLoad(
    LoadBarcodeCoil event,
    Emitter<BarcodeCoilState> emit,
  ) async {
    emit(BarcodeCoilLoading());

    final result = await incomingInspectionRepository.getBarcodeCoils(
      vendorId: event.vendorId,
      startDate: event.startDate,
      endDate: event.endDate,
    );

    result.fold(
      (l) => emit(
        BarcodeCoilError(message: l.message ?? 'Gagal mengambil data coil'),
      ),
      (r) => emit(BarcodeCoilLoaded(all: r, data: r)),
    );
  }

  void _onFilterKeyword(
    FilterBarcodeCoil event,
    Emitter<BarcodeCoilState> emit,
  ) {
    final current = state;
    if (current is! BarcodeCoilLoaded) return;

    emit(
      BarcodeCoilLoaded(
        all: current.all,
        data: _apply(current.all, event.keyword),
        keyword: event.keyword,
      ),
    );
  }

  List<BarcodeCoil> _apply(List<BarcodeCoil> source, String keyword) {
    final query = keyword.trim().toLowerCase();
    if (query.isEmpty) return source;

    return source.where((coil) {
      return coil.coilId.toLowerCase().contains(query) ||
          coil.noSj.toLowerCase().contains(query) ||
          coil.noKendaraan.toLowerCase().contains(query) ||
          coil.trxId.toLowerCase().contains(query) ||
          coil.prodCode.toLowerCase().contains(query) ||
          coil.descr.toLowerCase().contains(query) ||
          coil.plId.toLowerCase().contains(query) ||
          coil.containerId.toLowerCase().contains(query);
    }).toList();
  }
}
