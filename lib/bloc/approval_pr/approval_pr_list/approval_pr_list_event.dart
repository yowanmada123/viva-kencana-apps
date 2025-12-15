part of 'approval_pr_list_bloc.dart';

sealed class ApprovalPrListEvent extends Equatable {
  const ApprovalPrListEvent();

  @override
  List<Object> get props => [];
}

class GetApprovalPRListEvent extends ApprovalPrListEvent {
  final String entityId;
  const GetApprovalPRListEvent({required this.entityId});
}

class RemoveListByPrId extends ApprovalPrListEvent {
  final String prId;
  const RemoveListByPrId({required this.prId});
}
