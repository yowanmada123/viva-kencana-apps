part of 'confirm_load_bloc.dart';

sealed class ConfirmLoadEvent extends Equatable {
  const ConfirmLoadEvent();

  @override
  List<Object> get props => [];
}

final class ConfirmLoadSubmitted extends ConfirmLoadEvent {
  final String batchID;
  final String companyID;
  final String millID;
  final String whID;

  const ConfirmLoadSubmitted({
    required this.batchID,
    required this.companyID,
    required this.millID,
    required this.whID,
  });

  @override
  List<Object> get props => [batchID, companyID, millID, whID];
}
