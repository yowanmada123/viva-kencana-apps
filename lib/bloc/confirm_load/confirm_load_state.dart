part of 'confirm_load_bloc.dart';

sealed class ConfirmLoadState extends Equatable {
  const ConfirmLoadState();

  @override
  List<Object> get props => [];
}

final class ConfirmLoadInitial extends ConfirmLoadState {}

final class ConfirmLoadLoading extends ConfirmLoadState {}

final class ConfirmLoadSuccess extends ConfirmLoadState {
  const ConfirmLoadSuccess();
}

final class ConfirmLoadError extends ConfirmLoadState {
  final String? message;

  const ConfirmLoadError({required this.message});
}
