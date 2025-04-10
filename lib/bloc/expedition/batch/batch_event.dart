part of 'batch_bloc.dart';

sealed class BatchEvent extends Equatable {
  const BatchEvent();

  @override
  List<Object> get props => [];
}

class LoadBatch extends BatchEvent {
  final String deliveryId;

  const LoadBatch({required this.deliveryId});

  @override
  List<Object> get props => [deliveryId];
}
