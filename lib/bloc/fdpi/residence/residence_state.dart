part of 'residence_bloc.dart';

enum ResidenceStatus { initial, loading, success, failure }

class ResidenceState extends Equatable {
  final List<Residence> residences;
  final ResidenceStatus status;
  final Residence? selectedResidence;
  final String? errorMessage;

  const ResidenceState({
    this.residences = const [],
    this.status = ResidenceStatus.initial,
    this.selectedResidence = null,
    this.errorMessage = ''
  });

  ResidenceState copyWith({
    ResidenceStatus? status,
    List<Residence>? residences,
    Residence? selectedResidence,
    String? errorMessage
  }) {
    print("On Copy Status${status}, Residences ${residences}, selectedResidence ${selectedResidence}, errorMessage ${errorMessage}");
    return ResidenceState(
      status: status ?? this.status,
      residences: residences ?? this.residences,
      selectedResidence: selectedResidence ?? this.selectedResidence,
      errorMessage: errorMessage ?? this.errorMessage
    );
  }
  
  @override
  List<Object?> get props => [
    residences,
    status,
    selectedResidence,
    errorMessage,
  ];
}


  



