part of 'approval_sr_bloc.dart';

sealed class ApprovalSrState extends Equatable {
  const ApprovalSrState();
  
  @override
  List<Object> get props => [];
}

final class ApprovalSrInitial extends ApprovalSrState {}
