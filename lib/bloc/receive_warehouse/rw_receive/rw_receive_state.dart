part of 'rw_receive_bloc.dart';

abstract class RwReceiveState {}

class RwReceiveIdle extends RwReceiveState {}

class RwLookupLoading extends RwReceiveState {
  final String trId;

  RwLookupLoading(this.trId);
}

class RwLookupSuccess extends RwReceiveState {
  final RwScanResult scan;

  RwLookupSuccess(this.scan);
}

class RwLookupFailure extends RwReceiveState {
  final String message;

  RwLookupFailure(this.message);
}

class RwSubmitLoading extends RwReceiveState {
  final RwScanResult scan;

  RwSubmitLoading(this.scan);
}

class RwSubmitSuccess extends RwReceiveState {
  final RwScanResult scan;
  final RwReceived received;

  RwSubmitSuccess(this.scan, this.received);
}

class RwSubmitFailure extends RwReceiveState {
  final String message;

  RwSubmitFailure(this.message);
}
