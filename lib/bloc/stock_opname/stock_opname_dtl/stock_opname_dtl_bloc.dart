import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:vivakencanaapp/data/repository/stock_opname/opname_stock_dtl_repository.dart';

import '../../../models/stock_opname/stock_opname_dtl.dart';

part 'stock_opname_dtl_event.dart';
part 'stock_opname_dtl_state.dart';

class StockOpnameDtlBloc
    extends Bloc<StockOpnameDtlEvent, StockOpnameDtlState> {
  final OpnameStockDtlRepository opnameStockDtlRepository;

  StockOpnameDtlBloc({required this.opnameStockDtlRepository})
    : super(StockOpnameDtlInitial()) {
    on<LoadStockOpnameDtl>(_onLoad);
  }

  Future<void> _onLoad(
    LoadStockOpnameDtl event,
    Emitter<StockOpnameDtlState> emit,
  ) async {
    emit(StockOpnameDtlLoading());

    final result = await opnameStockDtlRepository.getOpnameDetail(
      trId: event.trId,
      millId: event.millId,
      whId: event.whId,
      binId: event.binId,
      batchId: event.batchId,
      search: event.search,
    );

    result.fold(
      (l) => emit(StockOpnameDtlError(l.message!)),
      (r) => emit(StockOpnameDtlLoaded(r)),
    );
  }
}
