import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:vivakencanaapp/models/stock_opname/prod_add.dart';
import 'package:vivakencanaapp/models/stock_opname/prod_tor.dart';

import '../../../data/repository/stock_opname/prod_master_repository.dart';

part 'prod_master_event.dart';
part 'prod_master_state.dart';

class ProdMasterBloc extends Bloc<ProdMasterEvent, ProdMasterState> {
  final ProdMasterRepository prodMasterRepository;

  ProdMasterBloc({required this.prodMasterRepository})
    : super(ProdMasterInitial()) {
    on<LoadProdMaster>(_onLoadProdMaster);
  }

  Future<void> _onLoadProdMaster(
    LoadProdMaster event,
    Emitter<ProdMasterState> emit,
  ) async {
    emit(ProdMasterLoading());

    try {
      final addResult = await prodMasterRepository.getProdAdd();
      final torResult = await prodMasterRepository.getProdTor();

      emit(
        ProdMasterLoaded(
          prodAdd: addResult.getOrElse(() => []),
          prodTor: torResult.getOrElse(() => []),
        ),
      );
    } catch (e) {
      // JANGAN render error ke UI form
      emit(const ProdMasterLoaded(prodAdd: [], prodTor: []));
    }
  }
}
