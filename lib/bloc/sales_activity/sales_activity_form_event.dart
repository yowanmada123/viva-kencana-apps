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

class AddImageEvent extends SalesActivityFormEvent {
  final ImageItem image;
  const AddImageEvent(this.image);

  @override
  List<Object?> get props => [image];
}

class UpdateRemarkEvent extends SalesActivityFormEvent {
  final int index;
  final String remark;

  const UpdateRemarkEvent(this.index, this.remark);

  @override
  List<Object?> get props => [index, remark];
}

class SetOdometerEvent extends SalesActivityFormEvent {
  final String odometer;
  const SetOdometerEvent(this.odometer);

  @override
  List<Object?> get props => [odometer];
}

class SetLocationEvent extends SalesActivityFormEvent {}

class SearchCustomerData extends SalesActivityFormEvent {
  final String entityId;
  final String keyword;

  const SearchCustomerData(this.entityId, this.keyword);
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
  final String entityId;
  final String customerId;
  const FetchCustomerDetail(this.entityId, this.customerId);
}

class SubmitSalesActivityForm extends SalesActivityFormEvent {
  final SalesActivityFormData formData;

  SubmitSalesActivityForm(this.formData);
}

class LoadCurrentLocation extends SalesActivityFormEvent {}
