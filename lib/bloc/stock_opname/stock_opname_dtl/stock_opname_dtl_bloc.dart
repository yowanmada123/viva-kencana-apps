import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:vivakencanaapp/data/repository/stock_opname/opname_stock_dtl_repository.dart';

import '../../../models/stock_opname/stock_opname_dtl.dart';

part 'stock_opname_dtl_event.dart';
part 'stock_opname_dtl_state.dart';

class StockOpnameDtlBloc
    extends Bloc<StockOpnameDtlEvent, StockOpnameDtlState> {
  final OpnameStockDtlRepository opnamestockdtlrepository;

  StockOpnameDtlBloc({required this.opnamestockdtlrepository})
    : super(StockOpnameDtlInitial()) {
    on<ClearStockOpnameDtl>(_onClear); // 🔥 WAJIB
    on<LoadStockOpnameDtl>(_onLoad);
    on<SearchStockOpnameDtl>(_onSearch);
    on<FilterBinBatchStockOpnameDtl>(_onFilterBinBatch);
  }

  /// ================= CLEAR STATE (FORCE REBUILD)
  void _onClear(ClearStockOpnameDtl event, Emitter<StockOpnameDtlState> emit) {
    emit(StockOpnameDtlLoading());
  }

  /// ================= LOAD BACKEND
  Future<void> _onLoad(
    LoadStockOpnameDtl event,
    Emitter<StockOpnameDtlState> emit,
  ) async {
    emit(StockOpnameDtlLoading());

    final result = await opnamestockdtlrepository.getOpnameDetail(
      trId: event.trId,
      millId: event.millId,
      whId: event.whId,
    );

    result.fold((l) => emit(StockOpnameDtlError(l.message!)), (r) {
      final binBatchMap = _buildBinBatchMap(r);

      emit(
        StockOpnameDtlLoaded(
          allData: r,
          filteredData: r,
          binBatchMap: binBatchMap,
        ),
      );
    });
  }

  /// ================= SEARCH LOCAL
  void _onSearch(
    SearchStockOpnameDtl event,
    Emitter<StockOpnameDtlState> emit,
  ) {
    final state = this.state;
    if (state is! StockOpnameDtlLoaded) return;

    final keyword = event.keyword.toLowerCase();

    final filtered =
        keyword.isEmpty
            ? state.allData
            : state.allData
                .where(
                  (e) =>
                      e.namaBarang.toLowerCase().contains(keyword) ||
                      e.prodCode.toLowerCase().contains(keyword),
                )
                .toList();

    emit(
      StockOpnameDtlLoaded(
        allData: state.allData,
        filteredData: filtered,
        binBatchMap: state.binBatchMap,
      ),
    );
  }

  /// ================= FILTER BIN
  void _onFilterBinBatch(
    FilterBinBatchStockOpnameDtl event,
    Emitter<StockOpnameDtlState> emit,
  ) {
    final state = this.state;
    if (state is! StockOpnameDtlLoaded) return;

    final filtered =
        state.allData.where((e) {
          if (event.binId != null && e.binId != event.binId) return false;
          return true;
        }).toList();

    emit(
      StockOpnameDtlLoaded(
        allData: state.allData,
        filteredData: filtered,
        binBatchMap: state.binBatchMap,
      ),
    );
  }

  /// ================= BUILD BIN → BATCH MAP
  Map<String, Set<String>> _buildBinBatchMap(List<StockOpnameDtl> data) {
    final map = <String, Set<String>>{};

    for (final e in data) {
      if (e.binId.isEmpty) continue;

      map.putIfAbsent(e.binId, () => <String>{});

      if (e.batchId.isNotEmpty) {
        map[e.binId]!.add(e.batchId);
      }
    }

    return map;
  }
}
