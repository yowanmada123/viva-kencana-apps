import 'package:bloc/bloc.dart';

import '../../../data/repository/incoming_inspection_repository.dart';
import 'inspection_submit_event.dart';
import 'inspection_submit_state.dart';

class InspectionSubmitBloc
    extends Bloc<InspectionSubmitEvent, InspectionSubmitState> {
  final IncomingInspectionRepository incomingInspectionRepository;

  InspectionSubmitBloc({required this.incomingInspectionRepository})
    : super(InspectionSubmitInitial()) {
    on<SubmitInspection>(_onSubmit);
    on<ResetInspectionSubmit>(
      (event, emit) => emit(InspectionSubmitInitial()),
    );
  }

  Future<void> _onSubmit(
    SubmitInspection event,
    Emitter<InspectionSubmitState> emit,
  ) async {
    emit(InspectionSubmitLoading());

    final result = await incomingInspectionRepository.submitInspection(
      form: event.form,
    );

    result.fold(
      (l) => emit(
        InspectionSubmitError(
          message: l.message ?? 'Gagal menyimpan data inspeksi',
        ),
      ),
      (r) => emit(InspectionSubmitSuccess(r)),
    );
  }
}
