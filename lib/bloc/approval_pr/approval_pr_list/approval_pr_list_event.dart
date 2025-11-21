part of 'approval_pr_list_bloc.dart';

sealed class ApprovalPrListEvent extends Equatable {
  const ApprovalPrListEvent();

  @override
  List<Object> get props => [];
}

class GetApprovalPRListEvent extends ApprovalPrListEvent {
  final String departmentId;
  final String approveStatus;
  final String startDate;
  final String endDate;  

    const GetApprovalPRListEvent({
    required this.departmentId,
    required this.approveStatus,
    required this.startDate,
    required this.endDate,
  });
}

class RemoveListIndex extends ApprovalPrListEvent {
  final int index;

  const RemoveListIndex({required this.index});
}
