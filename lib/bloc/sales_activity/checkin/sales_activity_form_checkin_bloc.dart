import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import '../../../data/repository/sales_repository.dart';
import '../../../models/sales_activity/checkin_info.dart';
import '../../../models/sales_activity/submit_data.dart';
import '../../../utils/strict_location.dart';

part 'sales_activity_form_checkin_event.dart';
part 'sales_activity_form_checkin_state.dart';

class SalesActivityFormCheckInBloc extends Bloc<SalesActivityFormCheckInEvent, SalesActivityFormCheckInState> {
  final SalesActivityRepository salesActivityRepository;
  SalesActivityFormCheckInBloc({required this.salesActivityRepository}) : super(const SalesActivityFormCheckInState()) {
    on<SubmitSalesActivityCheckInForm>(_onSubmitSalesActivityForm);
    on<LoadCheckinStatus>(_onGetCheckinStatus);
    on<LoadCurrentLocation>(_onLoadCurrentLocation);
    on<SetImageEvent>(_onSetImageEvent);

    on<SetOdometerEvent>((event, emit) {
      emit(state.copyWith(odometer: event.odometer));
    });
    on<SetCheckInEvent>((event, emit){
      emit(state.copyWith(isCheckedIn: true));
    });
    on<SetCheckOutEvent>((event, emit) {
      emit(state.copyWith(isCheckedOut: true));
    });

    on<SetLocationEvent>((event, emit) async {
      try {
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
        ));
      } catch (e) {
        print("Failed to get location: $e");
      }
    });
  }

  Future<void> _onSetImageEvent(
    SetImageEvent event,
    Emitter<SalesActivityFormCheckInState> emit,
  ) async {
    if (state is CheckinLoaded) {
      final current = state as CheckinLoaded;
      emit(current.copyWith(imageCheckIn: event.image));
    } else {
      emit(state.copyWith(imageCheckIn: event.image));
    }
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

  Future<void> _onGetCheckinStatus(
    LoadCheckinStatus event,
    Emitter<SalesActivityFormCheckInState> emit,
  ) async {
    emit(CheckinLoading());
    try {
      final result = await salesActivityRepository.getCheckinInfo();
      result.fold(
        (failure){
          emit(CheckinError(failure.message!));
        },
        (success){
          emit(CheckinLoaded(success));
        }
      );
    } catch (e) {
      emit(CheckinError(e.toString()));
    }
  }

  Future<void> _onLoadCurrentLocation(
    LoadCurrentLocation event,
    Emitter<SalesActivityFormCheckInState> emit,
  ) async {
    emit(CurrentLocationLoading());
    try {
      final position = await StrictLocation.getCurrentPosition();
      // final placemarks = await placemarkFromCoordinates(
      //   position.latitude,
      //   position.longitude,
      // );

      // final address =
      //     placemarks.isNotEmpty
      //         ? "${placemarks.first.street}, ${placemarks.first.locality}, ${placemarks.first.administrativeArea}"
      //         : "Address not found";

      emit(state.copyWith(position: position));
    } catch (e) {
      print(e.toString());
    }
  }
}
