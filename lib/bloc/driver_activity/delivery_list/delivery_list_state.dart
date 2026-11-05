part of 'delivery_list_bloc.dart';

abstract class DeliveryListState extends Equatable {
  const DeliveryListState();

  @override
  List<Object?> get props => [];
}

class DeliveryListInitial extends DeliveryListState {}

class DeliveryListLoading extends DeliveryListState {}

class DeliveryListSuccess extends DeliveryListState {
  final List<DriverDelivery> allDeliveries;
  final List<DriverDelivery> filteredDeliveries;
  final String searchQuery;

  const DeliveryListSuccess({
    required this.allDeliveries,
    required this.filteredDeliveries,
    this.searchQuery = '',
  });

  @override
  List<Object?> get props => [allDeliveries, filteredDeliveries, searchQuery];
}

class DeliveryListFailure extends DeliveryListState {
  final String message;
  final CustomException? error;

  const DeliveryListFailure({
    required this.message,
    this.error,
  });

  @override
  List<Object?> get props => [message, error];
}

