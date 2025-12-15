part of 'approve_pr_bloc.dart';

sealed class ApprovePrEvent extends Equatable {
  const ApprovePrEvent();

  @override
  List<Object> get props => [];
}

final class ApprovePrLoadEvent extends ApprovePrEvent {
  final String prId;
  final String status;
  final String entityId;

  const ApprovePrLoadEvent({
    required this.entityId,
    required this.prId,
    required this.status,
  });
}
