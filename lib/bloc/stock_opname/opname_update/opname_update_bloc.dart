import 'package:bloc/bloc.dart';
import '../../../data/repository/stock_opname/opname_repository.dart';

part 'opname_update_event.dart';
part 'opname_update_state.dart';

class OpnameBloc extends Bloc<OpnameEvent, OpnameState> {
  final OpnameRepository opnameRepository;

  OpnameBloc({required this.opnameRepository}) : super(OpnameInitial()) {
    on<SubmitOpnameUpdate>(_onSubmit);
  }

  Future<void> _onSubmit(
    SubmitOpnameUpdate event,
    Emitter<OpnameState> emit,
  ) async {
    emit(OpnameLoading());

    final result = await opnameRepository.submitOpnameUpdate(
      payload: {
        'mill_id': event.millId,
        'wh_id': event.whId,
        'bin_id': event.binId,
        'tr_id': event.trId,
        'prod_code': event.prodCode,
        'add_id': event.addId,
        'tor_id': event.torId,
        'panjang': event.panjang,
        'batch_id': event.batchId,
        'remark': event.remark,
        'qty_opname': event.qtyOpname,
        'user_id': event.userId2,
      },
    );

    result.fold(
      (l) => emit(OpnameError(l.message!)),
      (r) => emit(
        OpnameSuccess(
          (r['qty_awal'] as num).toDouble(),
          (r['qty_opname'] as num).toDouble(),
        ),
      ),
    );
  }
}
