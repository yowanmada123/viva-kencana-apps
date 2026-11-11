part of 'rw_receive_bloc.dart';

abstract class RwReceiveEvent {}

class RwScanned extends RwReceiveEvent {
  final String code;

  RwScanned(this.code);
}

class RwConfirm extends RwReceiveEvent {
  final RwScanResult scan;

  RwConfirm(this.scan);
}

class RwDismiss extends RwReceiveEvent {}
