part of 'cancel_load_bloc.dart';

sealed class CancelLoadEvent extends Equatable {
  const CancelLoadEvent();

  @override
  List<Object> get props => [];
}

final class CancelLoadSubmitted extends CancelLoadEvent {
  final String batchID;
  final String delivID;
  final String companyID;
  final String millID;
  final String whID;
  final String itemNum;

  const CancelLoadSubmitted({
    required this.batchID,
    required this.delivID,
    required this.companyID,
    required this.millID,
    required this.whID,
    required this.itemNum,
  });

  @override
  List<Object> get props => [
    batchID,
    delivID,
    companyID,
    millID,
    whID,
    itemNum,
  ];
}
