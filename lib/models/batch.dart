import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'warehouse.dart';

class Batch {
  final String vehicleID;
  final String driverID;
  final String kategori;
  final List<Warehouse> warehouses;
  Batch(
    this.vehicleID,
    this.driverID,
    this.kategori, {
    required this.warehouses,
  });

  Batch copyWith({
    String? vehicleID,
    String? driverID,
    String? kategori,
    List<Warehouse>? warehouses,
  }) {
    return Batch(
      vehicleID ?? this.vehicleID,
      driverID ?? this.driverID,
      kategori ?? this.kategori,
      warehouses: warehouses ?? this.warehouses,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'vehicle_id': vehicleID,
      'driver_id': driverID,
      'kategori': kategori,
      'warehouses': warehouses.map((x) => x.toMap()).toList(),
    };
  }

  factory Batch.fromMap(Map<String, dynamic> map) {
    return Batch(
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
    return 'Batch(vehicle_id: $vehicleID, driver_id: $driverID, kategori: $kategori, warehouses: $warehouses)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Batch &&
        other.vehicleID == vehicleID &&
        other.driverID == driverID &&
        other.kategori == kategori &&
        listEquals(other.warehouses, warehouses);
  }

  @override
  int get hashCode {
    return vehicleID.hashCode ^
        driverID.hashCode ^
        kategori.hashCode ^
        warehouses.hashCode;
  }
}
