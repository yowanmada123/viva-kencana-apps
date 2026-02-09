part of 'opname_update_bloc.dart';

abstract class OpnameState {}

class OpnameInitial extends OpnameState {}

class OpnameLoading extends OpnameState {}

class OpnameSuccess extends OpnameState {
  final double qtyAwal;
  final double qtyOpname;
  OpnameSuccess(this.qtyAwal, this.qtyOpname);
}

class OpnameError extends OpnameState {
  final String message;
  OpnameError(this.message);
}
