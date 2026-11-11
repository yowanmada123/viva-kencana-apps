import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:vivakencanaapp/data/repository/driver_activity_repository.dart';
import 'package:vivakencanaapp/models/driver_activity/driver_delivery.dart';
import 'package:vivakencanaapp/models/errors/custom_exception.dart';

part 'delivery_history_event.dart';
part 'delivery_history_state.dart';

class DeliveryHistoryBloc
    extends Bloc<DeliveryHistoryEvent, DeliveryHistoryState> {
  final DriverActivityRepository driverActivityRepository;

  DeliveryHistoryBloc({required this.driverActivityRepository})
      : super(DeliveryHistoryInitial()) {
    on<GetDeliveryHistoryEvent>(_onGetDeliveryHistory);
    on<RefreshDeliveryHistoryEvent>(_onRefreshDeliveryHistory);
  }

  Future<void> _onGetDeliveryHistory(
    GetDeliveryHistoryEvent event,
    Emitter<DeliveryHistoryState> emit,
  ) async {
    emit(DeliveryHistoryLoading());
    log('DeliveryHistoryBloc: Fetching delivery history...');
    debugPrint('[DeliveryHistoryBloc]: Fetching delivery history...');

    final result = await driverActivityRepository.getDeliveryHistory();
    result.fold(
      (failure) {
        log('DeliveryHistoryBloc Failure: ${failure.message}');
        debugPrint('[DeliveryHistoryBloc Failure]: ${failure.message}');
        emit(DeliveryHistoryFailure(
          message: failure.message ?? 'Gagal memuat riwayat pengiriman',
          error: failure,
        ));
      },
      (deliveries) {
        log('DeliveryHistoryBloc Success: ${deliveries.length} items loaded');
        debugPrint(
            '[DeliveryHistoryBloc Success]: ${deliveries.length} items loaded');
        emit(DeliveryHistorySuccess(deliveries: deliveries));
      },
    );
  }

  Future<void> _onRefreshDeliveryHistory(
    RefreshDeliveryHistoryEvent event,
    Emitter<DeliveryHistoryState> emit,
  ) async {
    log('DeliveryHistoryBloc: Refreshing delivery history...');
    debugPrint('[DeliveryHistoryBloc]: Refreshing delivery history...');

    final result = await driverActivityRepository.getDeliveryHistory();
    result.fold(
      (failure) {
        log('DeliveryHistoryBloc Refresh Failure: ${failure.message}');
        debugPrint('[DeliveryHistoryBloc Refresh Failure]: ${failure.message}');
        emit(DeliveryHistoryFailure(
          message: failure.message ?? 'Gagal memuat ulang riwayat pengiriman',
          error: failure,
        ));
      },
      (deliveries) {
        log('DeliveryHistoryBloc Refresh Success: ${deliveries.length} items loaded');
        debugPrint(
            '[DeliveryHistoryBloc Refresh Success]: ${deliveries.length} items loaded');
        emit(DeliveryHistorySuccess(deliveries: deliveries));
      },
    );
  }
}

