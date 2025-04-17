import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'warehouse.dart';

class Batch {
  final String company_id;
  final String mill_id;
  final List<Warehouse> warehouses;
  Batch({
    required this.company_id,
    required this.mill_id,
    required this.warehouses,
  });

  Batch copyWith({
    String? company_id,
    String? mill_id,
    List<Warehouse>? warehouses,
  }) {
    return Batch(
      company_id: company_id ?? this.company_id,
      mill_id: mill_id ?? this.mill_id,
      warehouses: warehouses ?? this.warehouses,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'company_id': company_id,
      'mill_id': mill_id,
      'warehouses': warehouses.map((x) => x.toMap()).toList(),
    };
  }

  factory Batch.fromMap(Map<String, dynamic> map) {
    return Batch(
      company_id: map['company_id'] ?? '',
      mill_id: map['mill_id'] ?? '',
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
  String toString() =>
      'Batch(company_id: $company_id, mill_id: $mill_id, warehouses: $warehouses)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Batch &&
        other.company_id == company_id &&
        other.mill_id == mill_id &&
        listEquals(other.warehouses, warehouses);
  }

  @override
  int get hashCode =>
      company_id.hashCode ^ mill_id.hashCode ^ warehouses.hashCode;
}
