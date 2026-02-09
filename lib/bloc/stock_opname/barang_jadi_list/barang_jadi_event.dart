part of 'barang_jadi_bloc.dart';

abstract class BarangJadiEvent {
  const BarangJadiEvent();
}

class SearchBarangJadi extends BarangJadiEvent {
  final String keyword;

  const SearchBarangJadi(this.keyword);
}

class SelectBarangJadi extends BarangJadiEvent {
  final BarangJadi item;
  SelectBarangJadi(this.item);
}

class ClearBarangJadi extends BarangJadiEvent {}

class SearchBarangJadiFromScan extends BarangJadiEvent {
  final String prodCode;
  const SearchBarangJadiFromScan(this.prodCode);
}
