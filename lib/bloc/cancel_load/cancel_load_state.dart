part of 'cancel_load_bloc.dart';

sealed class CancelLoadState extends Equatable {
  const CancelLoadState();

  @override
  List<Object> get props => [];
}

final class CancelLoadInitial extends CancelLoadState {}

final class CancelLoadLoading extends CancelLoadState {}

final class CancelLoadSuccess extends CancelLoadState {
  const CancelLoadSuccess();
}

final class CancelLoadError extends CancelLoadState {
  final String? message;

  const CancelLoadError({required this.message});
}
