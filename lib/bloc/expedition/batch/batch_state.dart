part of 'batch_bloc.dart';

sealed class BatchState extends Equatable {
  const BatchState();

  @override
  List<Object> get props => [];
}

final class BatchInitial extends BatchState {}

class BatchLoading extends BatchState {}

class BatchSuccess extends BatchState {
  final Batch batch;

  const BatchSuccess(this.batch);

  @override
  List<Object> get props => [batch];
}

class BatchFailure extends BatchState {
  final String message;

  const BatchFailure(this.message);

  @override
  List<Object> get props => [message];
}
