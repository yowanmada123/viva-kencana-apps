import 'dart:convert';

import 'package:flutter/foundation.dart';

class SalesActivityFormData {
  final String? customerId;
  final String? customerName;
  final String? customerKtpNpwp;
  final String? customerPhone;
  final String? customerEmail;
  final String? customerAddress;
  final String? customerProvince;
  final String? customerCity;
  final String? customerDistrict;
  final String? customerVillage;
  final String? customerBussiness;
  final String? customerBussinessStatus;
  final String? customerBussinessType;
  final String? customerTaxType;
  final String? customerOfficeType;
  final String? customerOfficeOwnership;
  final String? customerType;
  final String? checkboxCar;
  final bool? chkProductOffer;
  final bool? chkTakeOrder;
  final bool? chkInfoPromo;
  final bool? chkTakeBilling;
  final bool? chkCustomerVisit;
  final bool? chkNewCustRequest;
  final double? latitude;
  final double? longitude;
  final String? currentLocation;
  final String? remark;
  final String? image;
  final List<ImageItem>? images;
  final String? new_;
  final String? speedoKmModel;
  final String? checkpoint;
  final String? salesid;
  final String? officeid;
  final bool? setAddress;
  SalesActivityFormData({
    this.customerId = '',
    this.customerName = '',
    this.customerKtpNpwp = '',
    this.customerPhone = '',
    this.customerEmail = '',
    this.customerAddress = '',
    this.customerProvince = '',
    this.customerCity = '',
    this.customerDistrict = '',
    this.customerVillage = '',
    this.customerBussiness = '',
    this.customerBussinessStatus = '',
    this.customerBussinessType = '',
    this.customerTaxType = '',
    this.customerOfficeType = '',
    this.customerOfficeOwnership = '',
    this.customerType = '',
    this.checkboxCar = '',
    this.chkProductOffer = false,
    this.chkTakeOrder = false,
    this.chkInfoPromo = false,
    this.chkTakeBilling = false,
    this.chkCustomerVisit = false,
    this.chkNewCustRequest = false,
    this.latitude = 0.0,
    this.longitude = 0.0,
    this.currentLocation = '',
    this.remark = '',
    this.image = '',
    this.images = const [],
    this.new_ = '',
    this.speedoKmModel = '',
    this.checkpoint = '',
    this.salesid = '',
    this.officeid = '',
    this.setAddress = false,
  });

  SalesActivityFormData copyWith({
    String? customerId,
    String? customerName,
    String? customerKtpNpwp,
    String? customerPhone,
    String? customerEmail,
    String? customerAddress,
    String? customerProvince,
    String? customerCity,
    String? customerDistrict,
    String? customerVillage,
    String? customerBussiness,
    String? customerBussinessStatus,
    String? customerBussinessType,
    String? customerTaxType,
    String? customerOfficeType,
    String? customerOfficeOwnership,
    String? customerType,
    String? checkboxCar,
    bool? chkProductOffer,
    bool? chkTakeOrder,
    bool? chkInfoPromo,
    bool? chkTakeBilling,
    bool? chkCustomerVisit,
    bool? chkNewCustRequest,
    double? latitude,
    double? longitude,
    String? currentLocation,
    String? remark,
    String? image,
    List<ImageItem>? images,
    List<ImageItem>? imagesCheckpoint,
    String? new_,
    String? speedoKmModel,
    String? checkpoint,
    String? salesid,
    String? officeid,
    bool? setAddress,
  }) {
    return SalesActivityFormData(
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerKtpNpwp: customerKtpNpwp ?? this.customerKtpNpwp,
      customerPhone: customerPhone ?? this.customerPhone,
      customerEmail: customerEmail ?? this.customerEmail,
      customerAddress: customerAddress ?? this.customerAddress,
      customerProvince: customerProvince ?? this.customerProvince,
      customerCity: customerCity ?? this.customerCity,
      customerDistrict: customerDistrict ?? this.customerDistrict,
      customerVillage: customerVillage ?? this.customerVillage,
      customerBussiness: customerBussiness ?? this.customerBussiness,
      customerBussinessStatus: customerBussinessStatus ?? this.customerBussinessStatus,
      customerBussinessType: customerBussinessType ?? this.customerBussinessType,
      customerTaxType: customerTaxType ?? this.customerTaxType,
      customerOfficeType: customerOfficeType ?? this.customerOfficeType,
      customerOfficeOwnership: customerOfficeOwnership ?? this.customerOfficeOwnership,
      customerType: customerType ?? this.customerType,
      checkboxCar: checkboxCar ?? this.checkboxCar,
      chkProductOffer: chkProductOffer ?? this.chkProductOffer,
      chkTakeOrder: chkTakeOrder ?? this.chkTakeOrder,
      chkInfoPromo: chkInfoPromo ?? this.chkInfoPromo,
      chkTakeBilling: chkTakeBilling ?? this.chkTakeBilling,
      chkCustomerVisit: chkCustomerVisit ?? this.chkCustomerVisit,
      chkNewCustRequest: chkNewCustRequest ?? this.chkNewCustRequest,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      currentLocation: currentLocation ?? this.currentLocation,
      remark: remark ?? this.remark,
      image: image ?? this.image,
      images: images ?? this.images,
      new_: new_ ?? this.new_,
      speedoKmModel: speedoKmModel ?? this.speedoKmModel,
      checkpoint: checkpoint ?? this.checkpoint,
      salesid: salesid ?? this.salesid,
      officeid: officeid ?? this.officeid,
      setAddress: setAddress ?? this.setAddress,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'customer_id': customerId,
      'customer_name': customerName,
      'customer_ktp_npwp': customerKtpNpwp,
      'customer_phone': customerPhone,
      'customer_email': customerEmail,
      'customer_address': customerAddress,
      'customer_province': customerProvince,
      'customer_city': customerCity,
      'customer_district': customerDistrict,
      'customer_village': customerVillage,
      'customer_bussiness': customerBussiness,
      'customer_bussiness_status': customerBussinessStatus,
      'customer_bussiness_type': customerBussinessType,
      'customer_tax_type': customerTaxType,
      'customer_office_type': customerOfficeType,
      'customer_office_ownership': customerOfficeOwnership,
      'customer_type': customerType,
      'sales_vehicle': checkboxCar,
      'chk_product_offer': chkProductOffer,
      'chk_take_order': chkTakeOrder,
      'chk_info_promo': chkInfoPromo,
      'chk_take_billing': chkTakeBilling,
      'chk_customer_visit': chkCustomerVisit,
      'chk_new_cust_request': chkNewCustRequest,
      'latitude': latitude,
      'longitude': longitude,
      'gps_location': currentLocation,
      'remark': remark,
      'images': images?.map((x) => x.toMap()).toList(),
      'vehicle_odometer': speedoKmModel,
      'checkpoint': checkpoint,
      'sales_id': salesid,
      'office_id': officeid,
      'set_address': setAddress,
    };
  }

  factory SalesActivityFormData.fromMap(Map<String, dynamic> map) {
    return SalesActivityFormData(
      customerId: map['customerId'] ?? '',
      customerName: map['customerName'] ?? '',
      customerKtpNpwp: map['customerKtpNpwp'] ?? '',
      customerPhone: map['customerPhone'] ?? '',
      customerEmail: map['customerEmail'] ?? '',
      customerAddress: map['customerAddress'] ?? '',
      customerProvince: map['customerProvince'] ?? '',
      customerCity: map['customerCity'] ?? '',
      customerDistrict: map['customerDistrict'] ?? '',
      customerVillage: map['customerVillage'] ?? '',
      customerBussiness: map['customerBussiness'] ?? '',
      customerBussinessStatus: map['customerBussinessStatus'] ?? '',
      customerBussinessType: map['customerBussinessType'] ?? '',
      customerTaxType: map['customerTaxType'] ?? '',
      customerOfficeType: map['customerOfficeType'] ?? '',
      customerOfficeOwnership: map['customerOfficeOwnership'] ?? '',
      customerType: map['customerType'] ?? '',
      checkboxCar: map['checkboxCar'] ?? '',
      chkProductOffer: map['chkProductOffer'] ?? false,
      chkTakeOrder: map['chkTakeOrder'] ?? false,
      chkInfoPromo: map['chkInfoPromo'] ?? false,
      chkTakeBilling: map['chkTakeBilling'] ?? false,
      chkCustomerVisit: map['chkCustomerVisit'] ?? false,
      chkNewCustRequest: map['chkNewCustRequest'] ?? false,
      latitude: map['latitude']?.toDouble() ?? 0.0,
      longitude: map['longitude']?.toDouble() ?? 0.0,
      currentLocation: map['gps_location'] ?? '',
      remark: map['remark'] ?? '',
      image: map['image'] ?? '',
      images: List<ImageItem>.from(map['images']?.map((x) => ImageItem.fromMap(x))),
      new_: map['new'] ?? '',
      speedoKmModel: map['speedoKmModel'] ?? '',
      checkpoint: map['checkpoint'] ?? '',
      officeid: map['office_id'] ?? '',
      salesid: map['sales_id'] ?? '',
      setAddress: map['set_address'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory SalesActivityFormData.fromJson(String source) =>
      SalesActivityFormData.fromMap(json.decode(source));

  @override
  String toString() {
    return 'SalesActivityFormData(customerId: $customerId, customerName: $customerName, customerKtpNpwp: $customerKtpNpwp, customerPhone: $customerPhone, customerEmail: $customerEmail, customerAddress: $customerAddress, customerProvince: $customerProvince, customerCity: $customerCity, customerDistrict: $customerDistrict, customerVillage: $customerVillage, customerBussiness: $customerBussiness, customerBussinessStatus: $customerBussinessStatus, customerBussinessType: $customerBussinessType, customerTaxType: $customerTaxType, customerOfficeType: $customerOfficeType, customerOfficeOwnership: $customerOfficeOwnership, customerType: $customerType, checkboxCar: $checkboxCar, chkProductOffer: $chkProductOffer, chkTakeOrder: $chkTakeOrder, chkInfoPromo: $chkInfoPromo, chkTakeBilling: $chkTakeBilling, chkCustomerVisit: $chkCustomerVisit, chkNewCustRequest: $chkNewCustRequest, latitude: $latitude, longitude: $longitude, currentLocation: $currentLocation, remark: $remark, image: $image, images: $images, new_: $new_, speedoKmModel: $speedoKmModel, checkpoint: $checkpoint, salesid: $salesid, officeid: $officeid, setAddress: $setAddress)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SalesActivityFormData &&
        other.customerId == customerId &&
        other.customerName == customerName &&
        other.customerKtpNpwp == customerKtpNpwp &&
        other.customerPhone == customerPhone &&
        other.customerEmail == customerEmail &&
        other.customerAddress == customerAddress &&
        other.customerProvince == customerProvince &&
        other.customerCity == customerCity &&
        other.customerDistrict == customerDistrict &&
        other.customerVillage == customerVillage &&
        other.customerBussiness == customerBussiness &&
        other.customerBussinessStatus == customerBussinessStatus &&
        other.customerBussinessType == customerBussinessType &&
        other.customerTaxType == customerTaxType &&
        other.customerOfficeType == customerOfficeType &&
        other.customerOfficeOwnership == customerOfficeOwnership &&
        other.customerType == customerType &&
        other.checkboxCar == checkboxCar &&
        other.chkProductOffer == chkProductOffer &&
        other.chkTakeOrder == chkTakeOrder &&
        other.chkInfoPromo == chkInfoPromo &&
        other.chkTakeBilling == chkTakeBilling &&
        other.chkCustomerVisit == chkCustomerVisit &&
        other.chkNewCustRequest == chkNewCustRequest &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.currentLocation == currentLocation &&
        other.remark == remark &&
        other.image == image &&
        listEquals(other.images, images) &&
        other.new_ == new_ &&
        other.speedoKmModel == speedoKmModel &&
        other.checkpoint == checkpoint &&
        other.salesid == salesid &&
        other.officeid == officeid &&
        other.setAddress == setAddress;
  }

  @override
  int get hashCode {
    return customerId.hashCode ^
        customerName.hashCode ^
        customerKtpNpwp.hashCode ^
        customerPhone.hashCode ^
        customerEmail.hashCode ^
        customerAddress.hashCode ^
        customerProvince.hashCode ^
        customerCity.hashCode ^
        customerDistrict.hashCode ^
        customerVillage.hashCode ^
        customerBussiness.hashCode ^
        customerBussinessStatus.hashCode ^
        customerBussinessType.hashCode ^
        customerTaxType.hashCode ^
        customerOfficeType.hashCode ^
        customerOfficeOwnership.hashCode ^
        customerType.hashCode ^
        checkboxCar.hashCode ^
        chkProductOffer.hashCode ^
        chkTakeOrder.hashCode ^
        chkInfoPromo.hashCode ^
        chkTakeBilling.hashCode ^
        chkCustomerVisit.hashCode ^
        chkNewCustRequest.hashCode ^
        latitude.hashCode ^
        longitude.hashCode ^
        currentLocation.hashCode ^
        remark.hashCode ^
        image.hashCode ^
        images.hashCode ^
        new_.hashCode ^
        speedoKmModel.hashCode ^
        checkpoint.hashCode ^
        salesid.hashCode ^
        officeid.hashCode ^
        setAddress.hashCode;
  }
}

class ImageItem {
  final String file;
  final String remark;

  ImageItem({required this.file, this.remark = ""});

  ImageItem copyWith({String? file, String? remark}) {
    return ImageItem(
      file: file ?? this.file,
      remark: remark ?? this.remark,
    );
  }

  Map<String, dynamic> toMap() {
    return {'src': file, 'remark': remark};
  }

  factory ImageItem.fromMap(Map<String, dynamic> map) {
    return ImageItem(
      file: map['src'] ?? '',
      remark: map['remark'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "src": file,
      "remark": remark,
    };
  }

  @override
  String toString() => "ImageItem(file: $file, remark: $remark)";
}
