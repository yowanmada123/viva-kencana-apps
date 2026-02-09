part of 'opname_update_bloc.dart';

abstract class OpnameEvent {}

class SubmitOpnameUpdate extends OpnameEvent {
  final String millId;
  final String whId;
  final String binId;
  final String trId;
  final String prodCode;
  final String addId;
  final String torId;
  final String panjang;
  final String batchId;
  final String remark;
  final String qtyOpname;
  final String userId2;

  SubmitOpnameUpdate({
    required this.millId,
    required this.whId,
    required this.binId,
    required this.trId,
    required this.prodCode,
    required this.addId,
    required this.torId,
    required this.panjang,
    required this.batchId,
    required this.remark,
    required this.qtyOpname,
    required this.userId2,
  });
}
