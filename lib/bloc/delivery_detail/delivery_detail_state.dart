part of 'delivery_detail_bloc.dart';

sealed class DeliveryDetailState extends Equatable {
  const DeliveryDetailState();

  @override
  List<Object> get props => [];
}

final class DeliveryDetailInitial extends DeliveryDetailState {}

class DeliveryDetailLoading extends DeliveryDetailState {}

class DeliveryDetailSuccess extends DeliveryDetailState {
  final List<DeliveryDetail> deliveryDetail;
  late final Map<String, List<DeliveryDetail>> groupedItems;
  late final bool isConfirmed;

  DeliveryDetailSuccess(this.deliveryDetail) {
    bool confirm = true;
    Map<String, List<DeliveryDetail>> group = {};

    for (int i = 0; i < deliveryDetail.length; i++) {
      if (deliveryDetail[i].endLoad == "1900-01-01 00:00:00.000") {
        confirm = false;
      }
      final e = deliveryDetail[i];

      group.putIfAbsent(e.orderID, () => []);
      group[e.orderID]!.add(e);
    }

    groupedItems = group;
    isConfirmed = confirm;
  }

  @override
  List<Object> get props => [deliveryDetail];
}

class DeliveryDetailFailure extends DeliveryDetailState {
  final Exception exception;

  const DeliveryDetailFailure(this.exception);

  @override
  List<Object> get props => [exception];
}
