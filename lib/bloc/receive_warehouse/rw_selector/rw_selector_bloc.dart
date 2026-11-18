import 'package:bloc/bloc.dart';

import '../../../data/repository/receive_warehouse_repository.dart';
import '../../../models/mill.dart';
import '../../../models/receive_warehouse/receive_warehouse.dart';

part 'rw_selector_event.dart';
part 'rw_selector_state.dart';

/// Layar pilih Receive Warehouse: memuat daftar mill, lalu daftar
/// warehouse setiap kali mill berganti.
class RwSelectorBloc extends Bloc<RwSelectorEvent, RwSelectorState> {
  final ReceiveWarehouseRepository repository;

  RwSelectorBloc({required this.repository}) : super(const RwSelectorState()) {
    on<RwSelectorStarted>(_onStarted);
    on<RwSelectorMillChanged>(_onMillChanged);
  }

  Future<void> _onStarted(
    RwSelectorStarted event,
    Emitter<RwSelectorState> emit,
  ) async {
    emit(state.copyWith(optionLoading: true, clearError: true));

    final result = await repository.getOption();

    await result.fold(
      (l) async => emit(
        state.copyWith(
          optionLoading: false,
          error: l.message ?? 'Gagal mengambil daftar mill',
        ),
      ),
      (option) async {
        emit(
          state.copyWith(
            optionLoading: false,
            mills: option.mills,
          ),
        );

        /// Kalau user hanya punya satu mill, langsung muat warehouse-nya.
        if (option.mills.length == 1) {
          add(RwSelectorMillChanged(option.mills.first));
        }
      },
    );
  }

  Future<void> _onMillChanged(
    RwSelectorMillChanged event,
    Emitter<RwSelectorState> emit,
  ) async {
    emit(
      state.copyWith(
        selectedMill: event.mill,
        warehouses: const [],
        warehouseLoading: true,
        clearWarehouse: true,
        clearError: true,
      ),
    );

    final result = await repository.getWarehouses(millId: event.mill.millID);

    /// Abaikan hasil lama kalau user sudah berganti mill lagi.
    if (state.selectedMill != event.mill) return;

    result.fold(
      (l) => emit(
        state.copyWith(
          warehouseLoading: false,
          error: l.message ?? 'Gagal mengambil daftar warehouse',
        ),
      ),
      (r) => emit(state.copyWith(warehouseLoading: false, warehouses: r)),
    );
  }
}
