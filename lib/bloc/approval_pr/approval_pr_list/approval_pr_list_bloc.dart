import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../data/repository/approval_pr_repository.dart';
import '../../../models/approval_pr/approval_pr_fdpi.dart';

part 'approval_pr_list_event.dart';
part 'approval_pr_list_state.dart';

class ApprovalPrListBloc
    extends Bloc<ApprovalPrListEvent, ApprovalPrListState> {
  final ApprovalPRRepository approvalPRRepository;

  ApprovalPrListBloc({required this.approvalPRRepository})
    : super(ApprovalPrListInitial()) {
    on<GetApprovalPRListEvent>(_onGetListApprovalPR);
    on<RemoveListByPrId>(_onRemoveListByPrId);
  }

  void _onGetListApprovalPR(
    GetApprovalPRListEvent event,
    Emitter<ApprovalPrListState> emit,
  ) async {
    emit(ApprovalPrListLoadingState());
    final result = await approvalPRRepository.getPRList(event.entityId);
    result.fold(
      (failure) => emit(
        ApprovalPrListFailureState(message: failure.message!, error: failure),
      ),
      (data) => emit(ApprovalPrListSuccessState(data: data)),
    );
  }

  void _onRemoveListByPrId(
    RemoveListByPrId event,
    Emitter<ApprovalPrListState> emit,
  ) {
    final currentState = state;

    if (currentState is ApprovalPrListSuccessState) {
      emit(ApprovalPrListLoadingState());

      final updatedList =
          currentState.data.where((item) => item.prId != event.prId).toList();

      emit(ApprovalPrListSuccessState(data: updatedList));
    }
  }
}
