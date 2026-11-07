import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
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
    log('DeliveryListBloc: Fetching delivery list...');
    debugPrint('[DeliveryListBloc]: Fetching delivery list...');

    final result = await driverActivityRepository.getDeliveryList();
    result.fold(
      (failure) {
        log('DeliveryListBloc Failure: ${failure.message}');
        debugPrint('[DeliveryListBloc Failure]: ${failure.message}');
        emit(DeliveryListFailure(
          message: failure.message ?? 'Gagal memuat daftar pengiriman',
          error: failure,
        ));
      },
      (deliveries) {
        log('DeliveryListBloc Success: ${deliveries.length} items loaded');
        debugPrint('[DeliveryListBloc Success]: ${deliveries.length} items loaded');
        emit(DeliveryListSuccess(
          allDeliveries: deliveries,
          filteredDeliveries: deliveries,
        ));
      },
    );
  }

  Future<void> _onRefreshDeliveryList(
    RefreshDeliveryListEvent event,
    Emitter<DeliveryListState> emit,
  ) async {
    log('DeliveryListBloc: Refreshing delivery list...');
    debugPrint('[DeliveryListBloc]: Refreshing delivery list...');

    final result = await driverActivityRepository.getDeliveryList();
    result.fold(
      (failure) {
        log('DeliveryListBloc Refresh Failure: ${failure.message}');
        debugPrint('[DeliveryListBloc Refresh Failure]: ${failure.message}');
        emit(DeliveryListFailure(
          message: failure.message ?? 'Gagal memuat ulang daftar pengiriman',
          error: failure,
        ));
      },
      (deliveries) {
        log('DeliveryListBloc Refresh Success: ${deliveries.length} items loaded');
        debugPrint('[DeliveryListBloc Refresh Success]: ${deliveries.length} items loaded');
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
      final matchesBatch = item.trId.toLowerCase().contains(lower) ||
          item.vehicleId.toLowerCase().contains(lower) ||
          item.destination.toLowerCase().contains(lower) ||
          item.millName.toLowerCase().contains(lower) ||
          item.entity.toLowerCase().contains(lower) ||
          item.idEmployee.toLowerCase().contains(lower) ||
          item.driverId.toLowerCase().contains(lower) ||
          item.name.toLowerCase().contains(lower);

      if (matchesBatch) return true;

      return item.delivHdrItems.any((hdr) =>
          hdr.delivId.toLowerCase().contains(lower) ||
          hdr.orderId.toLowerCase().contains(lower) ||
          hdr.shipto.toLowerCase().contains(lower) ||
          hdr.receiver.toLowerCase().contains(lower));
    }).toList();
  }
}
