part of 'delivery_list_bloc.dart';

abstract class DeliveryListEvent extends Equatable {
  const DeliveryListEvent();

  @override
  List<Object?> get props => [];
}

class GetDeliveryListEvent extends DeliveryListEvent {
  const GetDeliveryListEvent();
}

class RefreshDeliveryListEvent extends DeliveryListEvent {
  const RefreshDeliveryListEvent();
}

class FilterDeliveryListEvent extends DeliveryListEvent {
  final String query;
  const FilterDeliveryListEvent(this.query);

  @override
  List<Object?> get props => [query];
}

