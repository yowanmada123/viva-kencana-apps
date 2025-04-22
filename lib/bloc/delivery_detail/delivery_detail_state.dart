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

  const DeliveryDetailSuccess(this.deliveryDetail);

  @override
  List<Object> get props => [deliveryDetail];
}

class DeliveryDetailFailure extends DeliveryDetailState {
  final Exception exception;

  const DeliveryDetailFailure(this.exception);

  @override
  List<Object> get props => [exception];
}
