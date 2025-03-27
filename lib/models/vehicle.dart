import 'dart:convert';

class Vehicle {
  final String expID;
  final String vehicleID;
  final String vehicleType;
  final String activeFlag;
  final String remark;
  final String expDescr;
  final String kota;
  final String driverID;
  final String driverName;
  final String availability;
  final String cityCode;
  final String provinceCode;

  Vehicle({
    required this.expID,
    required this.vehicleID,
    required this.vehicleType,
    required this.activeFlag,
    required this.remark,
    required this.expDescr,
    required this.kota,
    required this.driverID,
    required this.driverName,
    required this.availability,
    required this.cityCode,
    required this.provinceCode,
  });

  Vehicle copyWith({
    String? expID,
    String? vehicleID,
    String? vehicleType,
    String? activeFlag,
    String? remark,
    String? expDescr,
    String? kota,
    String? driverID,
    String? driverName,
    String? availability,
    String? cityCode,
    String? provinceCode,
  }) {
    return Vehicle(
      expID: expID ?? this.expID,
      vehicleID: vehicleID ?? this.vehicleID,
      vehicleType: vehicleType ?? this.vehicleType,
      activeFlag: activeFlag ?? this.activeFlag,
      remark: remark ?? this.remark,
      expDescr: expDescr ?? this.expDescr,
      kota: kota ?? this.kota,
      driverID: driverID ?? this.driverID,
      driverName: driverName ?? this.driverName,
      availability: availability ?? this.availability,
      cityCode: cityCode ?? this.cityCode,
      provinceCode: provinceCode ?? this.provinceCode,
    );
  }

  bool get isBanned {
    return activeFlag == 'N';
  }

  bool get isIdle {
    return availability == 'I';
  }

  bool get isReady {
    return availability == 'R';
  }

  bool get isDelivery {
    return availability == 'D';
  }

  bool get isLoading {
    return availability == 'L';
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'exp_id': expID,
      'vehicle_id': vehicleID,
      'vehicle_type': vehicleType,
      'active_flag': activeFlag,
      'remark': remark,
      'exp_descr': expDescr,
      'kota': kota,
      'driver_id': driverID,
      'driver_name': driverName,
      'availability': availability,
      'city_code': cityCode,
      'province_code': provinceCode,
    };
  }

  factory Vehicle.fromMap(Map<String, dynamic> map) {
    return Vehicle(
      expID: map['exp_id'] as String,
      vehicleID: map['vehicle_id'] as String,
      vehicleType: map['vehicle_type'] as String,
      activeFlag: map['active_flag'] as String,
      remark: map['remark'] as String,
      expDescr: map['exp_descr'] as String,
      kota: map['kota'] as String,
      driverID: map['driver_id'] as String,
      driverName: map['driver_name'] as String,
      availability: map['availability'] as String,
      cityCode: map['city_code'] as String,
      provinceCode: map['province_code'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory Vehicle.fromJson(String source) =>
      Vehicle.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Vehicle(expID: $expID, vehicleID: $vehicleID, vehicleType: $vehicleType, activeFlag: $activeFlag, remark: $remark, expDescr: $expDescr, kota: $kota, driverID: $driverID, driverName: $driverName, availability: $availability, cityCode: $cityCode, provinceCode: $provinceCode)';
  }

  @override
  bool operator ==(covariant Vehicle other) {
    if (identical(this, other)) return true;

    return other.expID == expID &&
        other.vehicleID == vehicleID &&
        other.vehicleType == vehicleType &&
        other.activeFlag == activeFlag &&
        other.remark == remark &&
        other.expDescr == expDescr &&
        other.kota == kota &&
        other.driverID == driverID &&
        other.driverName == driverName &&
        other.availability == availability &&
        other.cityCode == cityCode &&
        other.provinceCode == provinceCode;
  }

  @override
  int get hashCode {
    return expID.hashCode ^
        vehicleID.hashCode ^
        vehicleType.hashCode ^
        activeFlag.hashCode ^
        remark.hashCode ^
        expDescr.hashCode ^
        kota.hashCode ^
        driverID.hashCode ^
        driverName.hashCode ^
        availability.hashCode ^
        cityCode.hashCode ^
        provinceCode.hashCode;
  }
}
