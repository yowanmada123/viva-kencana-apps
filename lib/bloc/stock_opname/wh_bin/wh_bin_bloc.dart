import 'package:bloc/bloc.dart';
import 'package:vivakencanaapp/data/repository/stock_opname/wh_bin_repository.dart';
import 'package:vivakencanaapp/models/stock_opname/warehouse_bin.dart';

part 'wh_bin_event.dart';
part 'wh_bin_state.dart';

class WHBinBloc extends Bloc<WHBinEvent, WHBinState> {
  final WHBinRepository whBinRepository;

  WHBinBloc({required this.whBinRepository}) : super(WHBinInitial()) {
    on<LoadWHBin>(_onLoadWHBin);
  }

  Future<void> _onLoadWHBin(LoadWHBin event, Emitter<WHBinState> emit) async {
    emit(WHBinLoading());
    try {
      final data = await whBinRepository.getBins(
        millId: event.millId,
        whId: event.whId,
      );
      emit(WHBinLoaded(data));
    } catch (e) {
      emit(WHBinError(e.toString()));
    }
  }
}
