import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:vivakencanaapp/data/repository/driver_activity_repository.dart';
import 'package:vivakencanaapp/models/driver_activity/driver_delivery.dart';
import 'package:vivakencanaapp/models/errors/custom_exception.dart';

part 'delivery_list_event.dart';
part 'delivery_list_state.dart';

class DeliveryListBloc extends Bloc<DeliveryListEvent, DeliveryListState> {
  final DriverActivityRepository driverActivityRepository;

  DeliveryListBloc({required this.driverActivityRepository})
      : super(DeliveryListInitial()) {
    on<GetDeliveryListEvent>(_onGetDeliveryList);
    on<RefreshDeliveryListEvent>(_onRefreshDeliveryList);
    on<FilterDeliveryListEvent>(_onFilterDeliveryList);
  }

  Future<void> _onGetDeliveryList(
    GetDeliveryListEvent event,
    Emitter<DeliveryListState> emit,
  ) async {
    emit(DeliveryListLoading());
    final result = await driverActivityRepository.getDeliveryList();
    result.fold(
      (failure) => emit(DeliveryListFailure(
        message: failure.message ?? 'Gagal memuat daftar pengiriman',
        error: failure,
      )),
      (deliveries) => emit(DeliveryListSuccess(
        allDeliveries: deliveries,
        filteredDeliveries: deliveries,
      )),
    );
  }

  Future<void> _onRefreshDeliveryList(
    RefreshDeliveryListEvent event,
    Emitter<DeliveryListState> emit,
  ) async {
    final result = await driverActivityRepository.getDeliveryList();
    result.fold(
      (failure) => emit(DeliveryListFailure(
        message: failure.message ?? 'Gagal memuat ulang daftar pengiriman',
        error: failure,
      )),
      (deliveries) {
        String query = '';
        if (state is DeliveryListSuccess) {
          query = (state as DeliveryListSuccess).searchQuery;
        }
        final filtered = _filter(deliveries, query);
        emit(DeliveryListSuccess(
          allDeliveries: deliveries,
          filteredDeliveries: filtered,
          searchQuery: query,
        ));
      },
    );
  }

  void _onFilterDeliveryList(
    FilterDeliveryListEvent event,
    Emitter<DeliveryListState> emit,
  ) {
    if (state is DeliveryListSuccess) {
      final currentState = state as DeliveryListSuccess;
      final filtered = _filter(currentState.allDeliveries, event.query);
      emit(DeliveryListSuccess(
        allDeliveries: currentState.allDeliveries,
        filteredDeliveries: filtered,
        searchQuery: event.query,
      ));
    }
  }

  List<DriverDelivery> _filter(List<DriverDelivery> list, String query) {
    if (query.trim().isEmpty) return list;
    final lower = query.toLowerCase().trim();
    return list.where((item) {
      return item.trId.toLowerCase().contains(lower) ||
          item.vehicleId.toLowerCase().contains(lower) ||
          item.destination.toLowerCase().contains(lower) ||
          item.millName.toLowerCase().contains(lower) ||
          item.name.toLowerCase().contains(lower);
    }).toList();
  }
}

