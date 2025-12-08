import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:vivakencanaapp/data/repository/approval_pr_repository.dart';
import 'package:vivakencanaapp/models/approval_pr/approval_pr_department.dart';

part 'approval_pr_department_event.dart';
part 'approval_pr_department_state.dart';

class ApprovalPrDepartmentBloc
    extends Bloc<ApprovalPrDepartmentEvent, ApprovalPrDepartmentState> {
  final ApprovalPRRepository approvalPRRepository;

  ApprovalPrDepartmentBloc({required this.approvalPRRepository})
    : super(ApprovalPrDepartmentInitial()) {
    on<GetApprovalPrDepartmentEvent>(_onGetListApprovalDepartementPR);
  }

  void _onGetListApprovalDepartementPR(
    GetApprovalPrDepartmentEvent event,
    Emitter<ApprovalPrDepartmentState> emit,
  ) async {
    emit(ApprovalPrDepartmentLoadingState());
    final result = await approvalPRRepository.getPrDepartmentListAndUserData();
    result.fold(
      (failure) => emit(
        ApprovalPrDepartmentFailureState(
          message: failure.message!,
          error: failure,
        ),
      ),
      (data) => emit(ApprovalPrDepartmentSuccessState(data: data)),
    );
  }
}
