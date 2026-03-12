part of 'mill_selector_bloc.dart';

sealed class MillSelectorEvent extends Equatable {
  const MillSelectorEvent();

  @override
  List<Object?> get props => [];
}

class MillSelectorLoadEvent extends MillSelectorEvent {}
