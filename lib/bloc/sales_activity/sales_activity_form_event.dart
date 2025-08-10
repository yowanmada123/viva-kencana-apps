part of 'sales_activity_form_bloc.dart';

abstract class SalesActivityFormEvent extends Equatable {
  const SalesActivityFormEvent();

  @override
  List<Object?> get props => [];
}

class ToggleActivityEvent extends SalesActivityFormEvent {
  final String activity;

  const ToggleActivityEvent(this.activity);

  @override
  List<Object?> get props => [activity];
}

class SetImageEvent extends SalesActivityFormEvent {
  final File image;

  const SetImageEvent(this.image);

  @override
  List<Object?> get props => [image];
}

class AddImageEvent extends SalesActivityFormEvent {
  final File image;

  const AddImageEvent(this.image);

  @override
  List<Object?> get props => [image];
}

class SetOfficeOption extends SalesActivityFormEvent {
  final String option;

  const SetOfficeOption(this.option);

  @override
  List<Object?> get props => [option];
}

class SetUserOption extends SalesActivityFormEvent {
  final String option;

  const SetUserOption(this.option);

  @override
  List<Object?> get props => [option];
}

class SetOdometerEvent extends SalesActivityFormEvent {
  final String odometer;
  const SetOdometerEvent(this.odometer);

  @override
  List<Object?> get props => [odometer];
}

class SetLocationEvent extends SalesActivityFormEvent {}

class SearchCustomerData extends SalesActivityFormEvent {
  final String search;

  const SearchCustomerData(this.search);
}

class FetchProvinces extends SalesActivityFormEvent {}

class FetchCities extends SalesActivityFormEvent {
  final String province;
  const FetchCities(this.province);
}

class FetchDistricts extends SalesActivityFormEvent {
  final String city;
  const FetchDistricts(this.city);
}

class FetchVillages extends SalesActivityFormEvent {
  final String district;
  const FetchVillages(this.district);
}

class FetchCustomerDetail extends SalesActivityFormEvent {
  final String customerId;
  const FetchCustomerDetail(this.customerId);
}

class SubmitSalesActivityForm extends SalesActivityFormEvent {
  final SalesActivityFormData formData;

  SubmitSalesActivityForm(this.formData);
}

class LoadCurrentLocation extends SalesActivityFormEvent {}
