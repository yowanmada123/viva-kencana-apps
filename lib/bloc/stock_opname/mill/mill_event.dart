part of 'mill_bloc.dart';

sealed class MillEvent extends Equatable {
  const MillEvent();

  @override
  List<Object> get props => [];
}

final class MillLoadEvent extends MillEvent {
  const MillLoadEvent();
}
