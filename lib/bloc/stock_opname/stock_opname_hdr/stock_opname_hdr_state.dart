import 'package:vivakencanaapp/models/stock_opname/stock_opname_hdr.dart';

abstract class OpnameStockHdrState {}

class OpnameStockHdrInitial extends OpnameStockHdrState {}

class OpnameStockHdrLoading extends OpnameStockHdrState {}

class OpnameStockHdrLoaded extends OpnameStockHdrState {
  final List<StockOpnameHdr> data;

  OpnameStockHdrLoaded(this.data);
}

class OpnameStockHdrError extends OpnameStockHdrState {
  final String message;

  OpnameStockHdrError({required this.message});
}
