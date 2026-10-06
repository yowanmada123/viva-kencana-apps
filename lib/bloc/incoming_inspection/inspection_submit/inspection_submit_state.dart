abstract class InspectionSubmitState {}

class InspectionSubmitInitial extends InspectionSubmitState {}

class InspectionSubmitLoading extends InspectionSubmitState {}

class InspectionSubmitSuccess extends InspectionSubmitState {
  /// trx_id hasil generate backend.
  final String trxId;

  InspectionSubmitSuccess(this.trxId);
}

class InspectionSubmitError extends InspectionSubmitState {
  final String message;

  InspectionSubmitError({required this.message});
}
