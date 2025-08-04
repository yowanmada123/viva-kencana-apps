import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:vivakencanaapp/utils/strict_location.dart';

part 'sales_activity_form_checkin_event.dart';
part 'sales_activity_form_checkin_state.dart';

class SalesActivityFormCheckInBloc extends Bloc<SalesActivityFormCheckInEvent, SalesActivityFormCheckInState> {
  SalesActivityFormCheckInBloc() : super(const SalesActivityFormCheckInState()) {

    on<SetImageEvent>((event, emit) {
      emit(state.copyWith(imageCheckIn: event.image));
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
}
