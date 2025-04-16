import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:vivakencanaapp/data/repository/fdpi_repository.dart';
import 'package:vivakencanaapp/models/fdpi/residence.dart';

part 'residence_event.dart';
part 'residence_state.dart';

class ResidenceBloc extends Bloc<ResidenceEvent, ResidenceState> {
  final FdpiRepository fdpiRepository;
  
  ResidenceBloc({required this.fdpiRepository}) : super(const ResidenceState()) {
    on<LoadResidence>(_loadResidence);
  }

  void _loadResidence(
    LoadResidence event, 
    Emitter<ResidenceState> emit
  ) async {
      emit(state.copyWith(status: ResidenceStatus.loading));
      print("Masuk sini boys ${state.status}");

      final result = await fdpiRepository.getResidences(
        event.idProvince,
        event.idCity,
        event.status,
      );
      print("Result: $result");


      result.fold(
        (error) => emit(state.copyWith(status: ResidenceStatus.failure, errorMessage: error.message)), 
        (data) => emit(state.copyWith(status: ResidenceStatus.success, residences: data))
      );
      print("Masuk sini boys ${state.status}");
  }
}
