part of 'stock_opname_dtl_bloc.dart';

abstract class StockOpnameDtlState extends Equatable {
  const StockOpnameDtlState();

  @override
  List<Object?> get props => [];
}

class StockOpnameDtlInitial extends StockOpnameDtlState {}

class StockOpnameDtlLoading extends StockOpnameDtlState {}

class StockOpnameDtlLoaded extends StockOpnameDtlState {
  final List<StockOpnameDtl> data;

  const StockOpnameDtlLoaded(this.data);

  @override
  List<Object?> get props => [data];
}

class StockOpnameDtlError extends StockOpnameDtlState {
  final String message;

  const StockOpnameDtlError(this.message);

  @override
  List<Object?> get props => [message];
}
