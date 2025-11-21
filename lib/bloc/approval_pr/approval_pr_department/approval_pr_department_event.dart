part of 'approval_pr_department_bloc.dart';

sealed class ApprovalPrDepartmentEvent extends Equatable {
  const ApprovalPrDepartmentEvent();

  @override
  List<Object> get props => [];
}

class GetApprovalPrDepartmentEvent extends ApprovalPrDepartmentEvent {}

class RemoveListIndex extends ApprovalPrDepartmentEvent {
  final int index;

  const RemoveListIndex({required this.index});
}
