import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:vivakencanaapp/models/warehouse.dart';

class Batch {
  final String companyID;
  final String companyName;
  final String millID;
  final String vehicleID;
  final String driverID;
  final String kategori;
  final List<Warehouse> warehouses;
  Batch(
    this.companyID,
    this.companyName,
    this.millID,
    this.vehicleID,
    this.driverID,
    this.kategori, {
    required this.warehouses,
  });

  Batch copyWith({
    String? companyID,
    String? companyName,
    String? millID,
    String? vehicleID,
    String? driverID,
    String? kategori,
    List<Warehouse>? warehouses,
  }) {
    return Batch(
      companyID ?? this.companyID,
      companyName ?? this.companyName,
      millID ?? this.millID,
      vehicleID ?? this.vehicleID,
      driverID ?? this.driverID,
      kategori ?? this.kategori,
      warehouses: warehouses ?? this.warehouses,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'company_id': companyID,
      'company_name ': companyName,
      'mill_id': millID,
      'vehicle_id': vehicleID,
      'driver_id': driverID,
      'kategori': kategori,
      'warehouses': warehouses.map((x) => x.toMap()).toList(),
    };
  }

  factory Batch.fromMap(Map<String, dynamic> map) {
    return Batch(
      map['company_id'] ?? '',
      map['company_name'] ?? '',
      map['mill_id'] ?? '',
      map['vehicle_id'] ?? '',
      map['driver_id'] ?? '',
      map['kategori'] ?? '',
      warehouses:
          map['warehouses'] != null
              ? List<Warehouse>.from(
                map['warehouses']?.map((x) => Warehouse.fromMap(x)),
              )
              : [],
    );
  }

  String toJson() => json.encode(toMap());

  factory Batch.fromJson(String source) => Batch.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Batch(company_id: $companyID, company_name: $companyName, mill_id: $millID, vehicle_id: $vehicleID, driver_id: $driverID, kategori: $kategori, warehouses: $warehouses)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Batch &&
        other.companyID == companyID &&
        other.companyName == companyName &&
        other.millID == millID &&
        other.vehicleID == vehicleID &&
        other.driverID == driverID &&
        other.kategori == kategori &&
        listEquals(other.warehouses, warehouses);
  }

  @override
  int get hashCode {
    return companyID.hashCode ^
        companyName.hashCode ^
        millID.hashCode ^
        vehicleID.hashCode ^
        driverID.hashCode ^
        kategori.hashCode ^
        warehouses.hashCode;
  }
}
