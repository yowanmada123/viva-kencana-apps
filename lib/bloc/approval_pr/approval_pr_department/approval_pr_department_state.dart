part of 'approval_pr_department_bloc.dart';

sealed class ApprovalPrDepartmentState extends Equatable {
  const ApprovalPrDepartmentState();

  @override
  List<Object> get props => [];
}

final class ApprovalPrDepartmentInitial extends ApprovalPrDepartmentState {}

final class ApprovalPrDepartmentLoadingState
    extends ApprovalPrDepartmentState {}

final class ApprovalPrDepartmentFailureState extends ApprovalPrDepartmentState {
  final String message;
  final Exception error;
  const ApprovalPrDepartmentFailureState({
    required this.message,
    required this.error,
  });
}

final class ApprovalPrDepartmentSuccessState extends ApprovalPrDepartmentState {
  final List<Department> data;
  const ApprovalPrDepartmentSuccessState({required this.data});
}
