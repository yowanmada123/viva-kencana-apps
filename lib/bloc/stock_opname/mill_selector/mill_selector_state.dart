part of 'mill_selector_bloc.dart';

sealed class MillSelectorState extends Equatable {
  const MillSelectorState();

  @override
  List<Object?> get props => [];
}

class MillSelectorInitial extends MillSelectorState {}

class MillSelectorLoading extends MillSelectorState {}

class MillSelectorSuccess extends MillSelectorState {
  final List<Mill> mills;

  const MillSelectorSuccess(this.mills);

  @override
  List<Object?> get props => [mills];
}

class MillSelectorFailure extends MillSelectorState {
  final String message;

  const MillSelectorFailure(this.message);

  @override
  List<Object?> get props => [message];
}
