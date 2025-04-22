part of 'delivery_detail_bloc.dart';

sealed class DeliveryDetailEvent extends Equatable {
  const DeliveryDetailEvent();

  @override
  List<Object> get props => [];
}

class LoadDeliveryDetail extends DeliveryDetailEvent {
  final String batchID;
  final String companyID;
  final String millID;
  final String whID;

  const LoadDeliveryDetail({
    required this.batchID,
    required this.companyID,
    required this.millID,
    required this.whID,
  });

  @override
  List<Object> get props => [batchID, companyID, millID, whID];
}
