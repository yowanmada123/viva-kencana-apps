import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:vivakencanaapp/data/repository/stock_opname/mill_repository.dart';

import '../../../models/mill.dart';
part 'mill_event.dart';
part 'mill_state.dart';

class MillBloc extends Bloc<MillEvent, MillState> {
  final MillRepository millRepository;

  MillBloc({required this.millRepository}) : super(MillInitial()) {
    on<MillLoadEvent>(_loadMill);
  }

  void _loadMill(MillLoadEvent event, Emitter<MillState> emit) async {
    emit(MillLoading());

    final res = await millRepository.getMill();

    res.fold(
      (exception) {
        emit(MillFailure(exception));
      },
      (mill) {
        emit(MillSuccess(mill));
      },
    );
  }
}
