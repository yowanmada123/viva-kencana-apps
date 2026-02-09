part of 'prod_master_bloc.dart';

abstract class ProdMasterState extends Equatable {
  const ProdMasterState();
  @override
  List<Object?> get props => [];
}

class ProdMasterInitial extends ProdMasterState {}

class ProdMasterLoading extends ProdMasterState {}

class ProdMasterLoaded extends ProdMasterState {
  final List<ProdAdd> prodAdd;
  final List<ProdTor> prodTor;

  const ProdMasterLoaded({required this.prodAdd, required this.prodTor});

  @override
  List<Object?> get props => [prodAdd, prodTor];
}

class ProdMasterError extends ProdMasterState {
  final String message;
  const ProdMasterError(this.message);

  @override
  List<Object?> get props => [message];
}
