part of 'wh_bin_bloc.dart';

abstract class WHBinState {}

class WHBinInitial extends WHBinState {}

class WHBinLoading extends WHBinState {}

class WHBinLoaded extends WHBinState {
  final List<WHBin> data;
  WHBinLoaded(this.data);
}

class WHBinError extends WHBinState {
  final String message;
  WHBinError(this.message);
}
