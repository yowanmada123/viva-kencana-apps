import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:vivakencanaapp/data/repository/stock_opname/mill_selector_repository.dart';
import 'package:vivakencanaapp/models/mill.dart';

part 'mill_selector_event.dart';
part 'mill_selector_state.dart';

class MillSelectorBloc extends Bloc<MillSelectorEvent, MillSelectorState> {
  final MillSelectorRepository repository;

  MillSelectorBloc(this.repository) : super(MillSelectorInitial()) {
    on<MillSelectorLoadEvent>(_loadMill);
  }

  Future<void> _loadMill(
    MillSelectorLoadEvent event,
    Emitter<MillSelectorState> emit,
  ) async {
    emit(MillSelectorLoading());

    try {
      final mills = await repository.getAvailableMill();

      emit(MillSelectorSuccess(mills));
    } catch (e) {
      emit(MillSelectorFailure(e.toString()));
    }
  }
}
