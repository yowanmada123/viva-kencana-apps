part of 'approve_pr_bloc.dart';

sealed class ApprovePrState extends Equatable {
  const ApprovePrState();

  @override
  List<Object> get props => [];
}

final class ApprovePrInitial extends ApprovePrState {}

final class ApprovePrLoading extends ApprovePrState {}

final class ApprovePrFailure extends ApprovePrState {
  final String message;
  final Exception exception;
  const ApprovePrFailure({required this.message, required this.exception});
}

final class ApprovePrSuccess extends ApprovePrState {
  final String message;
  final String prId;
  const ApprovePrSuccess({required this.message, required this.prId});
}
