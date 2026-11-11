part of 'delivery_history_bloc.dart';

abstract class DeliveryHistoryEvent extends Equatable {
  const DeliveryHistoryEvent();

  @override
  List<Object?> get props => [];
}

class GetDeliveryHistoryEvent extends DeliveryHistoryEvent {
  const GetDeliveryHistoryEvent();
}

class RefreshDeliveryHistoryEvent extends DeliveryHistoryEvent {
  const RefreshDeliveryHistoryEvent();
}

