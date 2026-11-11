part of 'rw_selector_bloc.dart';

/// Warehouse terpilih dan shift disimpan di widget, bukan di sini; bloc hanya
/// menyimpan pilihan mill karena daftar warehouse bergantung padanya.
class RwSelectorState {
  final bool optionLoading;
  final bool warehouseLoading;
  final List<Mill> mills;
  final List<RwWarehouse> warehouses;
  final Mill? selectedMill;

  /// Naik setiap kali mill berganti, supaya widget tahu warehouse terpilih
  /// harus dikosongkan.
  final int warehouseVersion;
  final String? error;

  const RwSelectorState({
    this.optionLoading = false,
    this.warehouseLoading = false,
    this.mills = const [],
    this.warehouses = const [],
    this.selectedMill,
    this.warehouseVersion = 0,
    this.error,
  });

  RwSelectorState copyWith({
    bool? optionLoading,
    bool? warehouseLoading,
    List<Mill>? mills,
    List<RwWarehouse>? warehouses,
    Mill? selectedMill,
    bool clearWarehouse = false,
    String? error,
    bool clearError = false,
  }) {
    return RwSelectorState(
      optionLoading: optionLoading ?? this.optionLoading,
      warehouseLoading: warehouseLoading ?? this.warehouseLoading,
      mills: mills ?? this.mills,
      warehouses: warehouses ?? this.warehouses,
      selectedMill: selectedMill ?? this.selectedMill,
      warehouseVersion:
          clearWarehouse ? warehouseVersion + 1 : warehouseVersion,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
