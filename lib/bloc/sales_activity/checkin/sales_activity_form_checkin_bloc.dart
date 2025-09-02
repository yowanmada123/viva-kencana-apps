import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import '../../../data/repository/sales_repository.dart';
import '../../../models/sales_activity/sales_info.dart';
import '../../../models/sales_activity/submit_data.dart';
import '../../../utils/strict_location.dart';

part 'sales_activity_form_checkin_event.dart';
part 'sales_activity_form_checkin_state.dart';

class SalesActivityFormCheckInBloc extends Bloc<SalesActivityFormCheckInEvent, SalesActivityFormCheckInState> {
  final SalesActivityRepository salesActivityRepository;
  SalesActivityFormCheckInBloc({required this.salesActivityRepository}) : super(const SalesActivityFormCheckInState()) {
    on<SubmitSalesActivityCheckInForm>(_onSubmitSalesActivityForm);
    on<LoadCurrentLocation>(_onLoadCurrentLocation);
    on<LoadSalesData>(_onGetSalesData);
    on<AddImageEvent>(_onAddImageEvent);
    on<UpdateRemarkEvent>(_onUpdateRemarkEvent);

    on<SetOdometerEvent>((event, emit) {
      emit(state.copyWith(odometer: event.odometer));
    });

    on<SetLocationEvent>((event, emit) async {
      try {
        emit(state.copyWith(isLoadingLocation: true));
        StrictLocation.checkLocationRequirements();
        final LocationSettings locationSettings = LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 100,
        );
        final position = await Geolocator.getCurrentPosition(locationSettings: locationSettings);

        final placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        String address = placemarks.isNotEmpty
            ? "${placemarks.first.street}, ${placemarks.first.locality}, ${placemarks.first.administrativeArea}"
            : "Address not found";

        emit(state.copyWith(
          position: position,
          address: address,
          isLoadingLocation: false,
        ));
      } catch (e) {
        print("Failed to get location: $e");
        emit(state.copyWith(isLoadingLocation: false));
      }
    });
  }

  Future<void> _onSubmitSalesActivityForm(
    SubmitSalesActivityCheckInForm event,
    Emitter<SalesActivityFormCheckInState> emit,
  ) async {
    emit(SalesActivityFormCheckInLoading());
    final result = await salesActivityRepository.submitSalesCheckIn(formData: event.formData);

    result.fold(
      (failure) {
        emit(SalesActivityFormCheckInError(failure.message!));
      },
      (message) {
        emit(SalesActivityFormCheckInSuccess());
      },
    );
  }

  Future<void> _onLoadCurrentLocation(
    LoadCurrentLocation event,
    Emitter<SalesActivityFormCheckInState> emit,
  ) async {
    emit(CurrentLocationLoading());
    try {
      final position = await StrictLocation.getCurrentPosition();

      emit(state.copyWith(position: position));
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> _onGetSalesData(
    LoadSalesData event,
    Emitter<SalesActivityFormCheckInState> emit,
  ) async {
    emit(SalesDataLoading());
    try {
      final result = await salesActivityRepository.getSalesInfo();
      result.fold(
        (failure) {
          emit(SalesDataError(failure.message!));
        },
        (sales) {
          emit(SalesDataSuccess(sales: sales));
        },
      );
    } catch (e) {
      emit(SalesDataError(e.toString()));
    }
  }

  Future<void> _onAddImageEvent(
    AddImageEvent event,
    Emitter<SalesActivityFormCheckInState> emit,
  ) async {
    emit(state.copyWith(images: [...state.images, event.image]));
  }

  Future<void> _onUpdateRemarkEvent(
    UpdateRemarkEvent event,
    Emitter<SalesActivityFormCheckInState> emit,
  ) async {
    final updatedImages = [...state.images];
    updatedImages[event.index] =
        updatedImages[event.index].copyWith(remark: event.remark);

    emit(state.copyWith(images: updatedImages));
  }
}
