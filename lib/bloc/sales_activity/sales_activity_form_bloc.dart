import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import '../../data/repository/sales_repository.dart';
import '../../models/sales_activity/customer_info.dart';
import '../../models/sales_activity/submit_data.dart';
import '../../utils/strict_location.dart';

part 'sales_activity_form_event.dart';
part 'sales_activity_form_state.dart';

class SalesActivityFormBloc extends Bloc<SalesActivityFormEvent, SalesActivityFormState> {
  final SalesActivityRepository salesActivityRepository;
  SalesActivityFormBloc({required this.salesActivityRepository}) : super(const SalesActivityFormState()) {
    on<SearchCustomerData>(_onSearchCustomer);
    on<FetchProvinces>(_onFetchProvinces);
    on<FetchCities>(_onFetchCities);
    on<FetchDistricts>(_onFetchDistricts);
    on<FetchVillages>(_onFetchVillages);
    on<ToggleActivityEvent>(_onToggleActivity);
    on<AddImageEvent>(_onAddImage);
    on<SetOfficeOption>(_onSetOfficeOption);
    on<SetUserOption>(_onSetUserOption);
    on<SetLocationEvent>(_onSetLocation);
    on<SubmitSalesActivityForm>(_onSalesActivitySubmit);
    on<LoadCurrentLocation>(_onLoadCurrentLocation);
  }

  Future<void> _onSearchCustomer(
    SearchCustomerData event,
    Emitter<SalesActivityFormState> emit,
  ) async {
    emit(CustomerSearchLoading());
    try {
      final res = await salesActivityRepository.getCustomers(searchQuery: event.search);
      res.fold(
        (failure) => emit(CustomerSearchError(failure.message!)),
        (customers) => emit(CustomerSearchSuccess(customers)),
      );
    } catch (e) {
      emit(CustomerSearchError(e.toString()));
    }
  }

  Future<void> _onFetchProvinces(
    FetchProvinces event,
    Emitter<SalesActivityFormState> emit,
  ) async {
    emit(SalesActivityLoading());
    final result = await salesActivityRepository.getProvinces();
    result.fold(
      (failure) => emit(SalesActivityError(failure.message!)),
      (data) => emit(ProvinceLoadSuccess(data)),
    );
  }

  Future<void> _onFetchCities(
    FetchCities event,
    Emitter<SalesActivityFormState> emit,
  ) async {
    emit(SalesActivityLoading());
    final result = await salesActivityRepository.getCities(province: event.province);
    result.fold(
      (failure) => emit(SalesActivityError(failure.message!)),
      (data) => emit(CityLoadSuccess(data)),
    );
  }

  Future<void> _onFetchDistricts(
    FetchDistricts event,
    Emitter<SalesActivityFormState> emit,
  ) async {
    emit(SalesActivityLoading());
    final result = await salesActivityRepository.getDistricts(city: event.city);
    result.fold(
      (failure) => emit(SalesActivityError(failure.message!)),
      (data) => emit(DistrictLoadSuccess(data)),
    );
  }

  Future<void> _onFetchVillages(
    FetchVillages event,
    Emitter<SalesActivityFormState> emit,
  ) async {
    emit(SalesActivityLoading());
    final result = await salesActivityRepository.getVillages(district: event.district);
    result.fold(
      (failure) => emit(SalesActivityError(failure.message!)),
      (data) => emit(VillageLoadSuccess(data)),
    );
  }

  void _onToggleActivity(
    ToggleActivityEvent event,
    Emitter<SalesActivityFormState> emit,
  ) {
    final updated = Set<String>.from(state.selectedActivities);
    if (updated.contains(event.activity)) {
      updated.remove(event.activity);
    } else {
      updated.add(event.activity);
    }
    emit(state.copyWith(selectedActivities: updated));
  }

  void _onAddImage(
    AddImageEvent event,
    Emitter<SalesActivityFormState> emit,
  ) {
    final updatedImages = List<ImageWithFile>.from(state.images)..add(ImageWithFile(file: event.image));
    emit(state.copyWith(images: updatedImages));
  }

  void _onSetOfficeOption(
    SetOfficeOption event,
    Emitter<SalesActivityFormState> emit,
  ) {
    emit(state.copyWith(officeOption: event.option));
  }

  void _onSetUserOption(
    SetUserOption event,
    Emitter<SalesActivityFormState> emit,
  ) {
    emit(state.copyWith(userOption: event.option));
  }

  Future<void> _onSetLocation(
    SetLocationEvent event,
    Emitter<SalesActivityFormState> emit,
  ) async {
    try {
      StrictLocation.checkLocationRequirements();

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 100,
        ),
      );

      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      final address = placemarks.isNotEmpty
          ? "${placemarks.first.street}, ${placemarks.first.locality}, ${placemarks.first.administrativeArea}"
          : "Address not found";

      emit(state.copyWith(
        position: position,
        address: address,
      ));
    } catch (e) {
      print("Failed to get location: $e");
    }
  }

  Future<void> _onSalesActivitySubmit(
    SubmitSalesActivityForm event,
    Emitter<SalesActivityFormState> emit,
  ) async {
    emit(SalesActivityFormLoading());
    final result = await salesActivityRepository.submitSalesActivity(formData: event.formData);
    result.fold(
      (failure) => emit(SalesActivityError(failure.message!)),
      (data) => emit(SalesActivityFormSuccess()),
    );
  }

  Future<void> _onLoadCurrentLocation(
    LoadCurrentLocation event,
    Emitter<SalesActivityFormState> emit,
  ) async {
    emit(CurrentLocationLoading());
    try {
      final position = await StrictLocation.getCurrentPosition();
      emit(CurrentLocationSuccess(position));
    } catch (e) {
      print(e.toString());
    }
  }
}
