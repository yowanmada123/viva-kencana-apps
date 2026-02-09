import 'package:bloc/bloc.dart';
import 'package:vivakencanaapp/data/repository/stock_opname/barang_jadi_repository.dart';
import 'package:vivakencanaapp/models/stock_opname/barang_jadi.dart';

part 'barang_jadi_event.dart';
part 'barang_jadi_state.dart';

class BarangJadiBloc extends Bloc<BarangJadiEvent, BarangJadiState> {
  final BarangJadiRepository barangJadiRepository;

  BarangJadiBloc({required this.barangJadiRepository})
    : super(BarangJadiInitial()) {
    on<SelectBarangJadi>(_onSelect);
    on<SearchBarangJadi>(_onSearch);
    on<ClearBarangJadi>(_onClear);
    on<SearchBarangJadiFromScan>(_onSearchFromScan);
  }

  Future<void> _onSearch(
    SearchBarangJadi event,
    Emitter<BarangJadiState> emit,
  ) async {
    if (event.keyword.length < 3) return;

    emit(BarangJadiLoading());

    final result = await barangJadiRepository.searchBarangJadi(
      namaBarang: event.keyword,
    );

    result.fold(
      (l) => emit(BarangJadiError(l.message!)),
      (data) => emit(BarangJadiLoaded(data, null)),
    );
  }

  void _onSelect(SelectBarangJadi event, Emitter<BarangJadiState> emit) {
    emit(BarangJadiLoaded(const [], event.item));
  }

  void _onClear(ClearBarangJadi event, Emitter<BarangJadiState> emit) {
    emit(BarangJadiInitial());
  }

  Future<void> _onSearchFromScan(
    SearchBarangJadiFromScan event,
    Emitter<BarangJadiState> emit,
  ) async {
    emit(BarangJadiLoading());

    final result = await barangJadiRepository.searchBarangJadi(
      namaBarang: event.prodCode,
    );

    result.fold((l) => emit(BarangJadiError(l.message!)), (data) {
      if (data.isNotEmpty) {
        // ⬅️ AUTO SELECT FIRST RESULT
        emit(BarangJadiLoaded(data, data.first));
      } else {
        emit(const BarangJadiLoaded([], null));
      }
    });
  }
}
