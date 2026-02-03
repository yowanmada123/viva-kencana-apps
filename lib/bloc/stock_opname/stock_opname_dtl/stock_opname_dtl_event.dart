part of 'stock_opname_dtl_bloc.dart';

abstract class StockOpnameDtlEvent extends Equatable {
  const StockOpnameDtlEvent();

  @override
  List<Object?> get props => [];
}

class LoadStockOpnameDtl extends StockOpnameDtlEvent {
  final String trId;
  final String millId;
  final String whId;
  final String? binId;
  final String? batchId;
  final String? search;

  const LoadStockOpnameDtl({
    required this.trId,
    required this.millId,
    required this.whId,
    this.binId,
    this.batchId,
    this.search,
  });

  @override
  List<Object?> get props => [trId, millId, whId, binId, batchId, search];
}
