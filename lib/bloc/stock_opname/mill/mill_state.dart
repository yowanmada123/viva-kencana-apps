part of 'mill_bloc.dart';

sealed class MillState extends Equatable {
  const MillState();

  @override
  List<Object> get props => [];
}

final class MillInitial extends MillState {}

class MillLoading extends MillState {}

class MillSuccess extends MillState {
  final List<Mill> mills;

  const MillSuccess(this.mills);

  @override
  List<Object> get props => [mills];
}

class MillFailure extends MillState {
  final Exception exception;

  const MillFailure(this.exception);

  @override
  List<Object> get props => [exception];
}
