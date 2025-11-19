import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'approval_sr_event.dart';
part 'approval_sr_state.dart';

class ApprovalSrBloc extends Bloc<ApprovalSrEvent, ApprovalSrState> {
  ApprovalSrBloc() : super(ApprovalSrInitial()) {
    on<ApprovalSrEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
