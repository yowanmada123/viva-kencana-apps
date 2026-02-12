part of 'wh_bin_bloc.dart';

abstract class WHBinEvent {}

class LoadWHBin extends WHBinEvent {
  final String millId;
  final String whId;

  LoadWHBin({required this.millId, required this.whId});
}
