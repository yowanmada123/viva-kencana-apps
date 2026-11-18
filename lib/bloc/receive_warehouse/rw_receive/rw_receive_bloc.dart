import 'dart:convert';

import 'package:bloc/bloc.dart';

import '../../../data/repository/receive_warehouse_repository.dart';
import '../../../models/receive_warehouse/receive_warehouse.dart';

part 'rw_receive_event.dart';
part 'rw_receive_state.dart';

/// Alur satu kali scan:
///   RwScanned  -> RwLookupLoading -> RwLookupSuccess | RwLookupFailure
///   RwConfirm  -> RwSubmitLoading -> RwSubmitSuccess | RwSubmitFailure
///   RwDismiss  -> RwReceiveIdle   (tombol Batal, transfer tetap pending)
///
/// Pengecekan tujuan mill + warehouse dilakukan server di getRwByTrId dan
/// diulang di submitRw, jadi pesan "Item ini tidak untuk diterima di ..."
/// datang dari RwLookupFailure / RwSubmitFailure.
class RwReceiveBloc extends Bloc<RwReceiveEvent, RwReceiveState> {
  final ReceiveWarehouseRepository repository;
  final RwSelection selection;

  RwReceiveBloc({required this.repository, required this.selection})
    : super(RwReceiveIdle()) {
    on<RwScanned>(_onScanned);
    on<RwConfirm>(_onConfirm);
    on<RwDismiss>((_, emit) => emit(RwReceiveIdle()));
  }

  Future<void> _onScanned(RwScanned event, Emitter<RwReceiveState> emit) async {
    final trId = parseTrId(event.code);

    if (trId.isEmpty) {
      emit(RwLookupFailure('QR code tidak berisi tr_id yang bisa dibaca'));
      return;
    }

    emit(RwLookupLoading(trId));

    final result = await repository.getByTrId(trId: trId, selection: selection);

    result.fold(
      (l) => emit(RwLookupFailure(l.message ?? 'Gagal mencari transfer $trId')),
      (r) => emit(RwLookupSuccess(r)),
    );
  }

  Future<void> _onConfirm(RwConfirm event, Emitter<RwReceiveState> emit) async {
    emit(RwSubmitLoading(event.scan));

    final result = await repository.submit(
      trId: event.scan.header.trId,
      selection: selection,
    );

    result.fold(
      (l) => emit(RwSubmitFailure(l.message ?? 'Gagal menerima transfer')),
      (r) => emit(RwSubmitSuccess(event.scan, r)),
    );
  }

  /// Isi QR boleh tr_id mentah atau JSON yang memuat key tr_id.
  static String parseTrId(String raw) {
    final code = raw.trim();
    if (code.startsWith('{')) {
      try {
        final map = jsonDecode(code);
        if (map is Map && map['tr_id'] != null) {
          return map['tr_id'].toString().trim();
        }
      } catch (_) {
        /// Bukan JSON yang valid, perlakukan sebagai teks biasa.
      }
    }
    return code;
  }
}
