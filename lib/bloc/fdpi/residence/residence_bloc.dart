import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../data/repository/fdpi_repository.dart';
import '../../../models/fdpi/residence.dart';

part 'residence_event.dart';
part 'residence_state.dart';

class ResidenceBloc extends Bloc<ResidenceEvent, ResidenceState> {
  final FdpiRepository fdpiRepository;

  ResidenceBloc({required this.fdpiRepository})
    : super(const ResidenceState()) {
    on<LoadResidence>(_loadResidence);
  }

  void _loadResidence(LoadResidence event, Emitter<ResidenceState> emit) async {
    emit(ResidenceLoading());

    final result = await fdpiRepository.getResidences(
      event.idProvince,
      event.idCity,
      event.status,
    );

    result.fold(
      (error) => emit(
        ResidenceLoadFailure(errorMessage: error.message!, exception: error),
      ),
      (data) => emit(ResidenceLoadSuccess(residences: data)),
    );
  }
}
