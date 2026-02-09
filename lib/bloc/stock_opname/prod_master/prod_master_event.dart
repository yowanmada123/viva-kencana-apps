part of 'prod_master_bloc.dart';

abstract class ProdMasterEvent extends Equatable {
  const ProdMasterEvent();
  @override
  List<Object?> get props => [];
}

class LoadProdMaster extends ProdMasterEvent {}
