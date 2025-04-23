part of 'cancel_load_bloc.dart';

sealed class CancelLoadEvent extends Equatable {
  const CancelLoadEvent();

  @override
  List<Object> get props => [];
}

final class CancelLoadSubmitted extends CancelLoadEvent {
  final String batchID;
  final String companyID;
  final String millID;
  final String whID;

  const CancelLoadSubmitted({
    required this.batchID,
    required this.companyID,
    required this.millID,
    required this.whID,
  });

  @override
  List<Object> get props => [batchID, companyID, millID, whID];
}
