part of 'barang_jadi_bloc.dart';

abstract class BarangJadiState {
  const BarangJadiState();
}

class BarangJadiInitial extends BarangJadiState {}

class BarangJadiLoading extends BarangJadiState {}

class BarangJadiLoaded extends BarangJadiState {
  final List<BarangJadi> data;
  final BarangJadi? selected;

  const BarangJadiLoaded(this.data, this.selected);
}

class BarangJadiError extends BarangJadiState {
  final String message;

  const BarangJadiError(this.message);
}
