import '../../../models/incoming_inspection/vendor.dart';

abstract class VendorState {}

class VendorInitial extends VendorState {}

class VendorLoading extends VendorState {}

class VendorLoaded extends VendorState {
  final List<Vendor> data;

  VendorLoaded(this.data);
}

class VendorError extends VendorState {
  final String message;

  VendorError({required this.message});
}
