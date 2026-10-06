import 'package:bloc/bloc.dart';

import '../../../data/repository/incoming_inspection_repository.dart';
import 'vendor_event.dart';
import 'vendor_state.dart';

/// Mencari vendor sambil user mengetik, di layar filter Incoming Inspection.
/// Keyword bisa berupa nama vendor maupun kode vendor - backend yang
/// menentukan kolom mana yang dicocokkan.
class VendorBloc extends Bloc<VendorEvent, VendorState> {
  final IncomingInspectionRepository incomingInspectionRepository;

  VendorBloc({required this.incomingInspectionRepository})
    : super(VendorInitial()) {
    on<SearchVendor>(_onSearch);
    on<ClearVendor>(_onClear);
  }

  Future<void> _onSearch(SearchVendor event, Emitter<VendorState> emit) async {
    final keyword = event.keyword.trim();

    /// Ketikan terlalu pendek belum layak dikirim ke server.
    if (keyword.length < 2) {
      emit(VendorInitial());
      return;
    }

    emit(VendorLoading());

    final result = await incomingInspectionRepository.getVendors(
      keyword: keyword,
    );

    result.fold(
      (l) => emit(VendorError(message: l.message ?? 'Gagal mengambil vendor')),
      (r) => emit(VendorLoaded(r)),
    );
  }

  void _onClear(ClearVendor event, Emitter<VendorState> emit) {
    emit(VendorInitial());
  }
}
