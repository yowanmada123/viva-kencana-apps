import 'dart:convert';

import 'package:flutter/foundation.dart';

class SalesActivityFormData {
  final String customerId;
  final String custName;
  final String custKtpNpwp;
  final String custPhone;
  final String custEmail;
  final String custAddress;
  final String custProvince;
  final String custCity;
  final String custDistrict;
  final String custVillage;
  final String custBussiness;
  final String custBussinessStatus;
  final String custBussinessType;
  final String custTaxType;
  final String custOfficeType;
  final String custOfficeOwnership;
  final String custType;
  final String checkboxCar;
  final bool checkbox1;
  final bool checkbox2;
  final bool checkbox3;
  final bool checkbox4;
  final bool checkbox5;
  final bool checkbox6;
  final double latitude;
  final double longitude;
  final String currentLocation;
  final String remark;
  final String image;
  final List<Image> images;
  final String new_;
  final String speedoKmModel;
  final String checkpoint;
  final String salesid;
  SalesActivityFormData({
    required this.customerId,
    required this.custName,
    required this.custKtpNpwp,
    required this.custPhone,
    required this.custEmail,
    required this.custAddress,
    required this.custProvince,
    required this.custCity,
    required this.custDistrict,
    required this.custVillage,
    required this.custBussiness,
    required this.custBussinessStatus,
    required this.custBussinessType,
    required this.custTaxType,
    required this.custOfficeType,
    required this.custOfficeOwnership,
    required this.custType,
    required this.checkboxCar,
    required this.checkbox1,
    required this.checkbox2,
    required this.checkbox3,
    required this.checkbox4,
    required this.checkbox5,
    required this.checkbox6,
    required this.latitude,
    required this.longitude,
    required this.currentLocation,
    required this.remark,
    required this.image,
    required this.images,
    required this.new_,
    required this.speedoKmModel,
    required this.checkpoint,
    required this.salesid,
  });

  SalesActivityFormData copyWith({
    String? customerId,
    String? custName,
    String? custKtpNpwp,
    String? custPhone,
    String? custEmail,
    String? custAddress,
    String? custProvince,
    String? custCity,
    String? custDistrict,
    String? custVillage,
    String? custBussiness,
    String? custBussinessStatus,
    String? custBussinessType,
    String? custTaxType,
    String? custOfficeType,
    String? custOfficeOwnership,
    String? custType,
    String? checkboxCar,
    bool? checkbox1,
    bool? checkbox2,
    bool? checkbox3,
    bool? checkbox4,
    bool? checkbox5,
    bool? checkbox6,
    double? latitude,
    double? longitude,
    String? currentLocation,
    String? remark,
    String? image,
    List<Image>? images,
    String? new_,
    String? speedoKmModel,
    String? checkpoint,
    String? salesid,
  }) {
    return SalesActivityFormData(
      customerId: customerId ?? this.customerId,
      custName: custName ?? this.custName,
      custKtpNpwp: custKtpNpwp ?? this.custKtpNpwp,
      custPhone: custPhone ?? this.custPhone,
      custEmail: custEmail ?? this.custEmail,
      custAddress: custAddress ?? this.custAddress,
      custProvince: custProvince ?? this.custProvince,
      custCity: custCity ?? this.custCity,
      custDistrict: custDistrict ?? this.custDistrict,
      custVillage: custVillage ?? this.custVillage,
      custBussiness: custBussiness ?? this.custBussiness,
      custBussinessStatus: custBussinessStatus ?? this.custBussinessStatus,
      custBussinessType: custBussinessType ?? this.custBussinessType,
      custTaxType: custTaxType ?? this.custTaxType,
      custOfficeType: custOfficeType ?? this.custOfficeType,
      custOfficeOwnership: custOfficeOwnership ?? this.custOfficeOwnership,
      custType: custType ?? this.custType,
      checkboxCar: checkboxCar ?? this.checkboxCar,
      checkbox1: checkbox1 ?? this.checkbox1,
      checkbox2: checkbox2 ?? this.checkbox2,
      checkbox3: checkbox3 ?? this.checkbox3,
      checkbox4: checkbox4 ?? this.checkbox4,
      checkbox5: checkbox5 ?? this.checkbox5,
      checkbox6: checkbox6 ?? this.checkbox6,
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
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'customerId': customerId,
      'custName': custName,
      'custKtpNpwp': custKtpNpwp,
      'custPhone': custPhone,
      'custEmail': custEmail,
      'custAddress': custAddress,
      'custProvince': custProvince,
      'custCity': custCity,
      'custDistrict': custDistrict,
      'custVillage': custVillage,
      'custBussiness': custBussiness,
      'custBussinessStatus': custBussinessStatus,
      'custBussinessType': custBussinessType,
      'custTaxType': custTaxType,
      'custOfficeType': custOfficeType,
      'custOfficeOwnership': custOfficeOwnership,
      'custType': custType,
      'checkboxCar': checkboxCar,
      'checkbox1': checkbox1,
      'checkbox2': checkbox2,
      'checkbox3': checkbox3,
      'checkbox4': checkbox4,
      'checkbox5': checkbox5,
      'checkbox6': checkbox6,
      'latitude': latitude,
      'longitude': longitude,
      'currentLocation': currentLocation,
      'remark': remark,
      'image': image,
      'images': images.map((x) => x.toMap()).toList(),
      'new': new_,
      'speedoKmModel': speedoKmModel,
      'checkpoint': checkpoint,
      'salesid': salesid,
    };
  }

  factory SalesActivityFormData.fromMap(Map<String, dynamic> map) {
    return SalesActivityFormData(
      customerId: map['customerId'] ?? '',
      custName: map['custName'] ?? '',
      custKtpNpwp: map['custKtpNpwp'] ?? '',
      custPhone: map['custPhone'] ?? '',
      custEmail: map['custEmail'] ?? '',
      custAddress: map['custAddress'] ?? '',
      custProvince: map['custProvince'] ?? '',
      custCity: map['custCity'] ?? '',
      custDistrict: map['custDistrict'] ?? '',
      custVillage: map['custVillage'] ?? '',
      custBussiness: map['custBussiness'] ?? '',
      custBussinessStatus: map['custBussinessStatus'] ?? '',
      custBussinessType: map['custBussinessType'] ?? '',
      custTaxType: map['custTaxType'] ?? '',
      custOfficeType: map['custOfficeType'] ?? '',
      custOfficeOwnership: map['custOfficeOwnership'] ?? '',
      custType: map['custType'] ?? '',
      checkboxCar: map['checkboxCar'] ?? '',
      checkbox1: map['checkbox1'] ?? false,
      checkbox2: map['checkbox2'] ?? false,
      checkbox3: map['checkbox3'] ?? false,
      checkbox4: map['checkbox4'] ?? false,
      checkbox5: map['checkbox5'] ?? false,
      checkbox6: map['checkbox6'] ?? false,
      latitude: map['latitude']?.toDouble() ?? 0.0,
      longitude: map['longitude']?.toDouble() ?? 0.0,
      currentLocation: map['currentLocation'] ?? '',
      remark: map['remark'] ?? '',
      image: map['image'] ?? '',
      images: List<Image>.from(map['images']?.map((x) => Image.fromMap(x))),
      new_: map['new'] ?? '',
      speedoKmModel: map['speedoKmModel'] ?? '',
      checkpoint: map['checkpoint'] ?? '',
      salesid: map['salesid'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory SalesActivityFormData.fromJson(String source) =>
      SalesActivityFormData.fromMap(json.decode(source));

  @override
  String toString() {
    return 'SalesActivityFormData(customerId: $customerId, custName: $custName, custKtpNpwp: $custKtpNpwp, custPhone: $custPhone, custEmail: $custEmail, custAddress: $custAddress, custProvince: $custProvince, custCity: $custCity, custDistrict: $custDistrict, custVillage: $custVillage, custBussiness: $custBussiness, custBussinessStatus: $custBussinessStatus, custBussinessType: $custBussinessType, custTaxType: $custTaxType, custOfficeType: $custOfficeType, custOfficeOwnership: $custOfficeOwnership, custType: $custType, checkboxCar: $checkboxCar, checkbox1: $checkbox1, checkbox2: $checkbox2, checkbox3: $checkbox3, checkbox4: $checkbox4, checkbox5: $checkbox5, checkbox6: $checkbox6, latitude: $latitude, longitude: $longitude, currentLocation: $currentLocation, remark: $remark, image: $image, images: $images, new_: $new_, speedoKmModel: $speedoKmModel, checkpoint: $checkpoint, salesid: $salesid)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SalesActivityFormData &&
        other.customerId == customerId &&
        other.custName == custName &&
        other.custKtpNpwp == custKtpNpwp &&
        other.custPhone == custPhone &&
        other.custEmail == custEmail &&
        other.custAddress == custAddress &&
        other.custProvince == custProvince &&
        other.custCity == custCity &&
        other.custDistrict == custDistrict &&
        other.custVillage == custVillage &&
        other.custBussiness == custBussiness &&
        other.custBussinessStatus == custBussinessStatus &&
        other.custBussinessType == custBussinessType &&
        other.custTaxType == custTaxType &&
        other.custOfficeType == custOfficeType &&
        other.custOfficeOwnership == custOfficeOwnership &&
        other.custType == custType &&
        other.checkboxCar == checkboxCar &&
        other.checkbox1 == checkbox1 &&
        other.checkbox2 == checkbox2 &&
        other.checkbox3 == checkbox3 &&
        other.checkbox4 == checkbox4 &&
        other.checkbox5 == checkbox5 &&
        other.checkbox6 == checkbox6 &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.currentLocation == currentLocation &&
        other.remark == remark &&
        other.image == image &&
        listEquals(other.images, images) &&
        other.new_ == new_ &&
        other.speedoKmModel == speedoKmModel &&
        other.checkpoint == checkpoint &&
        other.salesid == salesid;
  }

  @override
  int get hashCode {
    return customerId.hashCode ^
        custName.hashCode ^
        custKtpNpwp.hashCode ^
        custPhone.hashCode ^
        custEmail.hashCode ^
        custAddress.hashCode ^
        custProvince.hashCode ^
        custCity.hashCode ^
        custDistrict.hashCode ^
        custVillage.hashCode ^
        custBussiness.hashCode ^
        custBussinessStatus.hashCode ^
        custBussinessType.hashCode ^
        custTaxType.hashCode ^
        custOfficeType.hashCode ^
        custOfficeOwnership.hashCode ^
        custType.hashCode ^
        checkboxCar.hashCode ^
        checkbox1.hashCode ^
        checkbox2.hashCode ^
        checkbox3.hashCode ^
        checkbox4.hashCode ^
        checkbox5.hashCode ^
        checkbox6.hashCode ^
        latitude.hashCode ^
        longitude.hashCode ^
        currentLocation.hashCode ^
        remark.hashCode ^
        image.hashCode ^
        images.hashCode ^
        new_.hashCode ^
        speedoKmModel.hashCode ^
        checkpoint.hashCode ^
        salesid.hashCode;
  }
}

class Image {
  final String src;
  final String remark;
  final String price;
  Image({required this.src, required this.remark, required this.price});

  Image copyWith({String? src, String? remark, String? price}) {
    return Image(
      src: src ?? this.src,
      remark: remark ?? this.remark,
      price: price ?? this.price,
    );
  }

  Map<String, dynamic> toMap() {
    return {'src': src, 'remark': remark, 'price': price};
  }

  factory Image.fromMap(Map<String, dynamic> map) {
    return Image(
      src: map['src'] ?? '',
      remark: map['remark'] ?? '',
      price: map['price'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory Image.fromJson(String source) => Image.fromMap(json.decode(source));

  @override
  String toString() => 'Image(src: $src, remark: $remark, price: $price)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Image &&
        other.src == src &&
        other.remark == remark &&
        other.price == price;
  }

  @override
  int get hashCode => src.hashCode ^ remark.hashCode ^ price.hashCode;
}
