part of 'stock_opname_dtl_bloc.dart';

abstract class StockOpnameDtlState extends Equatable {
  const StockOpnameDtlState();

  @override
  List<Object?> get props => [];
}

class StockOpnameDtlInitial extends StockOpnameDtlState {}

class StockOpnameDtlLoading extends StockOpnameDtlState {}

class StockOpnameDtlLoaded extends StockOpnameDtlState {
  final List<StockOpnameDtl> allData;
  final List<StockOpnameDtl> filteredData;

  final Map<String, Set<String>> binBatchMap;

  const StockOpnameDtlLoaded({
    required this.allData,
    required this.filteredData,
    required this.binBatchMap,
  });

  @override
  List<Object?> get props => [allData, filteredData, binBatchMap];
}

class StockOpnameDtlError extends StockOpnameDtlState {
  final String message;

  const StockOpnameDtlError(this.message);

  @override
  List<Object?> get props => [message];
}
