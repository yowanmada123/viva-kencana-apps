import 'package:bloc/bloc.dart';
import 'package:vivakencanaapp/bloc/stock_opname/stock_opname_hdr/stock_opname_hdr_event.dart';
import 'package:vivakencanaapp/bloc/stock_opname/stock_opname_hdr/stock_opname_hdr_state.dart';
import 'package:vivakencanaapp/data/repository/stock_opname/opname_stock_hdr_repository.dart';

class OpnameStockHdrBloc
    extends Bloc<OpnameStockHdrEvent, OpnameStockHdrState> {
  final OpnameStockHdrRepository opnameStockHdrRepository;

  OpnameStockHdrBloc({required this.opnameStockHdrRepository})
    : super(OpnameStockHdrInitial()) {
    on<LoadOpnameStockHdr>(_onLoad);
  }

  Future<void> _onLoad(
    LoadOpnameStockHdr event,
    Emitter<OpnameStockHdrState> emit,
  ) async {
    emit(OpnameStockHdrLoading());

    final result = await opnameStockHdrRepository.getOpenOpnameHdr(
      millId: event.millId,
    );

    result.fold(
      (l) => emit(OpnameStockHdrError(message: l.message!)),
      (r) => emit(OpnameStockHdrLoaded(r)),
    );
  }
}
