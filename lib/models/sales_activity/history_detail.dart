import 'dart:convert';

class HistoryDetail {
  final String entityId;
  final String salesId;
  final String customerId;
  final String customerName;
  final String customerKtpNpwp;
  final String customerPhone;
  final String customerEmail;
  final String customerAddress;
  final String customerProvince;
  final String customerCity;
  final String customerDistrict;
  final String customerVillage;
  final String customerKindOfBussiness;
  final String customerBussinessStatus;
  final String customerBussinessType;
  final String customerTaxType;
  final String customerOfficeType;
  final String customerBussinessOwnership;
  final String customerType;
  final String salesVehicle;
  final String startEndPoint;
  final String productOffer;
  final String takeOrder;
  final String promoInfo;
  final String penagihan;
  final String customerVisit;
  final String latitude;
  final String longitude;
  final String gpsAddress;
  final String remark;
  final String trDate;
  final String trModified;
  final String userId2;
  final String vehicleKm;
  final String customerNew;
  final String trId;
  final String seqId;
  final String gpsDistance;
  HistoryDetail({
    required this.entityId,
    required this.salesId,
    required this.customerId,
    required this.customerName,
    required this.customerKtpNpwp,
    required this.customerPhone,
    required this.customerEmail,
    required this.customerAddress,
    required this.customerProvince,
    required this.customerCity,
    required this.customerDistrict,
    required this.customerVillage,
    required this.customerKindOfBussiness,
    required this.customerBussinessStatus,
    required this.customerBussinessType,
    required this.customerTaxType,
    required this.customerOfficeType,
    required this.customerBussinessOwnership,
    required this.customerType,
    required this.salesVehicle,
    required this.startEndPoint,
    required this.productOffer,
    required this.takeOrder,
    required this.promoInfo,
    required this.penagihan,
    required this.customerVisit,
    required this.latitude,
    required this.longitude,
    required this.gpsAddress,
    required this.remark,
    required this.trDate,
    required this.trModified,
    required this.userId2,
    required this.vehicleKm,
    required this.customerNew,
    required this.trId,
    required this.seqId,
    required this.gpsDistance,
  });

  HistoryDetail copyWith({
    String? entityId,
    String? salesId,
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
    String? customerKindOfBussiness,
    String? customerBussinessStatus,
    String? customerBussinessType,
    String? customerTaxType,
    String? customerOfficeType,
    String? customerBussinessOwnership,
    String? customerType,
    String? salesVehicle,
    String? startEndPoint,
    String? productOffer,
    String? takeOrder,
    String? promoInfo,
    String? penagihan,
    String? customerVisit,
    String? latitude,
    String? longitude,
    String? gpsAddress,
    String? remark,
    String? trDate,
    String? trModified,
    String? userId2,
    String? vehicleKm,
    String? customerNew,
    String? trId,
    String? seqId,
    String? gpsDistance,
  }) {
    return HistoryDetail(
      entityId: entityId ?? this.entityId,
      salesId: salesId ?? this.salesId,
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
      customerKindOfBussiness: customerKindOfBussiness ?? this.customerKindOfBussiness,
      customerBussinessStatus: customerBussinessStatus ?? this.customerBussinessStatus,
      customerBussinessType: customerBussinessType ?? this.customerBussinessType,
      customerTaxType: customerTaxType ?? this.customerTaxType,
      customerOfficeType: customerOfficeType ?? this.customerOfficeType,
      customerBussinessOwnership: customerBussinessOwnership ?? this.customerBussinessOwnership,
      customerType: customerType ?? this.customerType,
      salesVehicle: salesVehicle ?? this.salesVehicle,
      startEndPoint: startEndPoint ?? this.startEndPoint,
      productOffer: productOffer ?? this.productOffer,
      takeOrder: takeOrder ?? this.takeOrder,
      promoInfo: promoInfo ?? this.promoInfo,
      penagihan: penagihan ?? this.penagihan,
      customerVisit: customerVisit ?? this.customerVisit,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      gpsAddress: gpsAddress ?? this.gpsAddress,
      remark: remark ?? this.remark,
      trDate: trDate ?? this.trDate,
      trModified: trModified ?? this.trModified,
      userId2: userId2 ?? this.userId2,
      vehicleKm: vehicleKm ?? this.vehicleKm,
      customerNew: customerNew ?? this.customerNew,
      trId: trId ?? this.trId,
      seqId: seqId ?? this.seqId,
      gpsDistance: gpsDistance ?? this.gpsDistance,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'entity_id': entityId,
      'sales_id': salesId,
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
      'customer_kind_of_bussiness': customerKindOfBussiness,
      'customer_bussiness_status': customerBussinessStatus,
      'customer_bussiness_type': customerBussinessType,
      'customer_tax_type': customerTaxType,
      'customer_office_type': customerOfficeType,
      'customer_bussiness_ownership': customerBussinessOwnership,
      'customer_type': customerType,
      'sales_vehicle': salesVehicle,
      'start_end_point': startEndPoint,
      'product_offer': productOffer,
      'take_order': takeOrder,
      'promo_info': promoInfo,
      'penagihan': penagihan,
      'customer_visit': customerVisit,
      'latitude': latitude,
      'longitude': longitude,
      'gps_address': gpsAddress,
      'remark': remark,
      'tr_date': trDate,
      'tr_modified': trModified,
      'user_id2': userId2,
      'vehicle_km': vehicleKm,
      'customer_new': customerNew,
      'tr_id': trId,
      'seq_id': seqId,
      'gps_distance': gpsDistance,
    };
  }

  factory HistoryDetail.fromMap(Map<String, dynamic> map) {
    return HistoryDetail(
      entityId: map['entity_id'] ?? '',
      salesId: map['sales_id'] ?? '',
      customerId: map['customer_id'] ?? '',
      customerName: map['customer_name'] ?? '',
      customerKtpNpwp: map['customer_ktp_npwp'] ?? '',
      customerPhone: map['customer_phone'] ?? '',
      customerEmail: map['customer_email'] ?? '',
      customerAddress: map['customer_address'] ?? '',
      customerProvince: map['customer_province'] ?? '',
      customerCity: map['customer_city'] ?? '',
      customerDistrict: map['customer_district'] ?? '',
      customerVillage: map['customer_village'] ?? '',
      customerKindOfBussiness: map['customer_kind_of_bussiness'] ?? '',
      customerBussinessStatus: map['customer_bussiness_status'] ?? '',
      customerBussinessType: map['customer_bussiness_type'] ?? '',
      customerTaxType: map['customer_tax_type'] ?? '',
      customerOfficeType: map['customer_office_type'] ?? '',
      customerBussinessOwnership: map['customer_bussiness_ownership'] ?? '',
      customerType: map['customer_type'] ?? '',
      salesVehicle: map['sales_vehicle'] ?? '',
      startEndPoint: map['start_end_point'] ?? '',
      productOffer: map['product_offer'] ?? '',
      takeOrder: map['take_order'] ?? '',
      promoInfo: map['promo_info'] ?? '',
      penagihan: map['penagihan'] ?? '',
      customerVisit: map['customer_visit'] ?? '',
      latitude: map['latitude'] ?? '',
      longitude: map['longitude'] ?? '',
      gpsAddress: map['gps_address'] ?? '',
      remark: map['remark'] ?? '',
      trDate: map['tr_date'] ?? '',
      trModified: map['tr_modified'] ?? '',
      userId2: map['user_id2'] ?? '',
      vehicleKm: map['vehicle_km'] ?? '',
      customerNew: map['customer_new'] ?? '',
      trId: map['tr_id'] ?? '',
      seqId: map['seq_id'] ?? '',
      gpsDistance: map['gps_distance'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory HistoryDetail.fromJson(String source) => HistoryDetail.fromMap(json.decode(source));

  @override
  String toString() {
    return 'HistoryDetail(entityId: $entityId, salesId: $salesId, customerId: $customerId, customerName: $customerName, customerKtpNpwp: $customerKtpNpwp, customerPhone: $customerPhone, customerEmail: $customerEmail, customerAddress: $customerAddress, customerProvince: $customerProvince, customerCity: $customerCity, customerDistrict: $customerDistrict, customerVillage: $customerVillage, customerKindOfBussiness: $customerKindOfBussiness, customerBussinessStatus: $customerBussinessStatus, customerBussinessType: $customerBussinessType, customerTaxType: $customerTaxType, customerOfficeType: $customerOfficeType, customerBussinessOwnership: $customerBussinessOwnership, customerType: $customerType, salesVehicle: $salesVehicle, startEndPoint: $startEndPoint, productOffer: $productOffer, takeOrder: $takeOrder, promoInfo: $promoInfo, penagihan: $penagihan, customerVisit: $customerVisit, latitude: $latitude, longitude: $longitude, gpsAddress: $gpsAddress, remark: $remark, trDate: $trDate, trModified: $trModified, userId2: $userId2, vehicleKm: $vehicleKm, customerNew: $customerNew, trId: $trId, seqId: $seqId, gpsDistance: $gpsDistance)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is HistoryDetail &&
      other.entityId == entityId &&
      other.salesId == salesId &&
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
      other.customerKindOfBussiness == customerKindOfBussiness &&
      other.customerBussinessStatus == customerBussinessStatus &&
      other.customerBussinessType == customerBussinessType &&
      other.customerTaxType == customerTaxType &&
      other.customerOfficeType == customerOfficeType &&
      other.customerBussinessOwnership == customerBussinessOwnership &&
      other.customerType == customerType &&
      other.salesVehicle == salesVehicle &&
      other.startEndPoint == startEndPoint &&
      other.productOffer == productOffer &&
      other.takeOrder == takeOrder &&
      other.promoInfo == promoInfo &&
      other.penagihan == penagihan &&
      other.customerVisit == customerVisit &&
      other.latitude == latitude &&
      other.longitude == longitude &&
      other.gpsAddress == gpsAddress &&
      other.remark == remark &&
      other.trDate == trDate &&
      other.trModified == trModified &&
      other.userId2 == userId2 &&
      other.vehicleKm == vehicleKm &&
      other.customerNew == customerNew &&
      other.trId == trId &&
      other.seqId == seqId &&
      other.gpsDistance == gpsDistance;
  }

  @override
  int get hashCode {
    return entityId.hashCode ^
      salesId.hashCode ^
      customerId.hashCode ^
      customerName.hashCode ^
      customerKtpNpwp.hashCode ^
      customerPhone.hashCode ^
      customerEmail.hashCode ^
      customerAddress.hashCode ^
      customerProvince.hashCode ^
      customerCity.hashCode ^
      customerDistrict.hashCode ^
      customerVillage.hashCode ^
      customerKindOfBussiness.hashCode ^
      customerBussinessStatus.hashCode ^
      customerBussinessType.hashCode ^
      customerTaxType.hashCode ^
      customerOfficeType.hashCode ^
      customerBussinessOwnership.hashCode ^
      customerType.hashCode ^
      salesVehicle.hashCode ^
      startEndPoint.hashCode ^
      productOffer.hashCode ^
      takeOrder.hashCode ^
      promoInfo.hashCode ^
      penagihan.hashCode ^
      customerVisit.hashCode ^
      latitude.hashCode ^
      longitude.hashCode ^
      gpsAddress.hashCode ^
      remark.hashCode ^
      trDate.hashCode ^
      trModified.hashCode ^
      userId2.hashCode ^
      vehicleKm.hashCode ^
      customerNew.hashCode ^
      trId.hashCode ^
      seqId.hashCode ^
      gpsDistance.hashCode;
  }
}