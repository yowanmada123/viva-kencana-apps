part of 'stock_opname_dtl_bloc.dart';

abstract class StockOpnameDtlEvent extends Equatable {
  const StockOpnameDtlEvent();

  @override
  List<Object?> get props => [];
}

/// ================= LOAD (BACKEND)
class LoadStockOpnameDtl extends StockOpnameDtlEvent {
  final String trId;
  final String millId;
  final String whId;
  final String? binId;
  final String? batchId;

  const LoadStockOpnameDtl({
    required this.trId,
    required this.millId,
    required this.whId,
    this.binId,
    this.batchId,
  });

  @override
  List<Object?> get props => [trId, millId, whId, binId, batchId];
}

/// ================= SEARCH (LOCAL)
class SearchStockOpnameDtl extends StockOpnameDtlEvent {
  final String keyword;

  const SearchStockOpnameDtl(this.keyword);

  @override
  List<Object?> get props => [keyword];
}

class FilterBinBatchStockOpnameDtl extends StockOpnameDtlEvent {
  final String? binId;
  final String? batchId;

  const FilterBinBatchStockOpnameDtl({this.binId, this.batchId});

  @override
  List<Object?> get props => [binId, batchId];
}
