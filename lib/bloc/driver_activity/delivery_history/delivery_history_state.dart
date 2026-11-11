part of 'delivery_history_bloc.dart';

abstract class DeliveryHistoryState extends Equatable {
  const DeliveryHistoryState();

  @override
  List<Object?> get props => [];
}

class DeliveryHistoryInitial extends DeliveryHistoryState {}

class DeliveryHistoryLoading extends DeliveryHistoryState {}

class DeliveryHistorySuccess extends DeliveryHistoryState {
  final List<DriverDelivery> deliveries;

  const DeliveryHistorySuccess({
    required this.deliveries,
  });

  @override
  List<Object?> get props => [deliveries];
}

class DeliveryHistoryFailure extends DeliveryHistoryState {
  final String message;
  final CustomException? error;

  const DeliveryHistoryFailure({
    required this.message,
    this.error,
  });

  @override
  List<Object?> get props => [message, error];
}

