import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import '../../data/repository/sales_repository.dart';
import '../../models/sales_activity/customer_detail.dart';
import '../../models/sales_activity/customer_info.dart';
import '../../models/sales_activity/submit_data.dart';
import '../../utils/strict_location.dart';

part 'sales_activity_form_event.dart';
part 'sales_activity_form_state.dart';

class SalesActivityFormBloc
    extends Bloc<SalesActivityFormEvent, SalesActivityFormState> {
  final SalesActivityRepository salesActivityRepository;
  SalesActivityFormBloc({required this.salesActivityRepository})
    : super(const SalesActivityFormState()) {
    on<SearchCustomerData>(_onSearchCustomer);
    on<FetchProvinces>(_onFetchProvinces);
    on<FetchCities>(_onFetchCities);
    on<FetchDistricts>(_onFetchDistricts);
    on<FetchVillages>(_onFetchVillages);
    on<FetchCustomerDetail>(_onFetchCustomerDetail);
    on<ToggleActivityEvent>(_onToggleActivity);
    on<AddImageEvent>(_onAddImageEvent);
    on<UpdateRemarkEvent>(_onUpdateRemarkEvent);
    on<SetLocationEvent>(_onSetLocation);
    on<SubmitSalesActivityForm>(_onSalesActivitySubmit);
    on<LoadCurrentLocation>(_onLoadCurrentLocation);
    on<SetOdometerEvent>(_onSetOdometerEvent);
  }

  Future<void> _onSetOdometerEvent(
    SetOdometerEvent event,
    Emitter<SalesActivityFormState> emit,
  ) async {
    emit(state.copyWith(odometer: event.odometer));
  }

  Future<void> _onSearchCustomer(
    SearchCustomerData event,
    Emitter<SalesActivityFormState> emit,
  ) async {
    emit(CustomerSearchLoading());
    try {
      final res = await salesActivityRepository.getCustomers(
        entityId: event.entityId,
        keyword: event.keyword,
      );
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
    final result = await salesActivityRepository.getCities(
      province: event.province,
    );
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
    final result = await salesActivityRepository.getVillages(
      district: event.district,
    );
    result.fold(
      (failure) => emit(SalesActivityError(failure.message!)),
      (data) => emit(VillageLoadSuccess(data)),
    );
  }

  Future<void> _onFetchCustomerDetail(
    FetchCustomerDetail event,
    Emitter<SalesActivityFormState> emit,
  ) async {
    final result = await salesActivityRepository.getCustomerDetail(
      entityId: event.entityId,
      customerId: event.customerId,
    );

    result.fold(
      (failure) => emit(SalesActivityError(failure.message!)),
      (data) => emit(CustomerDetailLoadSuccess(data)),
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

  Future<void> _onAddImageEvent(
    AddImageEvent event,
    Emitter<SalesActivityFormState> emit,
  ) async {
    emit(state.copyWith(images: [...state.images, event.image]));
  }

  Future<void> _onUpdateRemarkEvent(
    UpdateRemarkEvent event,
    Emitter<SalesActivityFormState> emit,
  ) async {
    final updatedImages = [...state.images];
    updatedImages[event.index] =
        updatedImages[event.index].copyWith(remark: event.remark);

    emit(state.copyWith(images: updatedImages));
  }

  Future<void> _onSetLocation(
    SetLocationEvent event,
    Emitter<SalesActivityFormState> emit,
  ) async {
    try {
      emit(state.copyWith(isLoadingLocation: true));
      StrictLocation.checkLocationRequirements();

      final position = await StrictLocation.getCurrentPosition();

      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      final address =
          placemarks.isNotEmpty
              ? "${placemarks.first.street}, ${placemarks.first.locality}, ${placemarks.first.administrativeArea}"
              : "Address not found";

      emit(state.copyWith(position: position, address: address, isLoadingLocation: false));
    } catch (e) {
      emit(state.copyWith(isLoadingLocation: false));
    }
  }

  Future<void> _onSalesActivitySubmit(
    SubmitSalesActivityForm event,
    Emitter<SalesActivityFormState> emit,
  ) async {
    emit(SalesActivityFormLoading());
    final result = await salesActivityRepository.submitSalesActivity(
      formData: event.formData,
    );
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
    final position = await StrictLocation.getCurrentPosition();
    emit(state.copyWith(position: position));
  }
}
